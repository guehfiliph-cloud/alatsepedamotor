import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, Routes.login);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat datang!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('User: ${user?.email ?? '-'}'),
            const SizedBox(height: 16),

            Card(
              child: ListTile(
                title: const Text('Daftar Alat'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, Routes.alat),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Buat Peminjaman'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, Routes.buatPeminjaman),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Peminjaman Saya'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, Routes.peminjamanSaya),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Pengembalian'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, Routes.pengembalian),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
