import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'Jai Shree Ram');
  final _roleCtrl = TextEditingController(text: 'God Detective');
  String? _status = 'Active';
  File? _imageFile;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      // Here you can persist update (call backend or shared_prefs)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
      Navigator.pop(context, {
        'name': _nameCtrl.text,
        'role': _roleCtrl.text,
        'status': _status,
        'image': _imageFile
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color.fromARGB(255, 42, 77, 255),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Hero(
                    tag: 'profile-pic',
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : const NetworkImage(
                                  'https://via.placeholder.com/150')
                              as ImageProvider,
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _roleCtrl,
                  decoration: const InputDecoration(labelText: 'Role'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your role' : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(
                        value: 'Inactive', child: Text('Inactive')),
                  ],
                  onChanged: (v) => setState(() => _status = v),
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 42, 77, 255), // Button color
                      foregroundColor: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _save,
                    child: const Text(
                      'Save',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
