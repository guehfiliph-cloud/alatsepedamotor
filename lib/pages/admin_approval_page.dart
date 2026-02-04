import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminApprovalPage extends StatefulWidget {
  const AdminApprovalPage({super.key});

  @override
  State<AdminApprovalPage> createState() => _AdminApprovalPageState();
}

class _AdminApprovalPageState extends State<AdminApprovalPage> {
  final supabase = Supabase.instance.client;

  // PERBAIKAN: Query diarahkan ke tabel 'users'
  Future<List<Map<String, dynamic>>> _fetchPendingUsers() async {
    try {
      final data = await supabase
          .from('users')
          .select()
          .eq('status_akun', 'pending')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  Future<void> _handleApproval(String id, String newStatus) async {
    try {
      await supabase
          .from('users')
          .update({'status_akun': newStatus})
          .eq('id', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Berhasil: Akun telah di-$newStatus")),
        );
        setState(() {}); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memproses: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Persetujuan Akun")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPendingUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(
              child: Text("Tidak ada akun menunggu persetujuan"),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                child: ListTile(
                  title: Text(user['nama'] ?? 'Tanpa Nama'),
                  subtitle: Text("${user['email']}\nRole: ${user['role']}"),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        onPressed: () => _handleApproval(user['id'], 'aktif'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _handleApproval(user['id'], 'ditolak'),
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
