import 'package:flutter/material.dart';
import 'package:habitflow/core/constants/constant_assets.dart';
import 'package:habitflow/features/bottom_navigation/widgets/bottom_navigation.dart';
import 'package:habitflow/features/dashboard/screens/dashboard_screen.dart';

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _index = 0;

  static final _items = [
    const AdaptiveNavItem(
      icon: Assets.home,
      activeIcon: Assets.home,
      label: 'Home',
    ),
    const AdaptiveNavItem(
      icon: Assets.profile,
      activeIcon: Assets.about,
      label: 'Me',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardScreen(),
          // your existing screens, e.g. DashboardScreen(), CalendarScreen(), ...
        ],
      ),
      bottomNavigationBar: AdaptiveBottomNavBar(
        items: _items,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
