import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas/provider/auth_provider.dart';
import 'package:uas/provider/shared_preferences_provider.dart';
import 'my_profile_screen.dart';
import 'elements_screen.dart';
import 'color_skins_screen.dart';
import 'login_screen_new.dart';
import '../services/local_db.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _tapToSignOut() async {
    final sharedPreferenceProvider = context.read<SharedPreferenceProvider>();
    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    await authProvider
        .signOutUser()
        .then((value) async {
          await sharedPreferenceProvider.logout();
          navigator.pushReplacement(
            MaterialPageRoute(builder: (c) => const LoginScreen()),
          );
        })
        .whenComplete(() {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text(authProvider.message ?? "")),
          );
        });
  }

  Widget _menuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    const Color bg = Color(0xFF1665D8);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap ?? () {},
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 18),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 18),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _menuButton(
                context,
                icon: Icons.person_outline,
                label: 'My Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyProfileScreen()),
                  );
                },
              ),
              _menuButton(
                context,
                icon: Icons.grid_view,
                label: 'Elements',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ElementsScreen()),
                  );
                },
              ),
              _menuButton(
                context,
                icon: Icons.palette,
                label: 'Color Skins',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ColorSkinsScreen()),
                  );
                },
              ),
              _menuButton(
                context,
                icon: Icons.logout,
                label: 'Logout',
                onTap: () async {
                  // Show confirmation dialog
                  final confirm =
                      await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Konfirmasi Logout'),
                          content: const Text(
                            'Apakah Anda yakin ingin keluar?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => _tapToSignOut(),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (confirm && context.mounted) {
                    // Clear user session
                    await LocalDB().logout();

                    // Navigate to login screen and clear navigation stack
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false, // remove all previous routes
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
