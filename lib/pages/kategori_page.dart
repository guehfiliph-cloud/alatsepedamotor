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

  InputDecoration _dec({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFB91C1C), width: 1.6),
      ),
    );
  }

  Future<void> dialogTambah() async {
    final ctrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Tambah Kategori"),
        content: TextField(
          controller: ctrl,
          decoration: _dec(
            label: "Nama kategori",
            icon: Icons.category_outlined,
            hint: "Contoh: Kunci, Obeng, dll",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Simpan"),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Edit Kategori"),
        content: TextField(
          controller: ctrl,
          decoration: _dec(label: "Nama kategori", icon: Icons.edit_outlined),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Simpan"),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Hapus Kategori"),
        content: Text("Yakin hapus kategori: $nama ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
      backgroundColor: const Color(0xFFEFF6FF),

      // ✅ AppBar DIHAPUS (biar tidak dobel dengan Dashboard Admin)
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              color: const Color(0xFFB91C1C).withValues(alpha: 0.22),
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: dialogTambah,
          tooltip: "Tambah Kategori",
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),

      body: Column(
        children: [
          // ✅ HEADER PUTIH RAPI (lebih “hidup”)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 14,
                  color: Colors.black12,
                  offset: Offset(0, 6),
                ),
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB91C1C).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFB91C1C).withValues(alpha: 0.14),
                    ),
                  ),
                  child: const Icon(
                    Icons.category_rounded,
                    color: Color(0xFFB91C1C),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kelola Kategori",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Tambah, edit, hapus kategori alat",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFB91C1C).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFB91C1C).withValues(alpha: 0.14),
                    ),
                  ),
                  child: IconButton(
                    tooltip: "Refresh",
                    onPressed: refresh,
                    icon: const Icon(Icons.refresh_rounded),
                    color: const Color(0xFFB91C1C),
                  ),
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

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 16,
                            color: Colors.black.withValues(alpha: 0.06),
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.category_rounded,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: const Text(
                          "",
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Wrap(
                          spacing: 6,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                tooltip: "Edit",
                                icon: const Icon(Icons.edit_rounded, size: 20),
                                onPressed: () => dialogEdit(kat),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFB91C1C,
                                ).withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                tooltip: "Hapus",
                                icon: const Icon(
                                  Icons.delete_rounded,
                                  size: 20,
                                ),
                                color: const Color(0xFFB91C1C),
                                onPressed: () => dialogHapus(kat),
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
          ),
        ],
      ),
    );
  }
}
