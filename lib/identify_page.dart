import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IdentifyPage extends StatefulWidget {
  const IdentifyPage({super.key});

  @override
  State<IdentifyPage> createState() => _IdentifyPageState();
}

class _IdentifyPageState extends State<IdentifyPage>
    with SingleTickerProviderStateMixin {
  File? _galleryImageFile;
  File? _cameraImageFile;
  bool _loading = false;
  List<dynamic> _matches = [];
  final ImagePicker _picker = ImagePicker();
  final String apiUrl = "http://192.168.122.20:8000/face/search";

  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _galleryImageFile = File(pickedFile.path);
        _matches.clear();
      });
    }
  }

  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _cameraImageFile = File(pickedFile.path);
        _matches.clear();
      });
    }
  }

  Future<void> _searchDatabase() async {
    // Use camera image if available, else gallery image
    final selectedFile = _cameraImageFile ?? _galleryImageFile;
    if (selectedFile == null) return;

    setState(() {
      _loading = true;
      _matches.clear();
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files
          .add(await http.MultipartFile.fromPath('file', selectedFile.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      setState(() {
        _matches = jsonResponse["matches"] ?? [];
      });

      if (_matches.isNotEmpty) {
        _animController.forward(from: 0);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildImageContainer({
    required String label,
    required IconData icon,
    required File? imageFile,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 150,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue.withOpacity(0.05),
        ),
        child: imageFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: Colors.blueAccent),
                  const SizedBox(height: 10),
                  Text(label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey)),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(imageFile, fit: BoxFit.cover),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Identify Person",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 42, 77, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildImageContainer(
              label: "Click to upload an image\nSupports JPG, PNG files",
              icon: Icons.cloud_upload,
              imageFile: _galleryImageFile,
              onTap: _pickImage,
            ),
            _buildImageContainer(
              label: "Click to capture image using camera",
              icon: Icons.camera_alt,
              imageFile: _cameraImageFile,
              onTap: _captureImage,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text("Search Database"),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color.fromARGB(255, 42, 77, 255),
                  textStyle:
                      TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
              onPressed:
                  (_galleryImageFile != null || _cameraImageFile != null) &&
                          !_loading
                      ? _searchDatabase
                      : null,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _matches.isEmpty
                        ? const Center(child: Text("No record found"))
                        : SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Top Matches",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _matches.length,
                                    itemBuilder: (context, index) {
                                      return AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeIn,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Card(
                                          elevation: 3,
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  _matches[index]["imageUrl"]),
                                            ),
                                            title: Text(_matches[index]
                                                    ["name"] ??
                                                "Unknown"),
                                            subtitle: Text(
                                                "Confidence: ${_matches[index]["confidence"] ?? 'N/A'}"),
                                            trailing: const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
