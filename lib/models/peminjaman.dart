class Peminjaman {
  final int id;
  final String userId;
  final String tanggalPinjam;
  final String tanggalKembaliRencana;
  final int totalHarga;
  final int alatId;
  final String status;

  Peminjaman({
    required this.id,
    required this.userId,
    required this.tanggalPinjam,
    required this.tanggalKembaliRencana,
    required this.totalHarga,
    required this.alatId,
    required this.status,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      id: json['id'],
      userId: json['user_id'],
      tanggalPinjam: json['tanggal_pinjam'],
      tanggalKembaliRencana: json['tanggal_kembali_rencana'],
      totalHarga: json['total_harga'],
      alatId: json['alat_id'],
      status: json['status'],
    );
  }
}
