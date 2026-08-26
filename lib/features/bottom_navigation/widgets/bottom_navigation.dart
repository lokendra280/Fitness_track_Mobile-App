import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:habitflow/core/common_widget/common_svg.dart';

/// Describes one destination in the bottom nav bar.
class AdaptiveNavItem {
  const AdaptiveNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final String icon;
  final String activeIcon;
  final String label;
}

/// Shared sizing so both the Material and Cupertino bars read as the same
/// "component" to the user, just re-skinned per platform.
class _NavBarMetrics {
  static const double iconSize = 24;
  static const double barHeight = 64;
}

/// A bottom navigation bar that renders as Material 3 on Android/Fuchsia
/// and as a native-style translucent tab bar on iOS/macOS, using
/// `flutter_adaptive_ui`'s `AdaptiveDesign` to pick the design language.
/// Falls back to the Material style for any other platform.
class AdaptiveBottomNavBar extends StatelessWidget {
  const AdaptiveBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AdaptiveNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  void _handleTap(int index) {
    if (index != currentIndex) {
      // Subtle tactile confirmation on selection — matches native nav bars
      // on both platforms rather than a silent tap.
      HapticFeedback.selectionClick();
    }
    onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveDesign(
      defaultBuilder: (context, screen) => _MaterialNavBar(
        items: items,
        currentIndex: currentIndex,
        onTap: _handleTap,
      ),
      material: (context, screen) => _MaterialNavBar(
        items: items,
        currentIndex: currentIndex,
        onTap: _handleTap,
      ),
      cupertino: (context, screen) => _CupertinoNavBar(
        items: items,
        currentIndex: currentIndex,
        onTap: _handleTap,
      ),
      fluent: (context, screen) => _MaterialNavBar(
        items: items,
        currentIndex: currentIndex,
        onTap: _handleTap,
      ),
    );
  }
}

class _MaterialNavBar extends StatelessWidget {
  const _MaterialNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AdaptiveNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      // A soft top shadow reads as "elevated surface" the way native
      // Android bottom bars sit above content, without a hard divider line.
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: _NavBarMetrics.barHeight,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return theme.textTheme.labelSmall?.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            );
          }),
          indicatorShape: const StadiumBorder(),
          indicatorColor: theme.colorScheme.primary.withOpacity(0.12),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          animationDuration: const Duration(milliseconds: 350),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final item in items)
              NavigationDestination(
                icon: CommonSvgWidget(
                  svgName: item.icon,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: _NavBarMetrics.iconSize,
                ),
                selectedIcon: CommonSvgWidget(
                  svgName: item.activeIcon,
                  color: theme.colorScheme.primary,
                  height: _NavBarMetrics.iconSize,
                ),
                label: item.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _CupertinoNavBar extends StatelessWidget {
  const _CupertinoNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AdaptiveNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final activeColor = cupertinoTheme.primaryColor;
    const inactiveColor = CupertinoColors.inactiveGray;

    return CupertinoTabBar(
      currentIndex: currentIndex,
      onTap: onTap,
      height: _NavBarMetrics.barHeight,
      // Opacity below 1 triggers CupertinoTabBar's built-in backdrop blur,
      // giving the frosted-glass look iOS users expect instead of a flat fill.
      backgroundColor: cupertinoTheme.barBackgroundColor.withOpacity(0.94),
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      border: Border(
        top: BorderSide(
          color: CupertinoColors.separator.resolveFrom(context),
          width: 0.5, // hairline, matches native iOS tab bar divider
        ),
      ),
      items: [
        for (final item in items)
          BottomNavigationBarItem(
            icon: CommonSvgWidget(
              svgName: item.icon,
              color: inactiveColor,
              height: _NavBarMetrics.iconSize,
            ),
            activeIcon: CommonSvgWidget(
              svgName: item.activeIcon,
              color: activeColor,
              height: _NavBarMetrics.iconSize,
            ),
            label: item.label,
          ),
      ],
    );
  }
}
