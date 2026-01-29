class Peminjaman {
  final int id;
  final String userId;
  final DateTime tanggalPinjam;
  final DateTime tanggalKembaliRencana;
  final String status;
  final int totalHarga;

  Peminjaman({
    required this.id,
    required this.userId,
    required this.tanggalPinjam,
    required this.tanggalKembaliRencana,
    required this.status,
    required this.totalHarga,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) => Peminjaman(
    id: json['id'] as int,
    userId: json['user_id'] as String,
    tanggalPinjam: DateTime.parse(json['tanggal_pinjam'] as String),
    tanggalKembaliRencana: DateTime.parse(json['tanggal_kembali_rencana'] as String),
    status: (json['status'] ?? '') as String,
    totalHarga: (json['total_harga'] as num).toInt(),
  );
}
