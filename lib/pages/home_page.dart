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
    _MenuItem(title: 'Alat', icon: Icons.inventory, route: Routes.alat),
    _MenuItem(
      title: 'Pinjam',
      icon: Icons.add_circle,
      route: Routes.buatPeminjaman,
    ),
    _MenuItem(
      title: 'Peminjaman',
      icon: Icons.assignment,
      route: Routes.peminjamanSaya,
    ),
    _MenuItem(
      title: 'Pengembalian',
      icon: Icons.assignment_return,
      route: Routes.pengembalian,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F2),

      // ==========================
      // APPBAR
      // ==========================
      appBar: AppBar(
        backgroundColor: const Color(0xFFB91C1C),
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
        ],
      ),

      // ==========================
      // CONTENT
      // ==========================
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo 👋',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            Text(
              user?.email ?? '-',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // CARD INFO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.motorcycle, color: Colors.white, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Pantau peminjaman alat bengkel sepeda motor dengan cepat dan rapi 📊',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // MENU BUTTONS
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: _menus.map((menu) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, menu.route);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            menu.icon,
                            size: 40,
                            color: const Color(0xFFDC2626),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            menu.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
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

      // ==========================
      // BOTTOM NAVIGATION
      // ==========================
      bottomNavigationBar: BottomNavigationBar(
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
