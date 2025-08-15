import 'dart:io';
import 'package:flutter/material.dart';

class CaseDetailsPage extends StatelessWidget {
  final Map<String, dynamic> report;
  const CaseDetailsPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final photoPath = report['photoPath'] as String? ?? '';
    final accentColor = const Color(0xFF2A4DFF);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          report['fullName'] ?? 'Case Details',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: accentColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Case Image with Hero Animation
            if (photoPath.isNotEmpty)
              Hero(
                tag:
                    'case-photo-${report['caseId']}', // Unique tag for Hero animation
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(photoPath),
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            // Content Container with subtle shadow
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: _AnimatedContent(report: report, accentColor: accentColor),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// A separate widget to handle the sequential animations
class _AnimatedContent extends StatefulWidget {
  final Map<String, dynamic> report;
  final Color accentColor;

  const _AnimatedContent({
    required this.report,
    required this.accentColor,
  });

  @override
  _AnimatedContentState createState() => _AnimatedContentState();
}

class _AnimatedContentState extends State<_AnimatedContent> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Start the fade-in animation after the widget is built
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _opacity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Case Details Section
          _buildInfoSection(
            title: "Personal Details",
            icon: Icons.person_outline,
            color: widget.accentColor,
            children: [
              _buildInfoCard(
                  icon: Icons.badge,
                  label: "Case ID",
                  value: widget.report['caseId'] ?? '-'),
              _buildInfoCard(
                  icon: Icons.person,
                  label: "Name",
                  value: widget.report['fullName'] ?? '-'),
              _buildInfoCard(
                  icon: Icons.cake,
                  label: "Age",
                  value: widget.report['age']?.toString() ?? '-'),
              _buildInfoCard(
                  icon: Icons.wc,
                  label: "Gender",
                  value: widget.report['gender'] ?? '-'),
            ],
          ),
          const SizedBox(height: 20),

          // Physical Attributes Section
          _buildInfoSection(
            title: "Physical Attributes",
            icon: Icons.accessibility_new,
            color: Colors.deepOrange,
            children: [
              _buildInfoCard(
                  icon: Icons.height,
                  label: "Height",
                  value: widget.report['height']?.toString() ?? '-'),
              _buildInfoCard(
                  icon: Icons.monitor_weight,
                  label: "Weight",
                  value: widget.report['weight']?.toString() ?? '-'),
            ],
          ),
          const SizedBox(height: 20),

          // Last Seen Location Section
          _buildInfoSection(
            title: "Last Seen Location",
            icon: Icons.location_on_outlined,
            color: Colors.green,
            children: [
              _buildInfoCard(
                  icon: Icons.place,
                  label: "Location",
                  value: widget.report['lastSeenLocation_input'] ?? '-'),
            ],
          ),
          const SizedBox(height: 20),

          // Guardian Information Section
          _buildInfoSection(
            title: "Guardian Information",
            icon: Icons.family_restroom,
            color: Colors.purple,
            children: [
              _buildInfoCard(
                  icon: Icons.person_pin,
                  label: "Name",
                  value: widget.report['guardianName'] ?? '-'),
              _buildInfoCard(
                  icon: Icons.phone,
                  label: "Contact",
                  value: widget.report['guardianContact'] ?? '-'),
            ],
          ),
          const SizedBox(height: 20),

          // Description Section
          _buildDescriptionSection(
            title: "Description",
            color: widget.accentColor,
            value: widget.report['description'] ?? '-',
          ),
          const SizedBox(height: 20),

          // Report Time
          Row(
            children: [
              Icon(Icons.access_time, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                "Reported on: ${widget.report['date'] ?? '-'}",
                style: const TextStyle(
                    color: Colors.black54, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildDescriptionSection({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 16, height: 1.5, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: scale,
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (color ?? Colors.blue).withOpacity(0.15),
                  child: Icon(icon, color: color ?? Colors.blue),
                ),
                title: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(value, style: const TextStyle(fontSize: 15)),
              ),
            ),
          ),
        );
      },
    );
  }
}
