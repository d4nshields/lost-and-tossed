import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

/// Main scaffold with bottom navigation for the app
///
/// This widget provides the main navigation structure with a bottom tab bar
/// and handles navigation between the main sections of the app.
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final currentRoute = RouteHelper.getCurrentRoute(context);

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: _NavBarItem(
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore,
                label: 'Discover',
                isActive: RouteHelper.isOnTab(context, AppRoutes.home),
                onTap: () => context.go(AppRoutes.home),
              ),
            ),
            Expanded(
              child: _NavBarItem(
                icon: Icons.search_outlined,
                activeIcon: Icons.search,
                label: 'Search',
                isActive: RouteHelper.isOnTab(context, AppRoutes.search),
                onTap: () => context.go(AppRoutes.search),
              ),
            ),
            const SizedBox(width: 40), // Space for FAB
            Expanded(
              child: _NavBarItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isActive: RouteHelper.isOnTab(context, AppRoutes.profile),
                onTap: () => context.go(AppRoutes.profile),
              ),
            ),
            Expanded(
              child: _NavBarItem(
                icon: Icons.menu,
                activeIcon: Icons.menu,
                label: 'More',
                isActive: false,
                onTap: () => _showMoreOptions(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.go(AppRoutes.capture),
      child: const Icon(Icons.camera_alt),
      tooltip: 'Document a discovery',
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _MoreOptionsSheet(),
    );
  }
}

/// Individual navigation bar item
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurface.withOpacity(0.6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive ? activeColor : inactiveColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// More options bottom sheet
class _MoreOptionsSheet extends StatelessWidget {
  const _MoreOptionsSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'More Options',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceLg),
          _MoreOption(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'App preferences and privacy',
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings
            },
          ),
          _MoreOption(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to help
            },
          ),
          _MoreOption(
            icon: Icons.info_outline,
            title: 'About Lost & Tossed',
            subtitle: 'App version and information',
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
          _MoreOption(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            onTap: () {
              Navigator.pop(context);
              _confirmSignOut(context);
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Lost & Tossed',
      applicationVersion: '1.0.0',
      applicationLegalese:
          '© 2024 Lost & Tossed. Made with curiosity and care.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'A playful community field guide for documenting found, discarded, or posted public objects. Help build a map of our shared spaces.',
        ),
      ],
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement sign out
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

/// More options item
class _MoreOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MoreOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
    );
  }
}
