import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'new_message.dart';

class DetectionsPage extends StatefulWidget {
  const DetectionsPage({super.key});

  @override
  State<DetectionsPage> createState() => _DetectionsPageState();
}

class _DetectionsPageState extends State<DetectionsPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // dynamic list — replace with backend data
  final List<Map<String, dynamic>> _allDetections = [
    {
      "name": "Abhishek Verma",
      "age": 20,
      "caseId": "#CR-2024-001",
      "time": DateTime.now().subtract(const Duration(hours: 2)),
      "location": "Thikna Koni",
      "status": "Pending",
      "confidence": 95,
      "image": "https://randomuser.me/api/portraits/men/32.jpg"
    },
    {
      "name": "Piyush Pandit",
      "age": 20,
      "caseId": "#CR-2024-002",
      "time": DateTime.now().subtract(const Duration(hours: 5)),
      "location": "Deepalpur",
      "status": "Verified",
      "confidence": 89,
      "image": "https://randomuser.me/api/portraits/women/44.jpg"
    },
    {
      "name": "Shubham Yadav",
      "age": 21,
      "caseId": "#CR-2024-003",
      "time": DateTime.now().subtract(const Duration(days: 1)),
      "location": "Phosgarh karnal",
      "status": "Alerted",
      "confidence": 72,
      "image": "https://randomuser.me/api/portraits/men/22.jpg"
    },
    {
      "name": "Harsh Vardhan",
      "age": 21,
      "caseId": "#CR-2024-004",
      "time": DateTime.now().subtract(const Duration(days: 3)),
      "location": "Panipat",
      "status": "Pending",
      "confidence": 91,
      "image": "https://randomuser.me/api/portraits/women/50.jpg"
    },
    {
      "name": "Aryan Gupta",
      "age": 20,
      "caseId": "#CR-2024-005",
      "time": DateTime.now().subtract(const Duration(days: 5)),
      "location": "Delhi",
      "status": "Alerted",
      "confidence": 65,
      "image": "https://randomuser.me/api/portraits/men/40.jpg"
    },
    {
      "name": "Hitesh Maan",
      "age": 20,
      "caseId": "#CR-2024-005",
      "time": DateTime.now().subtract(const Duration(days: 5)),
      "location": "Karnal",
      "status": "Alerted",
      "confidence": 65,
      "image": "https://randomuser.me/api/portraits/men/32.jpg"
    },
  ];

  List<Map<String, dynamic>> _filtered = [];
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_allDetections);
    _searchController.addListener(_onSearchChanged);
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _animController.forward();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  Timer? _debounce;
  void _onSearchChanged() {
    final q = _searchController.text.trim().toLowerCase();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      setState(() {
        if (q.isEmpty) {
          _filtered = List.from(_allDetections);
        } else {
          _filtered = _allDetections.where((d) {
            final name = (d["name"] as String).toLowerCase();
            final id = (d["caseId"] as String).toLowerCase();
            return name.contains(q) || id.contains(q);
          }).toList();
        }
      });
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Verified':
        return Colors.green.shade100;
      case 'Pending':
        return Colors.orange.shade100;
      case 'Alerted':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _confidenceColor(int conf) {
    if (conf >= 85) return Colors.green;
    if (conf >= 70) return Colors.orange;
    return Colors.red;
  }

  String _timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('d MMM').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detections'),
        backgroundColor: const Color.fromARGB(255, 42, 77, 255),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 1,
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const MessagePage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              })
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by name or case ID...',
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        })
                    : null,
              ),
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ChoiceChip(
                    label: const Text('Location'),
                    selected: false,
                    onSelected: (v) {}),
                const SizedBox(width: 8),
                ChoiceChip(
                    label: const Text('Date'),
                    selected: false,
                    onSelected: (v) {}),
                const SizedBox(width: 8),
                ChoiceChip(
                    label: const Text('Confidence'),
                    selected: false,
                    onSelected: (v) {}),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Animated List
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              padding: const EdgeInsets.only(bottom: 24),
              itemBuilder: (context, index) {
                final item = _filtered[index];
                final anim = CurvedAnimation(
                    parent: _animController,
                    curve: Interval(0.0, 1.0, curve: Curves.easeOut));
                return FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0.02, 0), end: Offset.zero)
                        .animate(anim),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Hero(
                          tag: item["caseId"],
                          child: CircleAvatar(
                              radius: 26,
                              backgroundImage: NetworkImage(item["image"])),
                        ),
                        title: Text(item["name"],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Age: ${item["age"]} • Case ID: ${item["caseId"]}'),
                            Text(
                                '${_timeAgo(item["time"])} • ${item["location"]}'),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: _statusColor(item["status"]),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Text(item["status"],
                                      style: const TextStyle(fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Text('${item["confidence"]}%'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      DetectionDetailPage(data: item)));
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DetectionDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const DetectionDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final conf = data["confidence"] as int;
    return Scaffold(
      appBar: AppBar(title: Text(data["name"])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Hero(
                tag: data["caseId"],
                child: CircleAvatar(
                    radius: 72, backgroundImage: NetworkImage(data["image"]))),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                title: Text('Match Found',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green)),
                subtitle: const Text('Identity verified with high confidence'),
              ),
            ),
            const SizedBox(height: 12),
            _infoRow('Case ID', data['caseId']),
            _infoRow('Age', data['age'].toString()),
            _infoRow('Location', data['location']),
            _infoRow(
                'Last Seen', DateFormat.yMMMd().add_jm().format(data['time'])),
            _infoRow('Confidence', '$conf%'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.verified),
                label: const Text('Verify')),
            const SizedBox(height: 8),
            ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.notifications_active),
                label: const Text('Notify HQ')),
            const SizedBox(height: 8),
            OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.close),
                label: const Text('Dismiss')),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
              width: 120,
              child:
                  Text(label, style: const TextStyle(color: Colors.black54))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
