// recent_activity.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'all_activity_page.dart';

class RecentActivity extends StatefulWidget {
  const RecentActivity({super.key});

  @override
  State<RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> {
  List<Map<String, dynamic>> recentReports = [];

  @override
  void initState() {
    super.initState();
    _loadRecentReports();
  }

  Future<void> _loadRecentReports() async {
    final prefs = await SharedPreferences.getInstance();
    final String? reportsData = prefs.getString('reports');

    if (reportsData != null) {
      try {
        final decoded = json.decode(reportsData);
        if (decoded is List) {
          setState(() {
            final allReports = List<Map<String, dynamic>>.from(decoded);
            recentReports = allReports.reversed.take(4).toList();
          });
        }
      } catch (e) {
        debugPrint("Error decoding recent reports: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header + View All button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Activity",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AllActivityPage()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor:
                      const Color.fromARGB(255, 23, 71, 163), // text color
                ),
                child: const Text("View All"),
              ),
            ],
          ),
        ),

        // List of recent reports
        recentReports.isEmpty
            ? const Center(child: Text("No recent activity"))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentReports.length,
                itemBuilder: (context, index) {
                  final report = recentReports[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    child: ListTile(
                      leading: const Icon(Icons.assignment, color: Colors.blue),
                      title: Text(report['fullName'] ?? "Unknown"),
                      subtitle: Text(
                          "Location: ${report['lastSeenLocation'] ?? 'N/A'}"),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
