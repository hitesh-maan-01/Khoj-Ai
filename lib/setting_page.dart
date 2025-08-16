// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'edit_profile.dart';
import 'notification_page.dart';
import 'app_info_page.dart';
import 'contact_team_page.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final Color accentColor = const Color.fromARGB(255, 13, 71, 161);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _openPage(Widget page) {
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (context, animation, secondaryAnimation) =>
          FadeTransition(opacity: animation, child: page),
    ));
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Secure Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color.fromARGB(255, 13, 71, 161)),
              )),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => LoginPage()), // Redirect to login
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Color.fromARGB(255, 13, 71, 161)),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      // Replace with your real logout logic (auth signOut, clearing storage, etc.)
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Logged out')));
      // Example: Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 1,
        backgroundColor: accentColor,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _animController, curve: Curves.easeIn),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 600),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 20,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  // Profile header
                  ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          const AssetImage('assets/Shubham/img_yadav.jpg'),
                      backgroundColor: accentColor.withOpacity(0.1),
                    ),
                    title: const Text('Shubham Yadav',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: const Text('Admin',
                        style: TextStyle(color: Colors.black54)),
                    onTap: () => _openPage(const ProfilePage()),
                  ),

                  const Divider(height: 30),

                  // Edit Profile
                  ListTile(
                    leading: Icon(Icons.person, color: accentColor),
                    title: const Text('Profile'),
                    subtitle: const Text('View details'),
                    trailing: Icon(Icons.chevron_right, color: accentColor),
                    onTap: () => _openPage(const ProfilePage()),
                  ),

                  const SizedBox(height: 8),

                  // Notifications
                  ListTile(
                    leading: Icon(Icons.notifications, color: accentColor),
                    title: const Text('Notifications'),
                    subtitle: const Text('Manage alert preferences'),
                    trailing: Icon(Icons.chevron_right, color: accentColor),
                    onTap: () => _openPage(const NotificationsPage()),
                  ),

                  const SizedBox(height: 8),

                  // App Information
                  ListTile(
                    leading: Icon(Icons.info_outline, color: accentColor),
                    title: const Text('App Information'),
                    subtitle: const Text('Version 2.1.0'),
                    trailing: Icon(Icons.chevron_right, color: accentColor),
                    onTap: () => _openPage(const AppInfoPage()),
                  ),

                  const SizedBox(height: 8),
                  // Contact Our Team
                  ListTile(
                    leading: Icon(Icons.contact_mail, color: accentColor),
                    title: const Text('Contact Our Team'),
                    subtitle: const Text('Send feedback or get in touch'),
                    trailing: Icon(Icons.chevron_right, color: accentColor),
                    onTap: () => _openPage(const ContactTeamPage()),
                  ),
                  const SizedBox(height: 8),

                  // Secure Logout
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text('Secure Logout',
                        style: TextStyle(color: Colors.redAccent)),
                    subtitle: const Text('Sign out safely'),
                    trailing: const Icon(Icons.chevron_right,
                        color: Colors.redAccent),
                    onTap: _confirmLogout,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
