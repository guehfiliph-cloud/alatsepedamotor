import 'dart:developer'; // Import ini untuk menggunakan log()
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PeminjamanSayaPage extends StatefulWidget {
  const PeminjamanSayaPage({super.key});

  @override
  State<PeminjamanSayaPage> createState() => _PeminjamanSayaPageState();
}

class _PeminjamanSayaPageState extends State<PeminjamanSayaPage> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> _fetchMyLoans() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await supabase
          .from('peminjaman')
          .select('*, alat_sepeda_motor(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e, stackTrace) {
      // PERBAIKAN: Menggunakan log() alih-alih print()
      log("Error Fetching My Loans", error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peminjaman Saya')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMyLoans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Terjadi kesalahan saat memuat data.'),
            );
          }

          final loans = snapshot.data ?? [];

          if (loans.isEmpty) {
            return const Center(
              child: Text('Anda belum memiliki riwayat peminjaman.'),
            );
          }

          return ListView.builder(
            itemCount: loans.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final loan = loans[index];
              final alat = loan['alat_sepeda_motor'];
              final status = loan['status'].toString();

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    alat?['nama_alat'] ?? 'Alat Tidak Diketahui',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text("Tgl Pinjam: ${loan['tanggal_pinjam']}"),
                      Text(
                        "Kembali (Rencana): ${loan['tanggal_kembali_rencana']}",
                      ),
                      const SizedBox(height: 8),
                      _buildStatusBadge(status),
                    ],
                  ),
                  trailing: Text(
                    "Rp ${loan['total_harga']}",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'dipinjam':
        color = Colors.orange;
        break;
      case 'dikembalikan':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.grey;
        break;
      default:
        color = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
