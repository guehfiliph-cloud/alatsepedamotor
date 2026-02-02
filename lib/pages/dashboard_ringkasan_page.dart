import 'package:flutter/material.dart' as m;
import 'package:supabase_flutter/supabase_flutter.dart';

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
    return m.FutureBuilder<Map<String, int>>(
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
            // HEADER PUTIH (RAPI & TEGAS)
            // ==========================
            m.Container(
              width: double.infinity,
              padding: const m.EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const m.BoxDecoration(
                color: m.Colors.white,
                boxShadow: [
                  m.BoxShadow(
                    blurRadius: 6,
                    color: m.Colors.black12,
                    offset: m.Offset(0, 2),
                  ),
                ],
                borderRadius: m.BorderRadius.only(
                  bottomLeft: m.Radius.circular(24),
                  bottomRight: m.Radius.circular(24),
                ),
              ),
              child: m.Row(
                children: [
                  const m.Icon(
                    m.Icons.dashboard_rounded,
                    color: m.Color(0xFFB91C1C),
                  ),
                  const m.SizedBox(width: 12),
                  const m.Expanded(
                    child: m.Column(
                      crossAxisAlignment: m.CrossAxisAlignment.start,
                      children: [
                        m.Text(
                          "Ringkasan",
                          style: m.TextStyle(
                            fontSize: 18,
                            fontWeight: m.FontWeight.bold,
                          ),
                        ),
                        m.SizedBox(height: 4),
                        m.Text(
                          "Statistik data sistem",
                          style: m.TextStyle(color: m.Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  m.IconButton(
                    tooltip: "Refresh",
                    onPressed: refresh,
                    icon: const m.Icon(m.Icons.refresh),
                  ),
                ],
              ),
            ),

            const m.SizedBox(height: 14),

            // ==========================
            // ISI CARD
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
                ],
              ),
            ),
          ],
        );
      },
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
      padding: const m.EdgeInsets.all(16),
      decoration: m.BoxDecoration(
        color: m.Colors.white,
        borderRadius: m.BorderRadius.circular(16),
        boxShadow: [
          m.BoxShadow(
            blurRadius: 10,
            color: m.Colors.black.withValues(alpha: 0.08),
            offset: const m.Offset(0, 4),
          ),
        ],
      ),
      child: m.Row(
        children: [
          m.Container(
            width: 46,
            height: 46,
            decoration: m.BoxDecoration(
              color: const m.Color(0xFFB91C1C).withValues(alpha: 0.12),
              borderRadius: m.BorderRadius.circular(14),
            ),
            child: m.Icon(icon, color: const m.Color(0xFFB91C1C)),
          ),
          const m.SizedBox(width: 12),
          m.Expanded(
            child: m.Column(
              crossAxisAlignment: m.CrossAxisAlignment.start,
              children: [
                m.Text(
                  title,
                  style: const m.TextStyle(
                    fontSize: 14,
                    color: m.Colors.black54,
                    fontWeight: m.FontWeight.w700,
                  ),
                ),
                const m.SizedBox(height: 6),
                m.Text(
                  value.toString(),
                  style: const m.TextStyle(
                    fontSize: 26,
                    fontWeight: m.FontWeight.w900,
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
