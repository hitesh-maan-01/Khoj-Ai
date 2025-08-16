// reports_page.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'case_details_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> filteredReports = [];
  Timer? _longPressTimer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReports();
    _searchController.addListener(_filterReports);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterReports);
    _searchController.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    final String? reportsData = prefs.getString('reports');
    if (reportsData != null) {
      try {
        final decoded = json.decode(reportsData);
        if (decoded is List) {
          setState(() {
            reports = List<Map<String, dynamic>>.from(decoded);
            filteredReports = List.from(reports);
          });
        }
      } catch (e) {
        debugPrint("Error decoding reports: $e");
      }
    }
  }

  Future<void> _saveReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reports', json.encode(reports));
  }

  void _deleteReport(int index) {
    setState(() {
      reports.removeAt(index);
      filteredReports = List.from(reports);
    });
    _saveReports();
  }

  void _filterReports() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredReports = reports.where((report) {
        final name = (report['fullName']?.toString() ?? '').toLowerCase();
        final location =
            (report['lastSeenlocation_input']?.toString() ?? '').toLowerCase();
        return name.contains(query) || location.contains(query);
      }).toList();
    });
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Report"),
        content: const Text("Are you sure you want to delete this report?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReport(index);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleLongPress(int index) {
    _longPressTimer?.cancel();
    _longPressTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _showDeleteDialog(index);
      }
    });
  }

  void _cancelLongPress() {
    _longPressTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Reports",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 13, 71, 161),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by name...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
          ),
          Expanded(
            child: filteredReports.isEmpty
                ? const Center(
                    child: Text("No reports found."),
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = filteredReports[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 400),
                          child: SlideAnimation(
                            verticalOffset: 50,
                            child: FadeInAnimation(
                              child: GestureDetector(
                                onLongPressStart: (_) =>
                                    _handleLongPress(index),
                                onLongPressEnd: (_) => _cancelLongPress(),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          CaseDetailsPage(report: report),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        // Image thumbnail
                                        (report['photoPath'] != null &&
                                                report['photoPath']
                                                    .toString()
                                                    .isNotEmpty)
                                            ? Hero(
                                                tag:
                                                    'case-photo-${report['caseId'] ?? index}',
                                                child: ClipOval(
                                                  child: Image.file(
                                                    File(report['photoPath']),
                                                    width: 90,
                                                    height: 90,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 50,
                                                  color: Colors.deepOrange,
                                                ),
                                              ),
                                        const SizedBox(width: 16),
                                        // Report details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildDetailRow(
                                                  "Name", report['fullName']),
                                              _buildDetailRow(
                                                  "Age", report['age']),
                                              _buildDetailRow("Location",
                                                  report['lastSeenLocation']),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(
                text: "$title: ",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
                text: (value != null && value.toString().isNotEmpty)
                    ? value.toString()
                    : "N/A"),
          ],
        ),
      ),
    );
  }
}
