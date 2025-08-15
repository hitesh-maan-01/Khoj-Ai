import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:badges/badges.dart' as badges;
import 'quick_actions.dart';
import 'recent_activity.dart';
import 'new_message.dart'; // Make sure this is your renamed MessagePage

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final List<Map<String, dynamic>> dashboardCards = [
    {
      "title": "Total Cases",
      "value": "25",
      "change": "+12%",
      "color": Colors.blue
    },
    {
      "title": "Live Matches",
      "value": "0",
      "status": "Live",
      "color": Colors.green
    },
    {
      "title": "New Reports",
      "value": "3",
      "status": "New",
      "color": Colors.orange
    },
    {
      "title": "Verifications",
      "value": "0",
      "status": "Pending",
      "color": Colors.purple
    },
  ];

  // For demo, we set a static notification count
  // In your real app, fetch from backend or state management
  final int newMessageCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A4DFF),
        elevation: 0,
        title: const Text(
          "Khoj AI",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const MessagePage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      var begin = const Offset(1.0, 0.0);
                      var end = Offset.zero;
                      var curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: badges.Badge(
                showBadge: newMessageCount > 0,
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: Colors.red,
                  padding: EdgeInsets.all(6),
                ),
                badgeContent: Text(
                  newMessageCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                child: const Icon(Icons.notifications, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Officer Details
            Container(
              width: double.infinity,
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
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage("assets/profile.jpg"),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Officer Name",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text("Rank / Position",
                          style: TextStyle(color: Colors.white70)),
                      Chip(
                        label: Text("Active Duty",
                            style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.white24,
                      )
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
                    mainAxisSpacing: 12,
                  ),
                  itemCount: dashboardCards.length,
                  itemBuilder: (context, index) {
                    final card = dashboardCards[index];
                    final cardColor = card['color'] as Color;
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
                              boxShadow: const [
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
                                Text(card["value"] ?? '-',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: cardColor)),
                                const SizedBox(height: 4),
                                Text(card["title"] ?? '',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black87)),
                                const Spacer(),
                                if (card.containsKey("change"))
                                  Text(card["change"] ?? '',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.green)),
                                if (card.containsKey("status"))
                                  Text(card["status"] ?? '',
                                      style: TextStyle(
                                          fontSize: 12, color: cardColor)),
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

            // Quick Actions
            QuickActions(),

            // Recent Activity
            RecentActivity(),
          ],
        ),
      ),
    );
  }
}
