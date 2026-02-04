import 'package:flutter/material.dart' as m;
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ tambah ini (biar bisa panggil Routes.xxx)
import '../routes.dart';

class DashboardRingkasanPage extends m.StatefulWidget {
  const DashboardRingkasanPage({super.key});

  @override
  m.State<DashboardRingkasanPage> createState() =>
      _DashboardRingkasanPageState();
}

class _DashboardRingkasanPageState extends m.State<DashboardRingkasanPage> {
  final supabase = Supabase.instance.client;

  late Future<Map<String, int>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, int>> _load() async {
    final alat = await supabase.from('alat_sepeda_motor').select('id');
    final kategori = await supabase.from('kategori').select('id');
    final users = await supabase.from('users').select('id');

    return {
      "alat": (alat as List).length,
      "kategori": (kategori as List).length,
      "users": (users as List).length,
    };
  }

  void refresh() {
    setState(() {
      _future = _load();
    });
  }

  @override
  m.Widget build(m.BuildContext context) {
    final now = DateTime.now();
    final hari = [
      "Minggu",
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jumat",
      "Sabtu",
    ][now.weekday % 7];

    return m.Container(
      decoration: const m.BoxDecoration(
        gradient: m.LinearGradient(
          begin: m.Alignment.topCenter,
          end: m.Alignment.bottomCenter,
          colors: [m.Color(0xFFF7F7F8), m.Color(0xFFF2F4F7)],
        ),
      ),
      child: m.FutureBuilder<Map<String, int>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != m.ConnectionState.done) {
            return const m.Center(child: m.CircularProgressIndicator());
          }
          if (snap.hasError) {
            return m.Center(child: m.Text("Error: ${snap.error}"));
          }

          final data = snap.data ?? {"alat": 0, "kategori": 0, "users": 0};

          return m.Column(
            children: [
              // ==========================
              // HEADER (RESPONSIVE, ANTI OVERFLOW)
              // ==========================
              m.SafeArea(
                bottom: false,
                child: m.Container(
                  width: double.infinity,
                  padding: const m.EdgeInsets.fromLTRB(18, 16, 18, 18),
                  decoration: const m.BoxDecoration(
                    color: m.Colors.white,
                    borderRadius: m.BorderRadius.only(
                      bottomLeft: m.Radius.circular(28),
                      bottomRight: m.Radius.circular(28),
                    ),
                    boxShadow: [
                      m.BoxShadow(
                        blurRadius: 20,
                        color: m.Colors.black12,
                        offset: m.Offset(0, 10),
                      ),
                    ],
                  ),
                  child: m.Stack(
                    children: [
                      // background soft blobs
                      m.Positioned(
                        right: -50,
                        top: -70,
                        child: m.Container(
                          width: 170,
                          height: 170,
                          decoration: m.BoxDecoration(
                            color: const m.Color(
                              0xFFB91C1C,
                            ).withValues(alpha: 0.06),
                            borderRadius: m.BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      m.Positioned(
                        left: -40,
                        bottom: -80,
                        child: m.Container(
                          width: 180,
                          height: 180,
                          decoration: m.BoxDecoration(
                            color: const m.Color(
                              0xFFEF4444,
                            ).withValues(alpha: 0.05),
                            borderRadius: m.BorderRadius.circular(999),
                          ),
                        ),
                      ),

                      // content
                      m.Column(
                        mainAxisSize: m.MainAxisSize.min,
                        children: [
                          m.Row(
                            crossAxisAlignment: m.CrossAxisAlignment.center,
                            children: [
                              m.Container(
                                width: 52,
                                height: 52,
                                decoration: m.BoxDecoration(
                                  color: const m.Color(0xFFF3F4F6),
                                  borderRadius: m.BorderRadius.circular(18),
                                ),
                                child: const m.Icon(
                                  m.Icons.dashboard_rounded,
                                  color: m.Color(0xFFB91C1C),
                                ),
                              ),
                              const m.SizedBox(width: 12),

                              // ✅ area text dibuat fleksibel agar tidak nabrak tombol refresh
                              m.Expanded(
                                child: m.Column(
                                  crossAxisAlignment:
                                      m.CrossAxisAlignment.start,
                                  children: [
                                    const m.Text(
                                      "Ringkasan",
                                      maxLines: 1,
                                      overflow: m.TextOverflow.ellipsis,
                                      style: m.TextStyle(
                                        fontSize: 20,
                                        fontWeight: m.FontWeight.w900,
                                        color: m.Colors.black,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const m.SizedBox(height: 6),

                                    // ✅ pakai Wrap supaya kalau sempit turun baris (anti overflow)
                                    m.Wrap(
                                      spacing: 10,
                                      runSpacing: 8,
                                      crossAxisAlignment:
                                          m.WrapCrossAlignment.center,
                                      children: [
                                        const m.Text(
                                          "Statistik data sistem",
                                          style: m.TextStyle(
                                            color: m.Colors.black54,
                                            fontWeight: m.FontWeight.w600,
                                          ),
                                        ),
                                        m.Container(
                                          padding: const m.EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: m.BoxDecoration(
                                            color: const m.Color(
                                              0xFFB91C1C,
                                            ).withValues(alpha: 0.08),
                                            borderRadius:
                                                m.BorderRadius.circular(999),
                                          ),
                                          child: m.Text(
                                            hari,
                                            maxLines: 1,
                                            overflow: m.TextOverflow.ellipsis,
                                            style: const m.TextStyle(
                                              color: m.Color(0xFFB91C1C),
                                              fontWeight: m.FontWeight.w800,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const m.SizedBox(width: 10),

                              // tombol refresh (tetap)
                              m.Container(
                                width: 44,
                                height: 44,
                                decoration: m.BoxDecoration(
                                  color: const m.Color(
                                    0xFFB91C1C,
                                  ).withValues(alpha: 0.08),
                                  borderRadius: m.BorderRadius.circular(14),
                                  border: m.Border.all(
                                    color: const m.Color(
                                      0xFFB91C1C,
                                    ).withValues(alpha: 0.14),
                                  ),
                                ),
                                child: m.IconButton(
                                  tooltip: "Refresh",
                                  onPressed: refresh,
                                  icon: const m.Icon(
                                    m.Icons.refresh_rounded,
                                    color: m.Color(0xFFB91C1C),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const m.SizedBox(height: 14),

                          // garis + tanggal
                          m.Container(
                            height: 1,
                            color: const m.Color(0xFFE5E7EB),
                          ),
                          const m.SizedBox(height: 10),
                          m.Row(
                            children: [
                              m.Icon(
                                m.Icons.calendar_month_rounded,
                                size: 16,
                                color: m.Colors.black.withValues(alpha: 0.45),
                              ),
                              const m.SizedBox(width: 8),
                              m.Text(
                                "${now.day}/${now.month}/${now.year}",
                                style: m.TextStyle(
                                  color: m.Colors.black.withValues(alpha: 0.55),
                                  fontWeight: m.FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const m.SizedBox(height: 14),

              // ==========================
              // ISI CARD (TETAP + ✅ tambah menu)
              // ==========================
              m.Expanded(
                child: m.ListView(
                  padding: const m.EdgeInsets.all(16),
                  children: [
                    _StatCardBig(
                      title: "Total Alat",
                      value: data["alat"] ?? 0,
                      icon: m.Icons.build_rounded,
                    ),
                    const m.SizedBox(height: 12),
                    _StatCardBig(
                      title: "Total Kategori",
                      value: data["kategori"] ?? 0,
                      icon: m.Icons.category_rounded,
                    ),
                    const m.SizedBox(height: 12),
                    _StatCardBig(
                      title: "Total User",
                      value: data["users"] ?? 0,
                      icon: m.Icons.people_alt_rounded,
                    ),

                    // ✅ TAMBAHAN MENU ADMIN (CRUD)
                    const m.SizedBox(height: 18),
                    _ActionCardBig(
                      title: "Data Peminjaman",
                      subtitle: "Kelola semua data peminjaman (Admin)",
                      icon: m.Icons.assignment_rounded,
                      onTap: () => m.Navigator.pushNamed(
                        context,
                        Routes.adminPeminjaman,
                      ),
                    ),
                    const m.SizedBox(height: 12),
                    _ActionCardBig(
                      title: "Pengembalian & Denda",
                      subtitle: "Kelola pengembalian, terlambat, dan denda",
                      icon: m.Icons.keyboard_return_rounded,
                      onTap: () => m.Navigator.pushNamed(
                        context,
                        Routes.adminPengembalian,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCardBig extends m.StatelessWidget {
  final String title;
  final int value;
  final m.IconData icon;

  const _StatCardBig({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  m.Widget build(m.BuildContext context) {
    return m.Container(
      decoration: m.BoxDecoration(
        color: m.Colors.white,
        borderRadius: m.BorderRadius.circular(20),
        boxShadow: [
          m.BoxShadow(
            blurRadius: 18,
            color: m.Colors.black.withValues(alpha: 0.08),
            offset: const m.Offset(0, 10),
          ),
        ],
        border: m.Border.all(color: const m.Color(0xFFE5E7EB)),
      ),
      child: m.Stack(
        children: [
          m.Positioned(
            right: -30,
            top: -30,
            child: m.Container(
              width: 120,
              height: 120,
              decoration: m.BoxDecoration(
                color: const m.Color(0xFFB91C1C).withValues(alpha: 0.06),
                borderRadius: m.BorderRadius.circular(999),
              ),
            ),
          ),
          m.Positioned(
            right: 30,
            bottom: -40,
            child: m.Container(
              width: 140,
              height: 140,
              decoration: m.BoxDecoration(
                color: const m.Color(0xFFEF4444).withValues(alpha: 0.05),
                borderRadius: m.BorderRadius.circular(999),
              ),
            ),
          ),
          m.Positioned.fill(
            child: m.Align(
              alignment: m.Alignment.centerLeft,
              child: m.Container(
                width: 6,
                decoration: m.BoxDecoration(
                  gradient: const m.LinearGradient(
                    colors: [m.Color(0xFFB91C1C), m.Color(0xFFEF4444)],
                    begin: m.Alignment.topCenter,
                    end: m.Alignment.bottomCenter,
                  ),
                  borderRadius: m.BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          m.Padding(
            padding: const m.EdgeInsets.all(16),
            child: m.Row(
              children: [
                m.Container(
                  width: 52,
                  height: 52,
                  decoration: m.BoxDecoration(
                    gradient: m.LinearGradient(
                      colors: [
                        const m.Color(0xFFB91C1C).withValues(alpha: 0.12),
                        const m.Color(0xFFEF4444).withValues(alpha: 0.08),
                      ],
                      begin: m.Alignment.topLeft,
                      end: m.Alignment.bottomRight,
                    ),
                    borderRadius: m.BorderRadius.circular(18),
                    border: m.Border.all(
                      color: const m.Color(0xFFB91C1C).withValues(alpha: 0.18),
                    ),
                  ),
                  child: m.Icon(icon, color: const m.Color(0xFFB91C1C)),
                ),
                const m.SizedBox(width: 14),
                m.Expanded(
                  child: m.Column(
                    crossAxisAlignment: m.CrossAxisAlignment.start,
                    children: [
                      m.Text(
                        title,
                        maxLines: 1,
                        overflow: m.TextOverflow.ellipsis,
                        style: const m.TextStyle(
                          fontSize: 14,
                          color: m.Colors.black54,
                          fontWeight: m.FontWeight.w800,
                        ),
                      ),
                      const m.SizedBox(height: 8),
                      m.Row(
                        crossAxisAlignment: m.CrossAxisAlignment.end,
                        children: [
                          m.Text(
                            value.toString(),
                            style: const m.TextStyle(
                              fontSize: 32,
                              fontWeight: m.FontWeight.w900,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const m.SizedBox(width: 10),
                          m.Container(
                            padding: const m.EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: m.BoxDecoration(
                              color: const m.Color(
                                0xFFB91C1C,
                              ).withValues(alpha: 0.08),
                              borderRadius: m.BorderRadius.circular(999),
                              border: m.Border.all(
                                color: const m.Color(
                                  0xFFB91C1C,
                                ).withValues(alpha: 0.14),
                              ),
                            ),
                            child: const m.Text(
                              "items",
                              style: m.TextStyle(
                                fontSize: 12,
                                fontWeight: m.FontWeight.w900,
                                color: m.Color(0xFFB91C1C),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                m.Container(
                  width: 34,
                  height: 34,
                  decoration: m.BoxDecoration(
                    color: const m.Color(0xFFF3F4F6),
                    borderRadius: m.BorderRadius.circular(12),
                  ),
                  child: const m.Icon(
                    m.Icons.chevron_right_rounded,
                    color: m.Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ TAMBAHAN CLASS UNTUK MENU CARD (STYLE NYA NYATU)
class _ActionCardBig extends m.StatelessWidget {
  final String title;
  final String subtitle;
  final m.IconData icon;
  final m.VoidCallback onTap;

  const _ActionCardBig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  m.Widget build(m.BuildContext context) {
    return m.InkWell(
      borderRadius: m.BorderRadius.circular(20),
      onTap: onTap,
      child: m.Container(
        decoration: m.BoxDecoration(
          color: m.Colors.white,
          borderRadius: m.BorderRadius.circular(20),
          boxShadow: [
            m.BoxShadow(
              blurRadius: 18,
              color: m.Colors.black.withValues(alpha: 0.08),
              offset: const m.Offset(0, 10),
            ),
          ],
          border: m.Border.all(color: const m.Color(0xFFE5E7EB)),
        ),
        child: m.Stack(
          children: [
            m.Positioned(
              right: -30,
              top: -30,
              child: m.Container(
                width: 120,
                height: 120,
                decoration: m.BoxDecoration(
                  color: const m.Color(0xFFB91C1C).withValues(alpha: 0.06),
                  borderRadius: m.BorderRadius.circular(999),
                ),
              ),
            ),
            m.Positioned.fill(
              child: m.Align(
                alignment: m.Alignment.centerLeft,
                child: m.Container(
                  width: 6,
                  decoration: m.BoxDecoration(
                    gradient: const m.LinearGradient(
                      colors: [m.Color(0xFFB91C1C), m.Color(0xFFEF4444)],
                      begin: m.Alignment.topCenter,
                      end: m.Alignment.bottomCenter,
                    ),
                    borderRadius: m.BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            m.Padding(
              padding: const m.EdgeInsets.all(16),
              child: m.Row(
                children: [
                  m.Container(
                    width: 52,
                    height: 52,
                    decoration: m.BoxDecoration(
                      gradient: m.LinearGradient(
                        colors: [
                          const m.Color(0xFFB91C1C).withValues(alpha: 0.12),
                          const m.Color(0xFFEF4444).withValues(alpha: 0.08),
                        ],
                        begin: m.Alignment.topLeft,
                        end: m.Alignment.bottomRight,
                      ),
                      borderRadius: m.BorderRadius.circular(18),
                      border: m.Border.all(
                        color: const m.Color(
                          0xFFB91C1C,
                        ).withValues(alpha: 0.18),
                      ),
                    ),
                    child: m.Icon(icon, color: const m.Color(0xFFB91C1C)),
                  ),
                  const m.SizedBox(width: 14),
                  m.Expanded(
                    child: m.Column(
                      crossAxisAlignment: m.CrossAxisAlignment.start,
                      children: [
                        m.Text(
                          title,
                          maxLines: 1,
                          overflow: m.TextOverflow.ellipsis,
                          style: const m.TextStyle(
                            fontSize: 15,
                            fontWeight: m.FontWeight.w900,
                          ),
                        ),
                        const m.SizedBox(height: 6),
                        m.Text(
                          subtitle,
                          maxLines: 2,
                          overflow: m.TextOverflow.ellipsis,
                          style: const m.TextStyle(
                            color: m.Colors.black54,
                            fontWeight: m.FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  m.Container(
                    width: 34,
                    height: 34,
                    decoration: m.BoxDecoration(
                      color: const m.Color(0xFFF3F4F6),
                      borderRadius: m.BorderRadius.circular(12),
                    ),
                    child: const m.Icon(
                      m.Icons.chevron_right_rounded,
                      color: m.Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
