import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/storage_service.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final supabase = Supabase.instance.client;
  final storage = StorageService();
  final picker = ImagePicker();

  final namaCtrl = TextEditingController();
  final hpCtrl = TextEditingController();

  bool loading = true;
  File? selectedImage;
  String? fotoUrl;

  @override
  void initState() {
    super.initState();
    _loadusers();
  }

  Future<void> _loadusers() async {
    setState(() => loading = true);

    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('users')
        .select('nama,no_hp,foto_url')
        .eq('id', user.id)
        .maybeSingle();

    if (!mounted) return;

    namaCtrl.text = (data?['nama'] ?? '').toString();
    hpCtrl.text = (data?['no_hp'] ?? '').toString();
    fotoUrl = (data?['foto_url'] ?? '').toString();

    setState(() => loading = false);
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() {
      selectedImage = File(picked.path);
    });
  }

  Future<void> _save() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final nama = namaCtrl.text.trim();
    final hp = hpCtrl.text.trim();

    if (nama.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nama tidak boleh kosong")));
      return;
    }

    try {
      // 1) upload foto kalau dipilih
      String? newUrl = fotoUrl;
      if (selectedImage != null) {
        newUrl = await storage.uploadUserPhoto(selectedImage!, user.id);
      }

      // 2) update tabel users
      await supabase
          .from('users')
          .update({'nama': nama, 'no_hp': hp, 'foto_url': newUrl})
          .eq('id', user.id);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profil berhasil disimpan")));

      setState(() {
        fotoUrl = newUrl;
        selectedImage = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal simpan: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: const Color(0xFFB91C1C),
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 96,
                            height: 96,
                            color: const Color(0xFFF3F4F6),
                            child: selectedImage != null
                                ? Image.file(selectedImage!, fit: BoxFit.cover)
                                : (fotoUrl != null && fotoUrl!.isNotEmpty)
                                ? Image.network(
                                    fotoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        const Icon(Icons.person, size: 44),
                                  )
                                : const Icon(Icons.person, size: 44),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image_outlined),
                        label: const Text("Ganti Foto"),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: namaCtrl,
                        decoration: const InputDecoration(
                          labelText: "Nama",
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: hpCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "No HP",
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB91C1C),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _save,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text("Simpan"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
