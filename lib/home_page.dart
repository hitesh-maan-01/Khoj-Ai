import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'report_missing_person_flow.dart';
import 'setting_page.dart';

// ---------------------- DASHBOARD PAGE ----------------------
class DashboardPage extends StatelessWidget {
  final List<Map<String, dynamic>> dashboardCards = [
    {
      "title": "Total Cases",
      "value": "247",
      "change": "+12%",
      "color": Colors.blue
    },
    {
      "title": "Live Matches",
      "value": "18",
      "status": "Live",
      "color": Colors.green
    },
    {
      "title": "New Reports",
      "value": "34",
      "status": "New",
      "color": Colors.orange
    },
    {
      "title": "Verifications",
      "value": "12",
      "status": "Pending",
      "color": Colors.purple
    },
  ];

  final List<Map<String, String>> recentActivity = [
    {
      "type": "High Priority Alert",
      "detail": "Missing person case #MP-2024-001",
      "time": "2m ago"
    },
    {
      "type": "Case Resolved",
      "detail": "Theft case #TH-2024-045 closed",
      "time": "15m ago"
    },
    {
      "type": "New Detection",
      "detail": "Facial recognition match found",
      "time": "1h ago"
    },
  ];

  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Khoj Ai"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF2A4DFF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Hero(
                    tag: "profile-pic",
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage("assets/profile.jpg"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Jai Shree Ram",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const Text("God",
                          style: TextStyle(color: Colors.white70)),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text("Active Duty",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Dashboard Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimationLimiter(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12),
                  itemCount: dashboardCards.length,
                  itemBuilder: (context, index) {
                    final card = dashboardCards[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      columnCount: 2,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4))
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(card["value"],
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: card["color"])),
                                const SizedBox(height: 4),
                                Text(card["title"],
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black87)),
                                if (card.containsKey("change"))
                                  Text(card["change"],
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.green)),
                                if (card.containsKey("status"))
                                  Text(card["status"],
                                      style: TextStyle(
                                          fontSize: 12, color: card["color"])),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Recent Activity
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Recent Activity",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("View All",
                      style:
                          TextStyle(color: Color.fromARGB(255, 42, 77, 255))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            AnimationLimiter(
              child: Column(
                children: List.generate(recentActivity.length, (index) {
                  final activity = recentActivity[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: ListTile(
                          leading: Icon(Icons.notifications,
                              color: Colors.redAccent),
                          title: Text(activity["type"]!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(activity["detail"]!),
                          trailing: Text(activity["time"]!,
                              style: const TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReportMissingPersonFlow(),
                            ),
                          );
                        },
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.deepOrange, Colors.orangeAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.note_add,
                                  color: Colors.white, size: 40),
                              SizedBox(height: 8),
                              Text(
                                "Submit\nNew Report",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ReportsPage extends StatelessWidget {
  final reports = List.generate(10, (index) => "Report #${1000 + index}");

  ReportsPage({super.key});

  void _openCaseDetail(BuildContext context, String reportId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: AnimationLimiter(
        child: ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            String reportId = reports[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 500),
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: GestureDetector(
                    onTap: () => _openCaseDetail(context, reportId),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Hero(
                          tag: "icon_$reportId",
                          child: Icon(Icons.description, color: Colors.orange),
                        ),
                        title: Text(reportId),
                        subtitle: const Text("Report details preview"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
