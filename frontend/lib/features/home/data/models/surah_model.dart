class SurahModel {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;
  // TODO: Fitur Audio (Pengembangan Lebih Lanjut)
  // final Map? audioFull;

  SurahModel({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    // this.audioFull,
  });

  factory SurahModel.fromJson(Map json) {
    return SurahModel(
      nomor: json['nomor'] ?? 0,
      nama: json['nama'] ?? '',
      namaLatin: json['namaLatin'] ?? '',
      jumlahAyat: json['jumlahAyat'] ?? 0,
      tempatTurun: json['tempatTurun'] ?? '',
      arti: json['arti'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      // audioFull: Map.from(json['audioFull'] ?? {}),
    );
  }
}

class AyatModel {
  final int nomorAyat;
  final String teksArab;
  final String teksIndonesia;

  const AyatModel({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksIndonesia,
  });

  factory AyatModel.fromJson(Map<String, dynamic> json) {
    return AyatModel(
      nomorAyat: (json['nomorAyat'] as num?)?.toInt() ?? 0,
      teksArab: json['teksArab'] as String? ?? '',
      teksIndonesia: json['teksIndonesia'] as String? ?? '',
    );
  }
}
