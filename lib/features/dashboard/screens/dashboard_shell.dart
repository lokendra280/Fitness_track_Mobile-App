import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_providers.dart';
import 'dashboard_screen.dart';
import 'today_progress_screen.dart';

/// Bottom-nav shell hosting Home / Progress (+ placeholder tabs), matching
/// the nav bar shown in both reference mocks. IndexedStack keeps each
/// screen's scroll position and animation state alive between tab switches.
class DashboardShell extends ConsumerWidget {
  const DashboardShell({super.key});

  static const _tabs = [
    (Icons.home_rounded, Icons.home_outlined, 'Home'),
    (Icons.show_chart_rounded, Icons.show_chart, 'Progress'),
    (Icons.assignment_rounded, Icons.assignment_outlined, 'Plan'),
    (Icons.check_circle_rounded, Icons.check_circle_outline, 'Habits'),
    (Icons.person_rounded, Icons.person_outline, 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          DashboardScreen(),
          TodayProgressScreen(),
          _PlaceholderTab(title: 'Plan'),
          _PlaceholderTab(title: 'Habits'),
          _PlaceholderTab(title: 'Profile'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => ref.read(bottomNavIndexProvider.notifier).state = i,
        items: [
          for (final tab in _tabs)
            BottomNavigationBarItem(
              icon: Icon(tab.$2),
              activeIcon: Icon(tab.$1),
              label: tab.$3,
            ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  const _PlaceholderTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text('$title — coming soon',
            style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
