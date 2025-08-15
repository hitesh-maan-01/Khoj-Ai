import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoPage extends StatefulWidget {
  const AppInfoPage({super.key});

  @override
  State<AppInfoPage> createState() => _AppInfoPageState();
}

class _AppInfoPageState extends State<AppInfoPage> {
  String _version = '—';
  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() => _version = '${info.version} (${info.buildNumber})');
    } catch (e) {
      setState(() => _version = '2.1.0');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'App Information',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 42, 77, 255),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const ListTile(
              leading: Icon(Icons.info_outline),
              iconColor: Color.fromARGB(255, 42, 77, 255),
              title: Text('Khoj AI'),
              subtitle: Text('Missing Person Reporting'),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Version'),
              subtitle: Text(_version),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () {
                  // show licenses, or open privacy policy
                  showAboutDialog(
                      context: context,
                      applicationName: 'Khoj AI',
                      applicationVersion: _version);
                },
                child: const Text(
                  'About',
                  style: TextStyle(
                      color: Color.fromARGB(255, 42, 77, 255),
                      fontWeight: FontWeight.bold),
                )),
          ],
        ),
      ),
    );
  }
}
