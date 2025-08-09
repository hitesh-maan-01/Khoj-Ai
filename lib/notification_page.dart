import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool push = true;
  bool email = false;
  bool sms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive real-time alerts'),
            value: push,
            onChanged: (v) => setState(() => push = v),
          ),
          SwitchListTile(
            title: const Text('Email Alerts'),
            subtitle: const Text('Receive email summaries'),
            value: email,
            onChanged: (v) => setState(() => email = v),
          ),
          SwitchListTile(
            title: const Text('SMS Alerts'),
            subtitle: const Text('Receive urgent SMS'),
            value: sms,
            onChanged: (v) => setState(() => sms = v),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                // Save preferences to backend or shared_prefs
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Notification preferences saved (demo)')));
                Navigator.pop(context);
              },
              child: const Text('Save Preferences'))
        ],
      ),
    );
  }
}
