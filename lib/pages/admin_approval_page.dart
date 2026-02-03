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

  // ==============================
  // UI Helper: badge role
  // ==============================
  Widget _roleBadge(String role) {
    Color bg;
    Color fg;
    String label = role;

    if (role == 'admin') {
      bg = const Color(0xFFB91C1C).withValues(alpha: 0.10);
      fg = const Color(0xFFB91C1C);
      label = 'Admin';
    } else if (role == 'petugas') {
      bg = const Color(0xFF2563EB).withValues(alpha: 0.10);
      fg = const Color(0xFF2563EB);
      label = 'Petugas';
    } else {
      bg = const Color(0xFF6B7280).withValues(alpha: 0.10);
      fg = const Color(0xFF6B7280);
      label = role;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }

  // ==============================
  // UI Helper: action button
  // ==============================
  Widget _actionBtn({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TANPA APPBAR (biar gak dobel), header custom aja
      backgroundColor: const Color(0xFFF7F7F8),
      body: Column(
        children: [
          // HEADER (lebih premium)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 18,
                  color: Colors.black12,
                  offset: Offset(0, 10),
                ),
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
            ),
            child: Stack(
              children: [
                // soft blobs biar ga flat
                Positioned(
                  right: -55,
                  top: -65,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB91C1C).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Positioned(
                  left: -50,
                  bottom: -80,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Persetujuan Akun Pending",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Setujui atau tolak akun admin/petugas",
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB91C1C).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(
                            0xFFB91C1C,
                          ).withValues(alpha: 0.14),
                        ),
                      ),
                      child: IconButton(
                        tooltip: "Refresh",
                        onPressed: fetchPendingUsers,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ISI HALAMAN
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : pendingUsers.isEmpty
                ? Center(
                    child: Container(
                      margin: const EdgeInsets.all(16),
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_rounded, color: Colors.black54),
                          SizedBox(width: 10),
                          Text(
                            "Tidak ada akun pending",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pendingUsers.length,
                    itemBuilder: (context, index) {
                      final user = pendingUsers[index];

                      final nama = (user['nama'] ?? '-').toString();
                      final email = (user['email'] ?? '-').toString();
                      final role = (user['role'] ?? '-').toString();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 18,
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
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.black54,
                                ),
                              ),
                              title: Text(
                                nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      email,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _roleBadge(role),
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _actionBtn(
                                    icon: Icons.check_rounded,
                                    tooltip: "Setujui",
                                    color: const Color(0xFF16A34A),
                                    onTap: () =>
                                        approveUser(user['id'].toString()),
                                  ),
                                  const SizedBox(width: 10),
                                  _actionBtn(
                                    icon: Icons.close_rounded,
                                    tooltip: "Tolak",
                                    color: const Color(0xFFDC2626),
                                    onTap: () =>
                                        rejectUser(user['id'].toString()),
                                  ),
                                ],
                              ),
                            ),
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
