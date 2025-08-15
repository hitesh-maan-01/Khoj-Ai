import 'package:flutter/material.dart';
import 'home_page.dart';
import 'detection_page.dart';
import 'setting_page.dart';
import 'reports_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    DashboardPage(), // from home_page.dart
    DetectionsPage(), // from detection_page.dart
    ReportsPage(), // from reports_page.dart
    SettingsPage(), // from setting_page.dart
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color.fromARGB(255, 42, 77, 255),
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: "Dashboard"),
            BottomNavigationBarItem(
                icon: Icon(Icons.remove_red_eye), label: "Detections"),
            BottomNavigationBarItem(
                icon: Icon(Icons.list_alt), label: "Reports"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
      ),
    );
  }
}
