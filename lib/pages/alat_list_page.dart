import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/admin_section_header.dart';
import '../services/storage_service.dart';

class AlatListPage extends StatefulWidget {
  const AlatListPage({super.key});

  @override
  State<AlatListPage> createState() => _AlatListPageState();
}

class _AlatListPageState extends State<AlatListPage> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _futureAlat;

  final ImagePicker _picker = ImagePicker();
  final StorageService _storage = StorageService();

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

  // ✅ Join kategori + ambil foto_url
  Future<List<Map<String, dynamic>>> fetchAlat() async {
    final res = await supabase
        .from('alat_sepeda_motor')
        .select(
          'id, nama_alat, stok, kategori_id, foto_url, kategori:kategori_id(id, nama_kategori)',
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

  // ✅ picker aman web + android (pakai XFile)
  Future<XFile?> _pickImage() async {
    return _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
  }

  // ✅ widget preview aman (web pakai Image.network untuk file lokal, mobile pakai Image.file via bytes)
  Widget _previewPickedImage(XFile file) {
    if (kIsWeb) {
      // di Web: XFile.path adalah blob URL, bisa langsung Image.network
      return Image.network(
        file.path,
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    // di Android/iOS: aman pakai Image.file lewat bytes (tanpa dart:io)
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const SizedBox(
            height: 140,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Image.memory(
          snap.data!,
          height: 140,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
  }

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

    final String? oldImageUrl = (alat?['foto_url'] == null)
        ? null
        : alat!['foto_url'].toString();

    XFile? selectedImage;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(isEdit ? "Edit Alat" : "Tambah Alat"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.image_outlined),
                          label: Text(isEdit ? "Ganti Gambar" : "Pilih Gambar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB91C1C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            final xfile = await _pickImage();
                            if (xfile == null) return;
                            setStateDialog(() => selectedImage = xfile);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (selectedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: _previewPickedImage(selectedImage!),
                    )
                  else if (oldImageUrl != null && oldImageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        oldImageUrl,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 140,
                          alignment: Alignment.center,
                          color: const Color(0xFFF3F4F6),
                          child: const Text("Gagal memuat gambar"),
                        ),
                      ),
                    ),

                  if (selectedImage != null ||
                      (oldImageUrl != null && oldImageUrl.isNotEmpty))
                    const SizedBox(height: 12),

                  TextField(
                    controller: namaCtrl,
                    decoration: InputDecoration(
                      labelText: "Nama Alat",
                      prefixIcon: const Icon(Icons.construction),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: stokCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Stok",
                      prefixIcon: const Icon(Icons.inventory_2),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: selectedKategoriId,
                    decoration: InputDecoration(
                      labelText: "Kategori",
                      prefixIcon: const Icon(Icons.category),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: kategoriList.map((k) {
                      return DropdownMenuItem<int>(
                        value: k['id'] as int,
                        child: Text(
                          (k['nama_kategori'] ?? '-').toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => selectedKategoriId = v,
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

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
        final id = alat['id'] as int;

        await editAlat(
          id: id,
          namaAlat: nama,
          stok: stok,
          kategoriId: kategoriId,
        );

        if (selectedImage != null) {
          final url = await _uploadImageForAlat(selectedImage!, id);
          await supabase
              .from('alat_sepeda_motor')
              .update({'foto_url': url})
              .eq('id', id);
        }
      } else {
        final inserted = await supabase
            .from('alat_sepeda_motor')
            .insert({
              'nama_alat': nama,
              'stok': stok,
              'kategori_id': kategoriId,
            })
            .select()
            .single();

        final alatId = inserted['id'] as int;

        if (selectedImage != null) {
          final url = await _uploadImageForAlat(selectedImage!, alatId);
          await supabase
              .from('alat_sepeda_motor')
              .update({'foto_url': url})
              .eq('id', alatId);
        }
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

  // ✅ upload aman web+android
  Future<String> _uploadImageForAlat(XFile picked, int alatId) async {
    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      // butuh fungsi bytes di StorageService
      return _storage.uploadAlatImageBytes(bytes, alatId, picked.name);
    } else {
      // mobile: masih boleh pakai path (kalau StorageService kamu butuh File, ubah StorageService jadi terima path/bytes)
      final bytes = await picked.readAsBytes();
      return _storage.uploadAlatImageBytes(bytes, alatId, picked.name);
    }
  }

  Future<void> confirmHapus(Map<String, dynamic> alat) async {
    final id = alat['id'] as int;
    final nama = (alat['nama_alat'] ?? '-').toString();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Hapus Alat"),
        content: Text("Yakin hapus alat: $nama ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB91C1C),
        onPressed: () => openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          AdminSectionHeader(
            title: "Data Alat",
            subtitle: "Kelola alat & stok",
            icon: Icons.build_rounded,
            onAction: refresh,
            actionIcon: Icons.refresh_rounded,
            actionTooltip: "Refresh",
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureAlat,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Terjadi error: ${snapshot.error}'),
                  );
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
                    final imageUrl = (alat['foto_url'] ?? '').toString();

                    String namaKategori = '-';
                    final kategoriObj = alat['kategori'];
                    if (kategoriObj is Map<String, dynamic>) {
                      namaKategori = (kategoriObj['nama_kategori'] ?? '-')
                          .toString();
                    }

                    return Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFB91C1C),
                                      Color(0xFFEF4444),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.motorcycle_rounded,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.motorcycle_rounded,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    namaAlat,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Kategori: $namaKategori',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Stok: $stok',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: stokColor(
                                      stok,
                                    ).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: stokColor(
                                        stok,
                                      ).withValues(alpha: 0.22),
                                    ),
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
                                          fontWeight: FontWeight.w800,
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
          ),
        ],
      ),
    );
  }
}
