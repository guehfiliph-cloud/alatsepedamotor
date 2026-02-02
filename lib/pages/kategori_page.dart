import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _futureKategori;

  @override
  void initState() {
    super.initState();
    _futureKategori = fetchKategori();
  }

  Future<List<Map<String, dynamic>>> fetchKategori() async {
    final res = await supabase
        .from('kategori')
        .select('*')
        .order('nama_kategori', ascending: true);

    return List<Map<String, dynamic>>.from(res);
  }

  void refresh() {
    setState(() {
      _futureKategori = fetchKategori();
    });
  }

  Future<void> tambahKategori(String namaKategori) async {
    await supabase.from('kategori').insert({'nama_kategori': namaKategori});
  }

  Future<void> editKategori(int id, String namaKategori) async {
    await supabase
        .from('kategori')
        .update({'nama_kategori': namaKategori})
        .eq('id', id);
  }

  Future<void> hapusKategori(int id) async {
    await supabase.from('kategori').delete().eq('id', id);
  }

  // ✅ CEK: kategori dipakai berapa alat di tabel alat_sepeda_motor
  Future<int> cekKategoriDipakai(int kategoriId) async {
    final res = await supabase
        .from('alat_sepeda_motor')
        .select('id')
        .eq('kategori_id', kategoriId);

    final list = List<Map<String, dynamic>>.from(res);
    return list.length;
  }

  Future<void> dialogTambah() async {
    final ctrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Kategori"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: "Nama kategori"),
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
      final nama = ctrl.text.trim();
      if (nama.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nama kategori tidak boleh kosong")),
        );
        return;
      }

      try {
        await tambahKategori(nama);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kategori berhasil ditambahkan")),
        );
        refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal tambah: $e")));
      }
    }
  }

  Future<void> dialogEdit(Map<String, dynamic> kat) async {
    final id = kat['id'] as int;
    final ctrl = TextEditingController(
      text: (kat['nama_kategori'] ?? '').toString(),
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Kategori"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: "Nama kategori"),
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
      final nama = ctrl.text.trim();
      if (nama.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nama kategori tidak boleh kosong")),
        );
        return;
      }

      try {
        await editKategori(id, nama);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kategori berhasil diubah")),
        );
        refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal edit: $e")));
      }
    }
  }

  Future<void> dialogHapus(Map<String, dynamic> kat) async {
    final id = kat['id'] as int;
    final nama = (kat['nama_kategori'] ?? '-').toString();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Kategori"),
        content: Text("Yakin hapus kategori: $nama ?"),
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
        // ✅ CEK dulu apakah kategori masih dipakai
        final dipakai = await cekKategoriDipakai(id);

        if (!mounted) return;

        if (dipakai > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Tidak bisa dihapus. Kategori ini masih digunakan oleh $dipakai alat.",
              ),
            ),
          );
          return;
        }

        // ✅ Kalau tidak dipakai, baru hapus
        await hapusKategori(id);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kategori berhasil dihapus")),
        );
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

      // ✅ AppBar DIHAPUS (biar tidak dobel dengan Dashboard Admin)
      floatingActionButton: FloatingActionButton(
        onPressed: dialogTambah,
        tooltip: "Tambah Kategori",
        backgroundColor: const Color(0xFFB91C1C),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          // ✅ HEADER PUTIH RAPI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: Colors.black12,
                  offset: Offset(0, 2),
                ),
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.category, color: Color(0xFFB91C1C)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Kelola Kategori",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: "Refresh",
                  onPressed: refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),

          // ✅ LIST KATEGORI
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureKategori,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Center(child: Text("Belum ada kategori."));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final kat = data[i];
                    final nama = (kat['nama_kategori'] ?? '-').toString();

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFDC2626),
                          child: Icon(Icons.category, color: Colors.white),
                        ),
                        title: Text(
                          nama,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              tooltip: "Edit",
                              icon: const Icon(Icons.edit),
                              onPressed: () => dialogEdit(kat),
                            ),
                            IconButton(
                              tooltip: "Hapus",
                              icon: const Icon(Icons.delete),
                              onPressed: () => dialogHapus(kat),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
