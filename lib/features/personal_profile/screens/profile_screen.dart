import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/constants/app_string.dart';
import 'package:habitflow/core/router/app_router.dart';
import 'package:habitflow/features/personal_profile/providers/profile_view_data_provider.dart';
import 'package:habitflow/features/personal_profile/screens/widgets/profile_header_card.dart';
import 'package:habitflow/features/personal_profile/screens/widgets/profile_menu_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(profileViewDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppString.appName),
      ),
      body: data == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                children: [
                  ProfileHeaderCard(
                    data: data,
                    onEditTap: () => context.push(AppRoutes.aiCoach),
                  ),
                  const SizedBox(height: 22),
                  // ProfileMenuTile(
                  //   icon: Icons.workspace_premium_outlined,
                  //   label: 'Subscription',
                  //   onTap: () {},
                  // ),
                  // const SizedBox(height: 12),
                  // ProfileMenuTile(
                  //   icon: Icons.watch_outlined,
                  //   label: 'Connected Device',
                  //   onTap: () {},
                  // ),
                  // const SizedBox(height: 12),
                  // ProfileMenuTile(
                  //   icon: Icons.settings_outlined,
                  //   label: 'Settings',
                  //   onTap: () {},
                  // ),
                  // const SizedBox(height: 12),
                  ProfileMenuTile(
                    icon: Icons.logout_rounded,
                    label: 'Log Out',
                    isDestructive: true,
                    showChevron: false,
                    onTap: () {
                      // TODO: hook into your real sign-out flow.
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
