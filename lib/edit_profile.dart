import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'Jai Shree Ram');
  final _roleCtrl = TextEditingController(text: 'God Detective');
  String? _status = 'Active';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      // persist update (call backend or shared_prefs)
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile saved (demo)')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(radius: 44, backgroundImage: const NetworkImage('')),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full name')),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _roleCtrl,
                  decoration: const InputDecoration(labelText: 'Role')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive'))
                ],
                onChanged: (v) => setState(() => _status = v),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child:
                    ElevatedButton(onPressed: _save, child: const Text('Save')),
              )
            ],
          ),
        ),
      ),
    );
  }
}
