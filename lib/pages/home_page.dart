import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // ==========================
  // MENU DASHBOARD
  // ==========================
  final List<_MenuItem> _menus = [
    _MenuItem(
      title: 'Alat',
      icon: Icons.inventory_2_rounded,
      route: Routes.alat,
    ),
    _MenuItem(
      title: 'Pinjam',
      icon: Icons.add_circle_outline_rounded,
      route: Routes.buatPeminjaman,
    ),
    _MenuItem(
      title: 'Peminjaman',
      icon: Icons.assignment_rounded,
      route: Routes.peminjamanSaya,
    ),
    _MenuItem(
      title: 'Pengembalian',
      icon: Icons.assignment_return_rounded,
      route: Routes.pengembalian,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F2),

      // ==========================
      // APPBAR (lebih modern, tetap fungsi sama)
      // ==========================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.2),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: IconButton(
              tooltip: "Logout",
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();

                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.login,
                    (route) => false,
                  );
                }
              },
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7F1D1D), Color(0xFFEF4444)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(22),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                color: Colors.black12,
                offset: Offset(0, 8),
              ),
            ],
          ),
        ),
      ),

      // ==========================
      // CONTENT
      // ==========================
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDF2F2), Color(0xFFF8FAFC)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header user
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB91C1C).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFB91C1C).withValues(alpha: 0.16),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo 👋',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '-',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // CARD INFO (lebih hidup + ada pattern)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 18,
                      color: const Color(0xFFB91C1C).withValues(alpha: 0.22),
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -40,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -50,
                      bottom: -60,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                          ),
                          child: const Icon(
                            Icons.motorcycle_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Pantau peminjaman alat bengkel sepeda motor dengan cepat dan rapi 📊',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // label kecil
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 14,
                      color: Colors.black.withValues(alpha: 0.05),
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.grid_view_rounded,
                      size: 18,
                      color: Color(0xFFB91C1C),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Menu Utama",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Spacer(),
                    Text(
                      "Pilih fitur",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // MENU BUTTONS (kartu lebih modern)
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: _menus.map((menu) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.pushNamed(context, menu.route);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 16,
                              color: Colors.black.withValues(alpha: 0.06),
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -22,
                              top: -22,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFB91C1C,
                                  ).withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFB91C1C,
                                      ).withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFB91C1C,
                                        ).withValues(alpha: 0.14),
                                      ),
                                    ),
                                    child: Icon(
                                      menu.icon,
                                      size: 28,
                                      color: const Color(0xFFB91C1C),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    menu.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Buka",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),

      // ==========================
      // BOTTOM NAVIGATION (lebih modern, fungsi sama)
      // ==========================
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black12,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: const Color(0xFFDC2626),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() => _currentIndex = index);
              Navigator.pushNamed(context, _menus[index].route);
            },
            items: _menus
                .map(
                  (menu) => BottomNavigationBarItem(
                    icon: Icon(menu.icon),
                    label: menu.title,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ==========================
// MODEL MENU ITEM
// ==========================
class _MenuItem {
  final String title;
  final IconData icon;
  final String route;

  _MenuItem({required this.title, required this.icon, required this.route});
}
