import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Settings
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Name and email
                    const Text(
                      'Explorer',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'user@example.com',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatColumn(label: 'Captures', value: '42'),
                        _StatColumn(label: 'Days Active', value: '15'),
                        _StatColumn(label: 'Favorites', value: '8'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Recent contributions
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Recent Contributions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  
                  // Recent items list
                  ..._recentItems.map((item) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.color.withOpacity(0.2),
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: 20,
                      ),
                    ),
                    title: Text(item.title),
                    subtitle: Text(item.description),
                    trailing: Text(
                      item.timeAgo,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  )),
                  
                  // View all button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Navigate to full contributions list
                        },
                        child: const Text('View All Contributions'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Profile actions
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy Settings'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Navigate to privacy settings
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Notifications'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Navigate to notifications settings
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Navigate to about
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red[400]),
                    title: Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.red[400]),
                    ),
                    onTap: () {
                      // TODO: Implement sign out
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text('Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // TODO: Implement actual sign out
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Sign out functionality coming soon!'),
                                  ),
                                );
                              },
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _RecentItem {
  const _RecentItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.timeAgo,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String timeAgo;
}

final _recentItems = [
  const _RecentItem(
    title: 'Solo Glove Adventure',
    description: 'Lost • Downtown Park',
    icon: Icons.help_outline,
    color: Color(0xFF3498DB),
    timeAgo: '2h ago',
  ),
  const _RecentItem(
    title: 'Event Poster Survivor',
    description: 'Posted • Main Street',
    icon: Icons.campaign_outlined,
    color: Color(0xFF2ECC71),
    timeAgo: '1d ago',
  ),
  const _RecentItem(
    title: 'Mysterious Object',
    description: 'Curious • Coffee Shop',
    icon: Icons.psychology_outlined,
    color: Color(0xFFE74C3C),
    timeAgo: '3d ago',
  ),
];
