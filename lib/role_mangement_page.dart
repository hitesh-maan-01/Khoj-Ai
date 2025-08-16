import 'package:flutter/material.dart';

class RoleManagementPage extends StatefulWidget {
  const RoleManagementPage({super.key});

  @override
  State<RoleManagementPage> createState() => _RoleManagementPageState();
}

class _RoleManagementPageState extends State<RoleManagementPage> {
  final Map<String, bool> _roles = {
    'Admin': false,
    'Investigator': true,
    'Guard': false,
    'Analyst': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Management'),
        backgroundColor: Color.fromARGB(255, 13, 71, 161),
        titleTextStyle: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._roles.entries.map((e) {
            return SwitchListTile(
              title: Text(e.key),
              value: e.value,
              onChanged: (v) => setState(() => _roles[e.key] = v),
            );
          }),
          const SizedBox(height: 12),
          ElevatedButton(
              onPressed: () {
                // save roles
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Roles updated (demo)')));
                Navigator.pop(context);
              },
              child: const Text('Save Roles')),
        ],
      ),
    );
  }
}
