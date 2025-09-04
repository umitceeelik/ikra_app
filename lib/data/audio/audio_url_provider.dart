/// Very small utility to build per-ayah audio URLs for different reciters.
/// Uses EveryAyah verse-by-verse structure:
///   https://everyayah.com/data/Alafasy_64kbps/SSSAAA.mp3
/// where SSS = 3-digit surah, AAA = 3-digit ayah (both zero-padded).
///
/// If needed, you can switch to 128kbps by changing the base path below.
/// Directory listing reference shows files like 001001.mp3 exist.
/// See: everyayah.com/data/Alafasy_64kbps/ and .../Alafasy_128kbps/
/// (This fixes 404s caused by a wrong folder name.)
///
/// Reciter enum left in place so we can add more reciters later.
enum Reciter { alafasy /*, husary, minshawi ... */ }

class AudioUrlProvider {
  /// Build ayah URL for the given [reciter], [surah], and [ayah].
  String ayahUrl({
    required Reciter reciter,
    required int surah,
    required int ayah,
    bool highQuality = false, // toggle 64kbps / 128kbps if needed
  }) {
    final s = surah.toString().padLeft(3, '0');
    final a = ayah.toString().padLeft(3, '0');

    switch (reciter) {
      case Reciter.alafasy:
        // Correct EveryAyah folder names (fixes 404):
        //  - 64kbps: Alafasy_64kbps
        //  - 128kbps: Alafasy_128kbps
        final base = highQuality
            ? 'https://everyayah.com/data/Alafasy_128kbps'
            : 'https://everyayah.com/data/Alafasy_64kbps';
        return '$base/${s}${a}.mp3';
    }
  }
}
