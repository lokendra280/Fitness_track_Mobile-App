import 'package:flutter/material.dart';
import 'package:habitflow/core/constants/constant_assets.dart';
import 'package:habitflow/core/constants/app_string.dart';
import 'package:habitflow/features/bottom_navigation/widgets/bottom_navigation.dart';
import 'package:habitflow/features/dashboard/screens/dashboard_screen.dart';
import 'package:habitflow/features/journey_setup/screens/journey_about_section.dart';
import 'package:habitflow/features/personal_profile/screens/personal_profile_screen.dart';
import 'package:habitflow/features/weekly_review/review_screens.dart';

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
      label: AppString.home,
    ),
    const AdaptiveNavItem(
      icon: Assets.state,
      activeIcon: Assets.state,
      label: AppString.progress,
    ),
    const AdaptiveNavItem(
      icon: Assets.profile,
      activeIcon: Assets.profile,
      label: AppString.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardScreen(),
          ReportsScreen(),
          // ProfileScreen(),
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
