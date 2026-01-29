class Kategori {
  final int id;
  final String namaKategori;

  Kategori({required this.id, required this.namaKategori});

  factory Kategori.fromJson(Map<String, dynamic> json) => Kategori(
    id: json['id'] as int,
    namaKategori: json['nama_kategori'] as String,
  );
}
