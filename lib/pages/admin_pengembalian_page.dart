import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPengembalianPage extends StatefulWidget {
  const AdminPengembalianPage({super.key});

  @override
  State<AdminPengembalianPage> createState() => _AdminPengembalianPageState();
}

class _AdminPengembalianPageState extends State<AdminPengembalianPage> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _future;

  static const int dendaPerHari = 10000;

  @override
  void initState() {
    super.initState();
    _future = fetchData();
  }

  void refresh() => setState(() => _future = fetchData());

  String _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day).toIso8601String().split('T').first;

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  int _daysLate(DateTime due, DateTime real) {
    final d1 = DateTime(due.year, due.month, due.day);
    final d2 = DateTime(real.year, real.month, real.day);
    final diff = d2.difference(d1).inDays;
    return diff > 0 ? diff : 0;
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    final res = await supabase
        .from('pengembalian')
        .select('''
      id,
      peminjaman_id,
      tanggal_kembali_real,
      terlambat,
      denda,
      kondisi,

      peminjaman:peminjaman_id (
        id,
        kode_peminjaman,
        tanggal_kembali_rencana,
        status,
        users:user_id(nama,email)
      )
    ''')
        .order('id', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchPeminjamanForDropdown() async {
    final res = await supabase
        .from('peminjaman')
        .select('''
      id,
      kode_peminjaman,
      tanggal_kembali_rencana,
      status,
      users:user_id(nama,email)
    ''')
        .order('id', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> insertRow({
    required int peminjamanId,
    required DateTime tglReal,
    required String kondisi,
    required int terlambat,
    required int denda,
  }) async {
    await supabase.from('pengembalian').insert({
      'peminjaman_id': peminjamanId,
      'tanggal_kembali_real': _dateOnly(tglReal),
      'terlambat': terlambat,
      'denda': denda,
      'kondisi': kondisi,
    });

    await supabase
        .from('peminjaman')
        .update({'status': 'dikembalikan'})
        .eq('id', peminjamanId);
  }

  Future<void> updateRow({
    required int id,
    required int peminjamanId,
    required DateTime tglReal,
    required String kondisi,
    required int terlambat,
    required int denda,
  }) async {
    await supabase
        .from('pengembalian')
        .update({
          'peminjaman_id': peminjamanId,
          'tanggal_kembali_real': _dateOnly(tglReal),
          'terlambat': terlambat,
          'denda': denda,
          'kondisi': kondisi,
        })
        .eq('id', id);
  }

  Future<void> deleteRow(int id) async {
    await supabase.from('pengembalian').delete().eq('id', id);
  }

  Future<void> openForm({Map<String, dynamic>? row}) async {
    final isEdit = row != null;

    final peminjamanList = await fetchPeminjamanForDropdown();
    if (!mounted) return;

    if (peminjamanList.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Data peminjaman kosong.")));
      return;
    }

    int selectedPeminjamanId =
        (row?['peminjaman_id'] as int?) ?? (peminjamanList.first['id'] as int);

    DateTime tglReal =
        _parseDate(row?['tanggal_kembali_real']) ?? DateTime.now();

    String kondisi = (row?['kondisi'] ?? 'baik').toString();

    int terlambat = (row?['terlambat'] ?? 0) as int;
    int denda = (row?['denda'] ?? 0) as int;

    void recalc() {
      final selected = peminjamanList.firstWhere(
        (p) => p['id'] == selectedPeminjamanId,
        orElse: () => peminjamanList.first,
      );

      final due = _parseDate(selected['tanggal_kembali_rencana']);
      if (due == null) {
        terlambat = 0;
        denda = 0;
        return;
      }

      terlambat = _daysLate(due, tglReal);
      denda = terlambat * dendaPerHari;
    }

    recalc();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setD) => AlertDialog(
          title: Text(isEdit ? "Edit Pengembalian" : "Tambah Pengembalian"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: selectedPeminjamanId,
                    items: peminjamanList.map((p) {
                      final u = p['users'];
                      final nama = (u is Map ? (u['nama'] ?? '-') : '-');
                      final kode = (p['kode_peminjaman'] ?? 'PJ-?').toString();
                      final st = (p['status'] ?? '-').toString();
                      return DropdownMenuItem<int>(
                        value: p['id'] as int,
                        child: Text(
                          "$kode • $nama • $st",
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setD(() {
                        selectedPeminjamanId = v;
                        recalc();
                      });
                    },
                    decoration: const InputDecoration(labelText: "Peminjaman"),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Tanggal Kembali (Real)"),
                    subtitle: Text(_dateOnly(tglReal)),
                    trailing: const Icon(Icons.date_range),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDate: tglReal,
                      );
                      if (picked != null) {
                        setD(() {
                          tglReal = picked;
                          recalc();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: kondisi,
                    items: const [
                      DropdownMenuItem(value: 'baik', child: Text("baik")),
                      DropdownMenuItem(value: 'rusak', child: Text("rusak")),
                      DropdownMenuItem(value: 'hilang', child: Text("hilang")),
                    ],
                    onChanged: (v) => setD(() => kondisi = v ?? kondisi),
                    decoration: const InputDecoration(labelText: "Kondisi"),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      "Terlambat: $terlambat hari\nDenda: Rp $denda",
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

    try {
      if (isEdit) {
        await updateRow(
          id: row['id'] as int,
          peminjamanId: selectedPeminjamanId,
          tglReal: tglReal,
          kondisi: kondisi,
          terlambat: terlambat,
          denda: denda,
        );
      } else {
        await insertRow(
          peminjamanId: selectedPeminjamanId,
          tglReal: tglReal,
          kondisi: kondisi,
          terlambat: terlambat,
          denda: denda,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? "Berhasil diubah" : "Berhasil ditambah"),
        ),
      );
      refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal simpan: $e")));
    }
  }

  Future<void> confirmDelete(Map<String, dynamic> row) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Pengembalian"),
        content: Text("Yakin hapus ID: ${row['id']} ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await deleteRow(row['id'] as int);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Berhasil dihapus")));
      refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal hapus: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Pengembalian & Denda"),
        actions: [
          IconButton(onPressed: refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }

          final data = snap.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text("Data pengembalian kosong"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final r = data[i];
              final p = r['peminjaman'];
              final kode = (p is Map
                  ? (p['kode_peminjaman'] ?? 'PJ-?')
                  : 'PJ-?');
              final u = (p is Map ? p['users'] : null);
              final nama = (u is Map ? (u['nama'] ?? '-') : '-');
              final email = (u is Map ? (u['email'] ?? '-') : '-');

              return Card(
                child: ListTile(
                  title: Text(
                    "$kode • ${r['kondisi'] ?? '-'}",
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    "User: $nama ($email)\n"
                    "Tgl real: ${r['tanggal_kembali_real'] ?? '-'}\n"
                    "Terlambat: ${r['terlambat'] ?? 0} hari | Denda: Rp ${r['denda'] ?? 0}",
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') openForm(row: r);
                      if (v == 'hapus') confirmDelete(r);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text("Edit")),
                      PopupMenuItem(value: 'hapus', child: Text("Hapus")),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
