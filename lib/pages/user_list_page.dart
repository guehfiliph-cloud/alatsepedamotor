import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final supabase = Supabase.instance.client;

  // refresh trigger
  late Future<List<Map<String, dynamic>>> _futureUsers;

  // profil yang sedang login
  late Future<Map<String, dynamic>?> _futureProfilLogin;

  @override
  void initState() {
    super.initState();
    _futureUsers = fetchUsers();
    _futureProfilLogin = fetchProfilLogin();
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final res = await supabase
        .from('users')
        .select('*')
        .order('nama', ascending: true);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<Map<String, dynamic>?> fetchProfilLogin() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    // ambil profil dari tabel users sesuai id auth
    final data = await supabase
        .from('users')
        .select('id, nama, email, role, status')
        .eq('id', user.id)
        .maybeSingle();

    return data;
  }

  void refresh() {
    setState(() {
      _futureUsers = fetchUsers();
      _futureProfilLogin = fetchProfilLogin();
    });
  }

  // ==========================
  // CREATE
  // ==========================
  Future<void> createUser({
    required String nama,
    required String email,
    String? noHp,
    String? role,
    String? status,
  }) async {
    await supabase.from('users').insert({
      'nama': nama,
      'email': email,
      if (noHp != null) 'no_hp': noHp,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
    });
  }

  // ==========================
  // UPDATE
  // ==========================
  Future<void> updateUser({
    required String id,
    required String nama,
    required String email,
    String? noHp,
    String? role,
    String? status,
  }) async {
    await supabase
        .from('users')
        .update({
          'nama': nama,
          'email': email,
          'no_hp': noHp,
          'role': role,
          'status': status,
        })
        .eq('id', id);
  }

  // ==========================
  // DELETE
  // ==========================
  Future<void> deleteUser(String id) async {
    await supabase.from('users').delete().eq('id', id);
  }

  // ==========================
  // UI: Dialog Add/Edit
  // ==========================
  Future<void> openUserForm({Map<String, dynamic>? user}) async {
    final namaCtrl = TextEditingController(
      text: user?['nama']?.toString() ?? '',
    );
    final emailCtrl = TextEditingController(
      text: user?['email']?.toString() ?? '',
    );
    final noHpCtrl = TextEditingController(
      text: user?['no_hp']?.toString() ?? '',
    );

    String role = (user?['role']?.toString() ?? 'peminjam');
    String status = (user?['status']?.toString() ?? 'approved');

    final isEdit = user != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit User" : "Tambah User"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: namaCtrl,
                decoration: const InputDecoration(labelText: "Nama"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noHpCtrl,
                decoration: const InputDecoration(labelText: "No HP"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: role,
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('admin')),
                  DropdownMenuItem(value: 'petugas', child: Text('petugas')),
                  DropdownMenuItem(value: 'peminjam', child: Text('peminjam')),
                ],
                onChanged: (v) => role = v ?? role,
                decoration: const InputDecoration(labelText: "Role"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: status,
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('menunggu')),
                  DropdownMenuItem(
                    value: 'approved',
                    child: Text('di setujui'),
                  ),
                  DropdownMenuItem(value: 'rejected', child: Text('ditolak')),
                ],
                onChanged: (v) => status = v ?? status,
                decoration: const InputDecoration(labelText: "Status"),
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
            onPressed: () async {
              final nama = namaCtrl.text.trim();
              final email = emailCtrl.text.trim();
              final noHp = noHpCtrl.text.trim();

              if (nama.isEmpty || email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Nama & Email wajib diisi")),
                );
                return;
              }

              try {
                if (isEdit) {
                  await updateUser(
                    id: user['id'].toString(),
                    nama: nama,
                    email: email,
                    noHp: noHp.isEmpty ? null : noHp,
                    role: role,
                    status: status,
                  );
                } else {
                  await createUser(
                    nama: nama,
                    email: email,
                    noHp: noHp.isEmpty ? null : noHp,
                    role: role,
                    status: status,
                  );
                }

                if (!mounted) return;
                Navigator.pop(context, true);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
              }
            },
            child: Text(isEdit ? "Simpan" : "Tambah"),
          ),
        ],
      ),
    );

    if (result == true) refresh();
  }

  Future<void> confirmDelete(Map<String, dynamic> user) async {
    final nama = user['nama']?.toString() ?? '-';
    final id = user['id']?.toString() ?? '';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus User"),
        content: Text("Yakin hapus user: $nama ?"),
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
        await deleteUser(id);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User berhasil dihapus")));
        refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal hapus: $e")));
      }
    }
  }

  // ==========================
  // HEADER PROFIL LOGIN
  // ==========================
  Widget profilHeader(Map<String, dynamic>? p) {
    final String nama = (p?['nama'] ?? '-').toString();
    final String email = (p?['email'] ?? '-').toString();
    final String role = (p?['role'] ?? '-').toString();
    final String status = (p?['status'] ?? '-').toString();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 22, child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(Icons.badge, "Role: $role"),
                    _chip(Icons.verified_user, "Status: $status"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola User"),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Tambah User",
        onPressed: () => openUserForm(),
        child: const Icon(Icons.add),
      ),

      // ✅ BODY: profil + list user
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _futureProfilLogin,
        builder: (context, profSnap) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _futureUsers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final users = snapshot.data ?? [];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // header profil login
                  profilHeader(profSnap.data),
                  const SizedBox(height: 14),

                  if (users.isEmpty)
                    const Center(child: Text("Data user belum ada."))
                  else
                    ...users.map((u) {
                      final nama = (u['nama'] ?? '-') as String;
                      final email = (u['email'] ?? '-') as String;
                      final role = (u['role'] ?? '-')?.toString();
                      final status = (u['status'] ?? '-')?.toString();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(nama),
                            subtitle: Text(email),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                if (role != null || status != null)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        role ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(status ?? ''),
                                    ],
                                  ),
                                IconButton(
                                  tooltip: "Edit",
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => openUserForm(user: u),
                                ),
                                IconButton(
                                  tooltip: "Hapus",
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => confirmDelete(u),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
