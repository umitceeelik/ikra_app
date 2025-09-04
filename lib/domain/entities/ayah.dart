import 'package:equatable/equatable.dart';

class Ayah extends Equatable {
  final int surah;
  final int numberInSurah;
  final String textAr;
  final String? textTr;
  final String? textEn;
  final int juz;

  const Ayah({
    required this.surah,
    required this.numberInSurah,
    required this.textAr,
    this.textTr,
    this.textEn,
    required this.juz,
  });

  @override
  List<Object?> get props =>
      [surah, numberInSurah, textAr, textTr, textEn, juz];
}
