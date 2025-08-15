import 'package:flutter/material.dart';
import 'identify_page.dart';
import 'report_missing_person_flow.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  Widget _buildQuickAction(BuildContext context,
      {required String title,
      required IconData icon,
      required List<Color> colors,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.28),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Quick Actions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAction(context,
                  title: "Submit\nNew Report",
                  icon: Icons.note_add,
                  colors: [Colors.deepOrange, Colors.orangeAccent], onTap: () {
                // Open Report Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ReportMissingPersonFlow()),
                );
              }),
              _buildQuickAction(context,
                  title: "Identify\nPerson",
                  icon: Icons.search,
                  colors: [Colors.blue.shade700, Colors.lightBlueAccent],
                  onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => IdentifyPage()));
              }),
            ],
          ),
        ],
      ),
    );
  }
}
