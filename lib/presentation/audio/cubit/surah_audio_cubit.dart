import 'dart:async';

import 'package:ikra/data/audio/audio_url_provider.dart';
import 'package:just_audio/just_audio.dart';

/// Lightweight audio state for a single Surah playback session.
class SurahAudioState {
  final bool isLoading;
  final bool isPlaying;
  final int? currentAyah; // 1-based index of the currently playing ayah
  final int totalAyah; // total number of ayat in this surah
  final String? error;
  final Reciter reciter;

  const SurahAudioState({
    required this.isLoading,
    required this.isPlaying,
    required this.currentAyah,
    required this.totalAyah,
    required this.reciter,
    this.error,
  });

  SurahAudioState copyWith({
    bool? isLoading,
    bool? isPlaying,
    int? currentAyah,
    int? totalAyah,
    Reciter? reciter,
    String? error,
  }) {
    return SurahAudioState(
      isLoading: isLoading ?? this.isLoading,
      isPlaying: isPlaying ?? this.isPlaying,
      currentAyah: currentAyah ?? this.currentAyah,
      totalAyah: totalAyah ?? this.totalAyah,
      reciter: reciter ?? this.reciter,
      error: error,
    );
  }

  factory SurahAudioState.initial({required Reciter reciter}) =>
      SurahAudioState(
        isLoading: false,
        isPlaying: false,
        currentAyah: null,
        totalAyah: 0,
        reciter: reciter,
      );
}

/// Cubit-like controller without importing flutter_bloc on purpose.
/// You can wrap this in Bloc/Cubit later if you prefer.
/// Exposes a broadcast stream of [SurahAudioState].
class SurahAudioCubit {
  final _stateCtrl = StreamController<SurahAudioState>.broadcast();
  SurahAudioState _state = SurahAudioState.initial(reciter: Reciter.alafasy);
  SurahAudioState get state => _state;
  Stream<SurahAudioState> get stream => _stateCtrl.stream;

  final AudioPlayer _player = AudioPlayer();
  final AudioUrlProvider _urlProvider;
  final int surah;

  StreamSubscription<int?>? _idxSub;
  StreamSubscription<bool>? _playingSub;

  SurahAudioCubit({
    required AudioUrlProvider urlProvider,
    required this.surah,
    Reciter reciter = Reciter.alafasy,
  }) : _urlProvider = urlProvider {
    _emit(_state.copyWith(reciter: reciter));

    // Reflect player currentIndex -> currentAyah (1-based)
    _idxSub = _player.currentIndexStream.listen((i) {
      if (i == null) return;
      _emit(_state.copyWith(currentAyah: i + 1));
    });

    // Reflect player playing status
    _playingSub = _player.playingStream.listen((playing) {
      _emit(_state.copyWith(isPlaying: playing));
    });
  }

  /// Build the playlist for this surah with [totalAyah] tracks.
  Future<void> load({required int totalAyah}) async {
    _emit(_state.copyWith(
        isLoading: true, totalAyah: totalAyah, currentAyah: 1,),);
    try {
      final sources = List.generate(totalAyah, (i) {
        final ayah = i + 1;
        final url = _urlProvider.ayahUrl(
            reciter: _state.reciter, surah: surah, ayah: ayah,);
        return AudioSource.uri(Uri.parse(url));
      });

      await _player.setAudioSource(ConcatenatingAudioSource(children: sources));
      _emit(_state.copyWith(isLoading: false));
    } catch (e) {
      _emit(_state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Start playing from the given ayah (1-based).
  Future<void> playFrom(int ayah) async {
    if (_state.totalAyah == 0) return;
    final index = (ayah - 1).clamp(0, _state.totalAyah - 1);
    await _player.seek(Duration.zero, index: index);
    await _player.play();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> next() async {
    final cur = _player.currentIndex ?? 0;
    if (cur < _state.totalAyah - 1) {
      await _player.seek(Duration.zero, index: cur + 1);
      await _player.play();
    }
  }

  Future<void> previous() async {
    final cur = _player.currentIndex ?? 0;
    if (cur > 0) {
      await _player.seek(Duration.zero, index: cur - 1);
      await _player.play();
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  void _emit(SurahAudioState s) {
    _state = s;
    _stateCtrl.add(s);
  }

  Future<void> dispose() async {
    await _idxSub?.cancel();
    await _playingSub?.cancel();
    await _player.dispose();
    await _stateCtrl.close();
  }
}
