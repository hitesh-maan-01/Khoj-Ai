import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class RecentActivity extends StatelessWidget {
  RecentActivity({super.key});

  final List<Map<String, String>> recentActivity = [
    {
      "type": "High Priority Alert",
      "detail": "Missing person case #MP-2024-001",
      "time": "22h ago"
    },
    {"type": "Case Resolved", "detail": "TH-2024-045 closed", "time": "21 ago"},
    {
      "type": "New Detection",
      "detail": "Facial recognition match found",
      "time": "7h ago"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Recent Activity",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("View All",
                  style: TextStyle(color: Color.fromARGB(255, 13, 71, 161))),
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
                      leading: const CircleAvatar(
                        backgroundColor: Colors.redAccent,
                        child: Icon(Icons.notifications,
                            color: Colors.white, size: 18),
                      ),
                      title: Text(activity["type"] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(activity["detail"] ?? ''),
                      trailing: Text(activity["time"] ?? '',
                          style: const TextStyle(color: Colors.grey)),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
