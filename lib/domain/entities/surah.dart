import 'package:equatable/equatable.dart';

class Surah extends Equatable {
  final int number;
  final String nameAr;
  final String nameTr;
  final String nameEn;
  final int ayahCount;

  const Surah({
    required this.number,
    required this.nameAr,
    required this.nameTr,
    required this.nameEn,
    required this.ayahCount,
  });

  @override
  List<Object?> get props => [number, nameAr, nameTr, nameEn, ayahCount];
}
