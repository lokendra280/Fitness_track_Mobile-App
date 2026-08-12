import 'package:flutter/material.dart';

/// Top greeting row: "Good morning, Alex! 👋" + bell with unread badge.
class GreetingHeader extends StatelessWidget {
  final String userName;
  final int notificationCount;
  final VoidCallback? onNotificationsTap;

  const GreetingHeader({
    super.key,
    required this.userName,
    required this.notificationCount,
    this.onNotificationsTap,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_greeting, $userName! 👋',
                  style: textTheme.headlineMedium),
              const SizedBox(height: 2),
              Text("Keep going, you're doing great!",
                  style: textTheme.bodyMedium),
            ],
          ),
        ),
        _NotificationBell(
          count: notificationCount,
          onTap: onNotificationsTap,
        ),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;
  const _NotificationBell({required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded),
              if (count > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: AnimatedScale(
                    scale: 1,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
