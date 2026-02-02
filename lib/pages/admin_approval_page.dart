import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminApprovalPage extends StatefulWidget {
  const AdminApprovalPage({super.key});

  @override
  State<AdminApprovalPage> createState() => _AdminApprovalPageState();
}

class _AdminApprovalPageState extends State<AdminApprovalPage> {
  final SupabaseClient _sb = Supabase.instance.client;

  List<dynamic> pendingUsers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingUsers();
  }

  // ==============================
  // AMBIL USER PENDING
  // ==============================
  Future<void> fetchPendingUsers() async {
    setState(() => loading = true);

    final data = await _sb
        .from('users')
        .select('id,nama,email,role,status_akun')
        .eq('status_akun', 'pending')
        .order('nama');

    if (!mounted) return;

    setState(() {
      pendingUsers = data;
      loading = false;
    });
  }

  // ==============================
  // APPROVE USER
  // ==============================
  Future<void> approveUser(String userId) async {
    await _sb.from('users').update({'status_akun': 'aktif'}).eq('id', userId);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("User berhasil disetujui")));

    fetchPendingUsers();
  }

  // ==============================
  // REJECT USER
  // ==============================
  Future<void> rejectUser(String userId) async {
    await _sb.from('users').update({'status_akun': 'ditolak'}).eq('id', userId);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("User ditolak")));

    fetchPendingUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TANPA APPBAR (biar gak dobel), header custom aja
      body: Column(
        children: [
          // HEADER PUTIH
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_user, color: Color(0xFFB91C1C)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Persetujuan Akun Pending",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Setujui atau tolak akun admin/petugas",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ISI HALAMAN
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : pendingUsers.isEmpty
                ? const Center(
                    child: Text(
                      "Tidak ada akun pending",
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pendingUsers.length,
                    itemBuilder: (context, index) {
                      final user = pendingUsers[index];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            user['nama'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${user['email']} | Role: ${user['role']}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                onPressed: () =>
                                    approveUser(user['id'].toString()),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    rejectUser(user['id'].toString()),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
