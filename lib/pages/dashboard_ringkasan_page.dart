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
    return m.Padding(
      padding: const m.EdgeInsets.all(16),
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
            crossAxisAlignment: m.CrossAxisAlignment.start,
            children: [
              m.Row(
                mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
                children: [
                  const m.Text(
                    "Ringkasan",
                    style: m.TextStyle(
                      fontSize: 18,
                      fontWeight: m.FontWeight.bold,
                    ),
                  ),
                  m.IconButton(
                    tooltip: "Refresh",
                    onPressed: refresh,
                    icon: const m.Icon(m.Icons.refresh),
                  ),
                ],
              ),
              const m.SizedBox(height: 12),

              _StatCard(
                title: "Total Alat",
                value: data["alat"] ?? 0,
                icon: m.Icons.build,
              ),
              const m.SizedBox(height: 10),
              _StatCard(
                title: "Total Kategori",
                value: data["kategori"] ?? 0,
                icon: m.Icons.category,
              ),
              const m.SizedBox(height: 10),
              _StatCard(
                title: "Total User",
                value: data["users"] ?? 0,
                icon: m.Icons.people,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends m.StatelessWidget {
  final String title;
  final int value;
  final m.IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  m.Widget build(m.BuildContext context) {
    return m.Container(
      width: double.infinity,
      padding: const m.EdgeInsets.all(14),
      decoration: m.BoxDecoration(
        color: m.Colors.white,
        borderRadius: m.BorderRadius.circular(14),
        boxShadow: [
          m.BoxShadow(
            blurRadius: 12,
            offset: const m.Offset(0, 6),
            color: m.Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: m.Row(
        children: [
          m.Container(
            width: 44,
            height: 44,
            decoration: m.BoxDecoration(
              color: const m.Color(0xFFB91C1C).withValues(alpha: 0.10),
              borderRadius: m.BorderRadius.circular(12),
            ),
            child: m.Icon(icon, color: const m.Color(0xFFB91C1C)),
          ),
          const m.SizedBox(width: 12),
          m.Expanded(
            child: m.Text(
              title,
              style: const m.TextStyle(fontWeight: m.FontWeight.w600),
            ),
          ),
          m.Text(
            value.toString(),
            style: const m.TextStyle(
              fontSize: 16,
              fontWeight: m.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
