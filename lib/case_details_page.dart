import 'dart:io';
import 'package:flutter/material.dart';

class CaseDetailsPage extends StatelessWidget {
  final Map<String, dynamic> report;

  const CaseDetailsPage({Key? key, required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? photoPath = report['photoPath'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Case Details"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Case ID: ${report['caseId']}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Name: ${report['name']}"),
            Text("Age: ${report['age']}"),
            const SizedBox(height: 10),
            Text("Details: ${report['details']}"),
            const SizedBox(height: 10),
            Text("Reported on: ${report['date']}"),
            const SizedBox(height: 20),
            if (photoPath != null)
              Image.file(File(photoPath), height: 200, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }
}
