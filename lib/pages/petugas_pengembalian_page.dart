import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetugasPengembalianPage extends StatefulWidget {
  const PetugasPengembalianPage({super.key});

  @override
  State<PetugasPengembalianPage> createState() =>
      _PetugasPengembalianPageState();
}

class _PetugasPengembalianPageState extends State<PetugasPengembalianPage> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetch();
  }

  void refresh() {
    setState(() => futureData = fetch());
  }

  Future<List<Map<String, dynamic>>> fetch() async {
    final res = await supabase
        .from('peminjaman')
        .select(
          'id, tanggal_pinjam, tanggal_kembali_rencana, status, kode_peminjaman, '
          'users:user_id(id,nama,email), '
          'alat:alat_id(id,nama_alat)',
        )
        .order('tanggal_pinjam', ascending: false);

    final list = List<Map<String, dynamic>>.from(res);

    // tampilkan yang masih dipinjam (monitor pengembalian)
    return list
        .where((e) => (e['status'] ?? '').toString() == 'dipinjam')
        .toList();
  }

  bool isLate(String? tanggalKembaliRencana) {
    if (tanggalKembaliRencana == null || tanggalKembaliRencana.isEmpty) {
      return false;
    }

    final due = DateTime.tryParse(tanggalKembaliRencana);

    if (due == null) {
      return false;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dueDate = DateTime(due.year, due.month, due.day);

    return today.isAfter(dueDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      appBar: AppBar(
        title: const Text("Memantau Pengembalian"),
        backgroundColor: const Color(0xFFB91C1C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(
              child: Text("Tidak ada peminjaman yang sedang dipinjam."),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final row = data[i];
              final user = (row['users'] as Map?) ?? {};
              final alat = (row['alat'] as Map?) ?? {};

              final namaUser = (user['nama'] ?? user['email'] ?? '-')
                  .toString();
              final namaAlat = (alat['nama_alat'] ?? '-').toString();
              final kode = (row['kode_peminjaman'] ?? '-').toString();
              final due = (row['tanggal_kembali_rencana'] ?? '').toString();
              final terlambat = isLate(due);

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 18,
                      color: Colors.black.withValues(alpha: 0.06),
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB91C1C).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        terlambat
                            ? Icons.warning_rounded
                            : Icons.timer_outlined,
                        color: const Color(0xFFB91C1C),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$namaUser • $namaAlat",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Kode: $kode",
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Kembali rencana: $due",
                            style: TextStyle(
                              color: terlambat ? Colors.red : Colors.black54,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: (terlambat ? Colors.red : Colors.green)
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: (terlambat ? Colors.red : Colors.green)
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        terlambat ? "Terlambat" : "Dipinjam",
                        style: TextStyle(
                          color: terlambat ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
