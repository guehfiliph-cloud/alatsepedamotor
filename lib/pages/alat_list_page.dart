import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlatListPage extends StatefulWidget {
  const AlatListPage({super.key});

  @override
  State<AlatListPage> createState() => _AlatListPageState();
}

class _AlatListPageState extends State<AlatListPage> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _futureAlat;

  @override
  void initState() {
    super.initState();
    _futureAlat = fetchAlat();
  }

  void refresh() {
    setState(() {
      _futureAlat = fetchAlat();
    });
  }

  // ✅ Join kategori berdasarkan kategori_id
  Future<List<Map<String, dynamic>>> fetchAlat() async {
    final res = await supabase
        .from('alat_sepeda_motor')
        .select(
          'id, nama_alat, stok, kategori_id, kategori:kategori_id(id, nama_kategori)',
        )
        .order('nama_alat', ascending: true);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchKategori() async {
    final res = await supabase
        .from('kategori')
        .select('id, nama_kategori')
        .order('nama_kategori', ascending: true);

    return List<Map<String, dynamic>>.from(res);
  }

  // === CRUD ===
  Future<void> tambahAlat({
    required String namaAlat,
    required int stok,
    required int kategoriId,
  }) async {
    await supabase.from('alat_sepeda_motor').insert({
      'nama_alat': namaAlat,
      'stok': stok,
      'kategori_id': kategoriId,
    });
  }

  Future<void> editAlat({
    required int id,
    required String namaAlat,
    required int stok,
    required int kategoriId,
  }) async {
    await supabase
        .from('alat_sepeda_motor')
        .update({
          'nama_alat': namaAlat,
          'stok': stok,
          'kategori_id': kategoriId,
        })
        .eq('id', id);
  }

  Future<void> hapusAlat(int id) async {
    await supabase.from('alat_sepeda_motor').delete().eq('id', id);
  }

  Color stokColor(int stok) => stok > 0 ? Colors.green : Colors.red;
  String stokLabel(int stok) => stok > 0 ? "Tersedia" : "Habis";

  // Form tambah/edit
  Future<void> openForm({Map<String, dynamic>? alat}) async {
    final isEdit = alat != null;

    final namaCtrl = TextEditingController(
      text: (alat?['nama_alat'] ?? '').toString(),
    );
    final stokCtrl = TextEditingController(
      text: (alat?['stok'] ?? 0).toString(),
    );

    int? selectedKategoriId = (alat?['kategori_id'] is int)
        ? alat!['kategori_id'] as int
        : null;

    final kategoriList = await fetchKategori();
    if (!mounted) return;

    if (selectedKategoriId == null && kategoriList.isNotEmpty) {
      selectedKategoriId = kategoriList.first['id'] as int;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit Alat" : "Tambah Alat"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: namaCtrl,
                decoration: const InputDecoration(
                  labelText: "Nama Alat",
                  prefixIcon: Icon(Icons.construction),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stokCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Stok",
                  prefixIcon: Icon(Icons.inventory_2),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: selectedKategoriId,
                decoration: const InputDecoration(
                  labelText: "Kategori",
                  prefixIcon: Icon(Icons.category),
                ),
                items: kategoriList.map((k) {
                  return DropdownMenuItem<int>(
                    value: k['id'] as int,
                    child: Text((k['nama_kategori'] ?? '-').toString()),
                  );
                }).toList(),
                onChanged: (v) => selectedKategoriId = v,
              ),
            ],
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
    );

    if (ok == true) {
      final nama = namaCtrl.text.trim();
      final stok = int.tryParse(stokCtrl.text.trim()) ?? 0;
      final kategoriId = selectedKategoriId;

      if (nama.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nama alat tidak boleh kosong")),
        );
        return;
      }

      if (kategoriId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Kategori harus dipilih")));
        return;
      }

      try {
        if (isEdit) {
          await editAlat(
            id: alat['id'] as int,
            namaAlat: nama,
            stok: stok,
            kategoriId: kategoriId,
          );
        } else {
          await tambahAlat(namaAlat: nama, stok: stok, kategoriId: kategoriId);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit ? "Alat berhasil diubah" : "Alat berhasil ditambahkan",
            ),
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
  }

  Future<void> confirmHapus(Map<String, dynamic> alat) async {
    final id = alat['id'] as int;
    final nama = (alat['nama_alat'] ?? '-').toString();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Alat"),
        content: Text("Yakin hapus alat: $nama ?"),
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

    if (ok == true) {
      try {
        await hapusAlat(id);
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Alat berhasil dihapus")));
        refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal hapus: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text('Data Alat'),
        backgroundColor: const Color(0xFFB91C1C),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB91C1C),
        onPressed: () => openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureAlat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('Data alat masih kosong'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alat = data[index];

              final namaAlat = (alat['nama_alat'] ?? '-').toString();
              final stok = (alat['stok'] ?? 0) as int;

              String namaKategori = '-';
              final kategoriObj = alat['kategori'];
              if (kategoriObj is Map<String, dynamic>) {
                namaKategori = (kategoriObj['nama_kategori'] ?? '-').toString();
              }

              // ✅ INI yang kamu mau: Card custom (tidak overflow)
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFDC2626),
                        child: Icon(Icons.motorcycle, color: Colors.white),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              namaAlat,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Kategori: $namaKategori'),
                            const SizedBox(height: 4),
                            Text('Stok: $stok'),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: stokColor(stok).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: stokColor(stok),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  stokLabel(stok),
                                  style: TextStyle(
                                    color: stokColor(stok),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: "Edit",
                                icon: const Icon(Icons.edit, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => openForm(alat: alat),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                tooltip: "Hapus",
                                icon: const Icon(Icons.delete, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => confirmHapus(alat),
                              ),
                            ],
                          ),
                        ],
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
