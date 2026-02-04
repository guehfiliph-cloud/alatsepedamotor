import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPeminjamanPage extends StatefulWidget {
  const AdminPeminjamanPage({super.key});

  @override
  State<AdminPeminjamanPage> createState() => _AdminPeminjamanPageState();
}

class _AdminPeminjamanPageState extends State<AdminPeminjamanPage> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _future;

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

  // ✅ PERBAIKAN: Query select tanpa spasi sebelum tanda kurung relasi
  Future<List<Map<String, dynamic>>> fetchData() async {
    try {
      final res = await supabase
          .from('peminjaman')
          .select('''
            id,
            kode_peminjaman,
            tanggal_pinjam,
            tanggal_kembali_rencana,
            total_harga,
            status,
            created_at,
            users:user_id(id, nama, email),
            alat_sepeda_motor:alat_id(id, nama_alat, stok)
          ''')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error Fetching Data: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final res = await supabase
        .from('users')
        .select('id, nama, email, role')
        .order('nama', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchAlat() async {
    final res = await supabase
        .from('alat_sepeda_motor')
        .select('id, nama_alat, stok')
        .order('nama_alat', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> insertRow({
    required String userId,
    required int alatId,
    required DateTime tglPinjam,
    required DateTime tglKembaliRencana,
    required int totalHarga,
    required String status,
  }) async {
    await supabase.from('peminjaman').insert({
      'user_id': userId,
      'alat_id': alatId,
      'tanggal_pinjam': _dateOnly(tglPinjam),
      'tanggal_kembali_rencana': _dateOnly(tglKembaliRencana),
      'total_harga': totalHarga,
      'status': status,
    });
  }

  Future<void> updateRow({
    required int id,
    required String userId,
    required int alatId,
    required DateTime tglPinjam,
    required DateTime tglKembaliRencana,
    required int totalHarga,
    required String status,
  }) async {
    await supabase
        .from('peminjaman')
        .update({
          'user_id': userId,
          'alat_id': alatId,
          'tanggal_pinjam': _dateOnly(tglPinjam),
          'tanggal_kembali_rencana': _dateOnly(tglKembaliRencana),
          'total_harga': totalHarga,
          'status': status,
        })
        .eq('id', id);
  }

  Future<void> deleteRow(int id) async {
    await supabase.from('peminjaman').delete().eq('id', id);
  }

  Future<void> openForm({Map<String, dynamic>? row}) async {
    final isEdit = row != null;

    final users = await fetchUsers();
    final alatList = await fetchAlat();
    if (!mounted) return;

    if (users.isEmpty || alatList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data users / alat kosong.")),
      );
      return;
    }

    String selectedUserId = users.first['id'].toString();
    int selectedAlatId = alatList.first['id'] as int;

    if (isEdit) {
      final u = row['users'];
      if (u is Map && u['id'] != null) selectedUserId = u['id'].toString();

      final a = row['alat_sepeda_motor'];
      if (a is Map && a['id'] != null) selectedAlatId = a['id'] as int;
    }

    DateTime tglPinjam = _parseDate(row?['tanggal_pinjam']) ?? DateTime.now();
    DateTime tglKembali =
        _parseDate(row?['tanggal_kembali_rencana']) ?? DateTime.now();

    final totalCtrl = TextEditingController(
      text: (row?['total_harga'] ?? 0).toString(),
    );

    String status = (row?['status'] ?? 'pending').toString();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setD) => AlertDialog(
          title: Text(isEdit ? "Edit Peminjaman" : "Tambah Peminjaman"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedUserId,
                    items: users.map((u) {
                      return DropdownMenuItem<String>(
                        value: u['id'].toString(),
                        child: Text(
                          "${u['nama'] ?? '-'} (${u['email'] ?? '-'})",
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        setD(() => selectedUserId = v ?? selectedUserId),
                    decoration: const InputDecoration(labelText: "User"),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: selectedAlatId,
                    items: alatList.map((a) {
                      return DropdownMenuItem<int>(
                        value: a['id'] as int,
                        child: Text(
                          "${a['nama_alat']} (stok: ${a['stok']})",
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        setD(() => selectedAlatId = v ?? selectedAlatId),
                    decoration: const InputDecoration(labelText: "Alat"),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Tanggal Pinjam"),
                    subtitle: Text(_dateOnly(tglPinjam)),
                    trailing: const Icon(Icons.date_range),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDate: tglPinjam,
                      );
                      if (picked != null) setD(() => tglPinjam = picked);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Tanggal Kembali (Rencana)"),
                    subtitle: Text(_dateOnly(tglKembali)),
                    trailing: const Icon(Icons.event_available),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDate: tglKembali,
                      );
                      if (picked != null) setD(() => tglKembali = picked);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: totalCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Total Harga",
                      prefixIcon: Icon(Icons.payments),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    items: const [
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text("pending"),
                      ),
                      DropdownMenuItem(
                        value: 'disetujui',
                        child: Text("disetujui"),
                      ),
                      DropdownMenuItem(
                        value: 'dipinjam',
                        child: Text("dipinjam"),
                      ),
                      DropdownMenuItem(
                        value: 'dikembalikan',
                        child: Text("dikembalikan"),
                      ),
                      DropdownMenuItem(
                        value: 'ditolak',
                        child: Text("ditolak"),
                      ),
                    ],
                    onChanged: (v) => setD(() => status = v ?? status),
                    decoration: const InputDecoration(labelText: "Status"),
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
      final total = int.tryParse(totalCtrl.text.trim()) ?? 0;

      if (isEdit) {
        await updateRow(
          id: row['id'] as int,
          userId: selectedUserId,
          alatId: selectedAlatId,
          tglPinjam: tglPinjam,
          tglKembaliRencana: tglKembali,
          totalHarga: total,
          status: status,
        );
      } else {
        await insertRow(
          userId: selectedUserId,
          alatId: selectedAlatId,
          tglPinjam: tglPinjam,
          tglKembaliRencana: tglKembali,
          totalHarga: total,
          status: status,
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
        title: const Text("Hapus Peminjaman"),
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
        title: const Text("Data Peminjaman"),
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
            return const Center(child: Text("Data peminjaman kosong"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final r = data[i];

              final user = r['users'];
              final alat = r['alat_sepeda_motor'];

              final namaUser = (user is Map ? (user['nama'] ?? '-') : '-');
              final emailUser = (user is Map ? (user['email'] ?? '-') : '-');
              final namaAlat = (alat is Map ? (alat['nama_alat'] ?? '-') : '-');

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    "${r['kode_peminjaman'] ?? 'PJ-?'} • ${r['status']?.toString().toUpperCase() ?? '-'}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "User: $namaUser ($emailUser)\n"
                      "Alat: $namaAlat\n"
                      "Pinjam: ${r['tanggal_pinjam'] ?? '-'} | Rencana: ${r['tanggal_kembali_rencana'] ?? '-'}\n"
                      "Total: Rp ${r['total_harga'] ?? 0}",
                      style: const TextStyle(height: 1.4),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') openForm(row: r);
                      if (v == 'hapus') confirmDelete(r);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text("Edit"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'hapus',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text("Hapus", style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
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
