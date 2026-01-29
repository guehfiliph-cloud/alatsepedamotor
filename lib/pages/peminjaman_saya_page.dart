import 'package:flutter/material.dart';

class PeminjamanSayaPage extends StatelessWidget {
  const PeminjamanSayaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peminjaman Saya')),
      body: const Center(child: Text('Daftar Peminjaman Saya')),
    );
  }
}
