import 'package:flutter/material.dart';

class BuatPeminjamanPage extends StatelessWidget {
  const BuatPeminjamanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),

      // ✅ APPBAR dibuat lebih modern (fungsi tetap sama: hanya judul)
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Buat Peminjaman',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7F1D1D), Color(0xFFEF4444)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                color: Colors.black12,
                offset: Offset(0, 8),
              ),
            ],
          ),
        ),
      ),

      // ✅ BODY tetap Center + Text, cuma dibungkus card biar menarik
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(18),
          padding: const EdgeInsets.all(18),
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                color: Colors.black.withValues(alpha: 0.06),
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_rounded, color: Color(0xFFB91C1C)),
              SizedBox(width: 10),
              Text(
                'Form Peminjaman',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
