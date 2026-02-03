import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final supabase = Supabase.instance.client;

  // ==========================
  // FUTURE untuk trigger refresh (list users)
  // ==========================
  late Future<List<Map<String, dynamic>>> _futureUsers;

  // ==========================
  // FUTURE untuk data profil user yang sedang login
  // ==========================
  late Future<Map<String, dynamic>?> _futureProfilLogin;

  @override
  void initState() {
    super.initState();
    // inisialisasi data saat pertama kali halaman dibuka
    _futureUsers = fetchUsers();
    _futureProfilLogin = fetchProfilLogin();
  }

  // ==========================
  // READ: ambil list user
  // ==========================
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final res = await supabase
        .from('users')
        .select('*')
        .order('nama', ascending: true);

    return List<Map<String, dynamic>>.from(res);
  }

  // ==========================
  // READ: ambil profil user login (berdasarkan auth.currentUser.id)
  // ==========================
  Future<Map<String, dynamic>?> fetchProfilLogin() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    // NOTE:
    // Kalau kolom status kamu sebenarnya "status_akun",
    // ganti select(...) jadi: select('id, nama, email, role, status_akun')
    final data = await supabase
        .from('users')
        .select('id, nama, email, role, status')
        .eq('id', user.id)
        .maybeSingle();

    return data;
  }

  // ==========================
  // Refresh ulang list + profil
  // ==========================
  void refresh() {
    setState(() {
      _futureUsers = fetchUsers();
      _futureProfilLogin = fetchProfilLogin();
    });
  }

  // ==========================
  // CREATE: tambah user baru
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
  // UPDATE: edit user
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
  // DELETE: hapus user
  // ==========================
  Future<void> deleteUser(String id) async {
    await supabase.from('users').delete().eq('id', id);
  }

  // ==========================
  // UI: Dialog Add/Edit User
  // ==========================
  Future<void> openUserForm({Map<String, dynamic>? user}) async {
    // controller untuk input
    final namaCtrl = TextEditingController(
      text: user?['nama']?.toString() ?? '',
    );
    final emailCtrl = TextEditingController(
      text: user?['email']?.toString() ?? '',
    );
    final noHpCtrl = TextEditingController(
      text: user?['no_hp']?.toString() ?? '',
    );

    // default value dropdown
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
              // ambil value input
              final nama = namaCtrl.text.trim();
              final email = emailCtrl.text.trim();
              final noHp = noHpCtrl.text.trim();

              // validasi minimal
              if (nama.isEmpty || email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Nama & Email wajib diisi")),
                );
                return;
              }

              try {
                // edit vs tambah
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

    // kalau dialog sukses (true) => refresh list
    if (result == true) refresh();
  }

  // ==========================
  // Konfirmasi hapus user
  // ==========================
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
  // HEADER: profil user login
  // ==========================
  Widget profilHeader(Map<String, dynamic>? p) {
    final String nama = (p?['nama'] ?? '-').toString();
    final String email = (p?['email'] ?? '-').toString();
    final String role = (p?['role'] ?? '-').toString();

    // NOTE:
    // Kalau kolom status kamu "status_akun", ganti p?['status'] -> p?['status_akun']
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
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFF3E8FF),
            child: Icon(Icons.person, color: Color(0xFF6D28D9)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
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

  // ==========================
  // Chip kecil untuk Role/Status (profil login)
  // ==========================
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
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // background halaman
      backgroundColor: const Color(0xFFE3F2FD),

      // tombol tambah user
      floatingActionButton: FloatingActionButton(
        tooltip: "Tambah User",
        onPressed: () => openUserForm(),
        backgroundColor: const Color(0xFFB91C1C),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          // ==========================
          // HEADER PUTIH (tanpa AppBar)
          // ==========================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
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
                const Icon(Icons.people, color: Color(0xFFB91C1C)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Kelola User",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                // tombol refresh data
                IconButton(
                  tooltip: "Refresh",
                  onPressed: refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),

          // ==========================
          // BODY: profil login + list user
          // ==========================
          Expanded(
            child: FutureBuilder<Map<String, dynamic>?>(
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
                        // card profil user login (bagian atas)
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
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Card(
                                elevation: 1, // lebih tipis
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ListTile(
                                  // ==========================
                                  // ✅ BAGIAN INI YANG BUAT "USER LEBIH KECIL"
                                  // ==========================
                                  dense: true, // membuat ListTile lebih rapat
                                  visualDensity: const VisualDensity(
                                    vertical: -2, // makin minus = makin rapat
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),

                                  // avatar lebih kecil
                                  leading: const CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Color(0xFFF3F4F6),
                                    child: Icon(Icons.person, size: 18),
                                  ),

                                  // nama lebih kecil + 1 baris
                                  title: Text(
                                    nama,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),

                                  // email lebih kecil + 1 baris
                                  subtitle: Text(
                                    email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),

                                  trailing: Wrap(
                                    spacing: 10,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      // kolom role + status dibuat kecil
                                      if (role != null || status != null)
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              role ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 11,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              status ?? '',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),

                                      // icon edit kecil + padding nol biar gak makan tempat
                                      IconButton(
                                        tooltip: "Edit",
                                        icon: const Icon(Icons.edit, size: 18),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => openUserForm(user: u),
                                      ),

                                      // icon delete kecil + padding nol biar rapat
                                      IconButton(
                                        tooltip: "Hapus",
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 18,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
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
          ),
        ],
      ),
    );
  }
}
