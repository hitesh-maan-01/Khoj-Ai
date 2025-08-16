import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Initial state for the toggles
  bool push = true;
  bool email = false;
  bool sms = false;

  final Color accentColor = const Color.fromARGB(255, 13, 71, 161);

  // A list of notification settings to make the UI dynamic
  late final List<Map<String, dynamic>> _notificationSettings;

  @override
  void initState() {
    super.initState();
    _notificationSettings = [
      {
        'title': 'Push Notifications',
        'subtitle': 'Receive real-time alerts',
        'value': push,
        'icon': Icons.notifications_active_outlined,
        'onChanged': (v) => setState(() => push = v),
      },
      {
        'title': 'Email Alerts',
        'subtitle': 'Receive email summaries',
        'value': email,
        'icon': Icons.email_outlined,
        'onChanged': (v) => setState(() => email = v),
      },
      {
        'title': 'SMS Alerts',
        'subtitle': 'Receive urgent SMS',
        'value': sms,
        'icon': Icons.sms_outlined,
        'onChanged': (v) => setState(() => sms = v),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 13, 71, 161),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Animated list of settings
            ..._notificationSettings.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> setting = entry.value;

              return _AnimatedSettingTile(
                index: index,
                title: setting['title'],
                subtitle: setting['subtitle'],
                value: setting['value'],
                icon: setting['icon'],
                accentColor: accentColor,
                onChanged: setting['onChanged'],
              );
            }),

            const SizedBox(height: 30),

            // Save button with animation
            _AnimatedSaveButton(
              onPressed: _savePreferences,
              accentColor: accentColor,
            ),
          ],
        ),
      ),
    );
  }

  void _savePreferences() {
    // In a real app, you would save these values to a backend or local storage.
    // For this example, we just show a Snackbar.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification preferences saved!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }
}

// A widget to animate the entrance of each setting tile
class _AnimatedSettingTile extends StatefulWidget {
  final int index;
  final String title;
  final String subtitle;
  final bool value;
  final IconData icon;
  final Color accentColor;
  final Function(bool) onChanged;

  const _AnimatedSettingTile({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  _AnimatedSettingTileState createState() => _AnimatedSettingTileState();
}

class _AnimatedSettingTileState extends State<_AnimatedSettingTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start the animation with a staggered delay
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          elevation: widget.value ? 4 : 1,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: SwitchListTile(
            title: Text(widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.subtitle),
            secondary: Icon(
              widget.icon,
              color: widget.value ? widget.accentColor : Colors.grey,
            ),
            value: widget.value,
            onChanged: widget.onChanged,
            activeColor: widget.accentColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }
}

// A widget to animate the save button
class _AnimatedSaveButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color accentColor;

  const _AnimatedSaveButton({
    required this.onPressed,
    required this.accentColor,
  });

  @override
  _AnimatedSaveButtonState createState() => _AnimatedSaveButtonState();
}

class _AnimatedSaveButtonState extends State<_AnimatedSaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    _controller.forward();
  }

  void _onTapUp(_) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: widget.accentColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'Save Preferences',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
