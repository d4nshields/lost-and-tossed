import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/theme/cozy_theme.dart';
import '../../../auth/providers/auth_providers.dart';

/// Explore screen showing map and feed views
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Tossed'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.map_outlined),
              text: 'Map',
            ),
            Tab(
              icon: Icon(Icons.view_stream_outlined),
              text: 'Feed',
            ),
          ],
        ),
        actions: [
          // User avatar/profile button
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: LostTossedCozyTheme.spaceSm),
              child: PopupMenuButton<String>(
                onSelected: (String value) {
                  switch (value) {
                    case 'profile':
                      // Navigate to profile
                      break;
                    case 'settings':
                      // Navigate to settings
                      break;
                    case 'signout':
                      ref.read(authNotifierProvider.notifier).signOut();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text('Profile'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings_outlined),
                      title: Text('Settings'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'signout',
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Sign Out'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    (user.email?[0] ?? 'U').toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Map view
          _buildMapView(context),
          // Feed view
          _buildFeedView(context),
        ],
      ),
    );
  }

  Widget _buildMapView(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        // Placeholder for map
        Container(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: LostTossedCozyTheme.spaceMd),
                Text(
                  'Map View',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: LostTossedCozyTheme.spaceSm),
                Text(
                  'Explore finds around you',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Filter chips
        Positioned(
          top: LostTossedCozyTheme.spaceMd,
          left: LostTossedCozyTheme.spaceMd,
          right: LostTossedCozyTheme.spaceMd,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Lost'),
                  selected: true,
                  onSelected: (bool value) {},
                ),
                const SizedBox(width: LostTossedCozyTheme.spaceXs),
                FilterChip(
                  label: const Text('Tossed'),
                  selected: false,
                  onSelected: (bool value) {},
                ),
                const SizedBox(width: LostTossedCozyTheme.spaceXs),
                FilterChip(
                  label: const Text('Posted'),
                  selected: false,
                  onSelected: (bool value) {},
                ),
                const SizedBox(width: LostTossedCozyTheme.spaceXs),
                FilterChip(
                  label: const Text('Marked'),
                  selected: false,
                  onSelected: (bool value) {},
                ),
                const SizedBox(width: LostTossedCozyTheme.spaceXs),
                FilterChip(
                  label: const Text('Curious'),
                  selected: false,
                  onSelected: (bool value) {},
                ),
                const SizedBox(width: LostTossedCozyTheme.spaceXs),
                FilterChip(
                  label: const Text('Traces'),
                  selected: false,
                  onSelected: (bool value) {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedView(BuildContext context) {
    final theme = Theme.of(context);
    
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh feed
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(LostTossedCozyTheme.spaceMd),
        itemCount: 10, // Placeholder count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: LostTossedCozyTheme.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(LostTossedCozyTheme.radiusMd),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(LostTossedCozyTheme.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category chip
                      Chip(
                        label: Text(_getCategoryForIndex(index)),
                        labelStyle: theme.textTheme.labelSmall,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      
                      const SizedBox(height: LostTossedCozyTheme.spaceSm),
                      
                      // Caption with micro-copy style
                      Text(
                        _getMicroCopyForIndex(index),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      
                      const SizedBox(height: LostTossedCozyTheme.spaceSm),
                      
                      // Metadata
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '~150m away',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: LostTossedCozyTheme.spaceMd),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '2 hours ago',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getCategoryForIndex(int index) {
    final categories = ['Lost', 'Tossed', 'Posted', 'Marked', 'Curious', 'Traces'];
    return categories[index % categories.length];
  }

  String _getMicroCopyForIndex(int index) {
    final microCopies = [
      'A glove begins its solo adventure',
      'The snack that left only a clue',
      'Poster\'s still here, but the event is long gone',
      'Someone marked their territory with chalk',
      'A curious arrangement of bottle caps',
      'Footprints in fresh snow, heading nowhere',
      'Keys waiting for their owner\'s return',
      'Yesterday\'s news, literally',
      'A sticker\'s shadow remains after removal',
      'Tire tracks telling a story of haste',
    ];
    return microCopies[index % microCopies.length];
  }
}
