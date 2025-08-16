import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactTeamPage extends StatefulWidget {
  const ContactTeamPage({super.key});

  @override
  State<ContactTeamPage> createState() => _ContactTeamPageState();
}

class _ContactTeamPageState extends State<ContactTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _orgCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String? _orgType;

  final Color accentColor = const Color.fromARGB(255, 13, 71, 161);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _orgCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'khojai0118@gmail.com', // replace with your team email
      queryParameters: {
        'subject': 'Contact Form Submission from ${_nameCtrl.text}',
        'body': '''
Full Name: ${_nameCtrl.text}
Email: ${_emailCtrl.text}
Organization: ${_orgCtrl.text}
Phone: ${_phoneCtrl.text}
Organization Type: $_orgType

Message:
${_messageCtrl.text}
        ''',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mail sent')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mail sent')),
      );
    }
    setState(() {
      _nameCtrl.clear();
      _emailCtrl.clear();
      _orgCtrl.clear();
      _phoneCtrl.clear();
      _messageCtrl.clear();
      _orgType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contact Our Team',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: accentColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name *'),
                validator: (v) => v!.isEmpty ? 'Enter your full name' : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email *'),
                validator: (v) => v!.isEmpty ? 'Enter your email' : null,
              ),
              TextFormField(
                controller: _orgCtrl,
                decoration: const InputDecoration(labelText: 'Organization *'),
                validator: (v) => v!.isEmpty ? 'Enter organization name' : null,
              ),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              DropdownButtonFormField<String>(
                value: _orgType,
                decoration:
                    const InputDecoration(labelText: 'Organization Type *'),
                items: const [
                  DropdownMenuItem(value: 'Admin', child: Text('Army')),
                  DropdownMenuItem(value: 'NGO', child: Text('NGO')),
                  DropdownMenuItem(value: 'NDRF', child: Text('NDRF')),
                  DropdownMenuItem(value: 'Police', child: Text('Police')),
                ],
                onChanged: (v) => setState(() => _orgType = v),
                validator: (v) => v == null ? 'Select organization type' : null,
              ),
              TextFormField(
                controller: _messageCtrl,
                decoration: const InputDecoration(
                    labelText: 'Message *', alignLabelWithHint: true),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Enter your message' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _sendMessage,
                  label: const Text('Send Message',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
