import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivas/providers/user_provider.dart';
import 'package:nivas/providers/project_provider.dart';
import 'package:nivas/screens/group/groups_list_screen.dart';
import 'package:nivas/screens/admin/admin_dashboard_screen.dart';
import 'package:nivas/screens/home/profile_screen.dart';
import 'package:nivas/screens/home/settings_screen.dart';
import 'package:nivas/widgets/project_switcher.dart';
import 'package:nivas/utils/constants.dart';

/// Home screen with app drawer navigation
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final currentProject = ref.watch(currentProjectProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nivas'),
        backgroundColor: Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        actions: [
          // Project switcher in app bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: currentProject.when(
                data: (project) => project != null
                    ? const CompactProjectSwitcher()
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context, ref, currentUser.value),
      body: const GroupsListScreen(),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, dynamic currentUser) {
    final projectId = ref.watch(currentProjectIdProvider);
    final isSuperAdmin = projectId != null ? ref.watch(isSuperAdminProvider(projectId)) : false;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Color(AppColors.primaryBlue),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                currentUser?.displayName[0].toUpperCase() ?? 'U',
                style: TextStyle(
                  fontSize: 32,
                  color: Color(AppColors.primaryBlue),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountName: Text(
              currentUser?.displayName ?? 'User',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              currentUser?.phoneNumber ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Groups
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Groups'),
            onTap: () {
              Navigator.pop(context);
              // Already on groups screen
            },
          ),

          // Admin Dashboard (if super admin)
          if (isSuperAdmin)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminDashboardScreen(),
                  ),
                );
              },
            ),

          const Divider(),

          // Profile
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),

          // Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 Nivas. All rights reserved.',
                children: [
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appTagline,
                    style: TextStyle(color: Color(AppColors.textSecondary)),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
