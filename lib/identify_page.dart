import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class IdentifyPage extends StatefulWidget {
  const IdentifyPage({super.key});

  @override
  State<IdentifyPage> createState() => _IdentifyPageState();
}

class _IdentifyPageState extends State<IdentifyPage>
    with TickerProviderStateMixin {
  File? _image;
  bool _loading = false;
  List<Map<String, dynamic>> _matches = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _matches.clear();
      });
    }
  }

  Future<void> _searchDatabase() async {
    if (_image == null) return;

    setState(() => _loading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("http://192.168.122.20:8000/face/search"),
      );

      request.files
          .add(await http.MultipartFile.fromPath('file', _image!.path));
      final response = await request.send();

      if (response.statusCode == 200) {
        final res = await response.stream.bytesToString();
        final data = json.decode(res);

        setState(() {
          _matches = List<Map<String, dynamic>>.from(data['matches'] ?? []);
        });
      } else {
        debugPrint("API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    setState(() => _loading = false);
  }

  Widget _buildMatchCard(Map<String, dynamic> match, int index) {
    double? confidence;
    if (match["confidence"] != null) {
      try {
        confidence = (match["confidence"] is num)
            ? (match["confidence"] as num).toDouble()
            : double.tryParse(match["confidence"].toString());
      } catch (_) {
        confidence = null;
      }
    }

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 400),
      child: SlideAnimation(
        verticalOffset: 20.0,
        child: FadeInAnimation(
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: ListTile(
              leading: (match["imageUrl"] != null &&
                      match["imageUrl"].toString().isNotEmpty)
                  ? Hero(
                      tag: match["imageUrl"],
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(match["imageUrl"]),
                        radius: 28,
                      ),
                    )
                  : const CircleAvatar(child: Icon(Icons.person)),
              title: Text(
                match["name"]?.toString() ?? "Unknown",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                "Confidence: ${confidence != null ? confidence.toStringAsFixed(2) : "N/A"}",
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MatchDetailPage(match: match),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("🔍 Identify Person"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 13, 71, 163),
        titleTextStyle: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        _image!,
                        key: ValueKey(_image),
                        fit: BoxFit.cover,
                        height: 220,
                      ),
                    )
                  : Container(
                      key: const ValueKey("placeholder"),
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey[300],
                      ),
                      child: const Center(
                        child: Text(
                          "📷 Upload or Capture an Image",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _animatedButton(Icons.photo, "Gallery",
                    () => _pickImage(ImageSource.gallery)),
                _animatedButton(Icons.camera_alt, "Camera",
                    () => _pickImage(ImageSource.camera)),
              ],
            ),
            const SizedBox(height: 20),

            // Search Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: const Color.fromARGB(255, 13, 71, 161),
                iconColor: Color.fromARGB(255, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _loading ? null : _searchDatabase,
              icon: const Icon(Icons.search),
              label: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Search Database",
                      style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
            ),
            const SizedBox(height: 30),

            // Top Matches
            if (_matches.isNotEmpty)
              AnimationLimiter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "🎯 Top Matches",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ..._matches
                        .asMap()
                        .entries
                        .map((entry) => _buildMatchCard(entry.value, entry.key))
                        .toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _animatedButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 13, 71, 163),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
      ),
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}

/// 🔹 Detail Page for a Match
class MatchDetailPage extends StatelessWidget {
  final Map<String, dynamic> match;

  const MatchDetailPage({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    double? confidence;
    if (match["confidence"] != null) {
      try {
        confidence = (match["confidence"] is num)
            ? (match["confidence"] as num).toDouble()
            : double.tryParse(match["confidence"].toString());
      } catch (_) {
        confidence = null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(match["name"]?.toString() ?? "Person Details"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (match["imageUrl"] != null &&
                    match["imageUrl"].toString().isNotEmpty)
                ? Hero(
                    tag: match["imageUrl"],
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(match["imageUrl"]),
                      radius: 60,
                    ),
                  )
                : const CircleAvatar(
                    radius: 60, child: Icon(Icons.person, size: 40)),

            const SizedBox(height: 20),
            Text(
              match["name"]?.toString() ?? "Unknown",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Confidence: ${confidence != null ? confidence.toStringAsFixed(2) : "N/A"}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Extra details if available
            if (match.containsKey("details"))
              Text(
                match["details"].toString(),
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
