// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile.dart';
import 'notification_page.dart';
import 'role_mangement_page.dart';
import 'app_info_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  bool _offlineMode = false;
  late AnimationController _animController;

  static const _offlineKey = 'offline_mode_enabled';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _loadOfflineMode();
    _animController.forward();
  }

  Future<void> _loadOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_offlineKey) ?? false;
    setState(() => _offlineMode = enabled);
  }

  Future<void> _setOfflineMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineKey, value);
    setState(() => _offlineMode = value);
    final snack = value ? 'Offline mode enabled' : 'Offline mode disabled';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(snack)));
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
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text('Logout')),
        ],
      ),
    );
    if (ok == true) {
      // Replace with your real logout logic (auth signOut, clearing storage, etc.)
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Logged out (demo)')));
      // Example: Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileHeroTag = 'settings-profile-hero';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
        elevation: 1,
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
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      child: Row(
                        children: [
                          Hero(
                            tag: profileHeroTag,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: const NetworkImage(
                                  'https://randomuser.me/api/portraits/men/32.jpg'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Officer John Smith',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                SizedBox(height: 4),
                                Text('Senior Detective',
                                    style: TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12)),
                            child: const Text('Active Status',
                                style: TextStyle(color: Colors.blueAccent)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Edit Profile
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Edit Profile'),
                    subtitle: const Text('Update personal information'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openPage(const EditProfilePage()),
                  ),

                  const SizedBox(height: 8),

                  // Notifications
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifications'),
                    subtitle: const Text('Manage alert preferences'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openPage(const NotificationsPage()),
                  ),

                  const SizedBox(height: 8),

                  // Offline Mode
                  ListTile(
                    leading: const Icon(Icons.cloud_off),
                    title: const Text('Offline Mode'),
                    subtitle: const Text('Work without internet'),
                    trailing: Switch(
                      value: _offlineMode,
                      onChanged: (v) => _setOfflineMode(v),
                    ),
                    onTap: () => _setOfflineMode(!_offlineMode),
                  ),

                  const SizedBox(height: 8),

                  // Role Management
                  ListTile(
                    leading: const Icon(Icons.shield),
                    title: const Text('Role Management'),
                    subtitle: const Text('Permissions & access control'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openPage(const RoleManagementPage()),
                  ),

                  const SizedBox(height: 8),

                  // App Information
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('App Information'),
                    subtitle: const Text('Version 2.1.0'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openPage(const AppInfoPage()),
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
