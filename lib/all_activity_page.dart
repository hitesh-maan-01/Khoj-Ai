// all_activity_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllActivityPage extends StatefulWidget {
  const AllActivityPage({super.key});

  @override
  State<AllActivityPage> createState() => _AllActivityPageState();
}

class _AllActivityPageState extends State<AllActivityPage> {
  List<Map<String, dynamic>> allReports = [];

  @override
  void initState() {
    super.initState();
    _loadAllReports();
  }

  Future<void> _loadAllReports() async {
    final prefs = await SharedPreferences.getInstance();
    final String? reportsData = prefs.getString('reports');

    if (reportsData != null) {
      try {
        final decoded = json.decode(reportsData);
        if (decoded is List) {
          setState(() {
            allReports =
                List<Map<String, dynamic>>.from(decoded).reversed.toList();
          });
        }
      } catch (e) {
        debugPrint("Error decoding all reports: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Activities"),
        backgroundColor: const Color.fromARGB(255, 13, 71, 161),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: allReports.isEmpty
          ? const Center(child: Text("No activities yet"))
          : ListView.builder(
              itemCount: allReports.length,
              itemBuilder: (context, index) {
                final report = allReports[index];
                return ListTile(
                  leading: const Icon(Icons.assignment,
                      color: Color.fromARGB(255, 13, 71, 163)),
                  title: Text(report['fullName'] ?? "Unknown"),
                  subtitle:
                      Text("Location: ${report['lastSeenLocation'] ?? 'N/A'}"),
                );
              },
            ),
    );
  }

  static String _timeAgo(dynamic isoTime) {
    if (isoTime == null) return "N/A";
    try {
      final dateTime = DateTime.parse(isoTime.toString());
      final diff = DateTime.now().difference(dateTime);
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      return "${diff.inDays}d ago";
    } catch (_) {
      return "N/A";
    }
  }
}
