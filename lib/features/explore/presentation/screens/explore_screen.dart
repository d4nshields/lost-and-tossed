import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../presentation/theme/cozy_theme.dart';
import '../../../../shared/models/submission_models.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../providers/feed_providers.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check for tab query parameter (e.g., from capture submission)
    // Wrapped in try-catch for tests that don't use GoRouter
    try {
      final queryParams = GoRouterState.of(context).uri.queryParameters;
      if (queryParams['tab'] == 'feed') {
        // Switch to feed tab and refresh
        _tabController.animateTo(1);
        ref.read(feedProvider.notifier).refresh();
      }
    } catch (_) {
      // GoRouter not available (e.g., in tests)
    }
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
    final feedState = ref.watch(feedProvider);

    // Show loading state
    if (feedState.isLoading && feedState.submissions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error state
    if (feedState.error != null && feedState.submissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceMd),
            Text(
              'Failed to load feed',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceSm),
            Text(
              feedState.error!,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceMd),
            ElevatedButton(
              onPressed: () => ref.read(feedProvider.notifier).loadSubmissions(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show empty state
    if (feedState.submissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceMd),
            Text(
              'No finds yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceSm),
            Text(
              'Be the first to document something!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(feedProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(LostTossedCozyTheme.spaceMd),
        itemCount: feedState.submissions.length + (feedState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Load more trigger
          if (index >= feedState.submissions.length) {
            // Trigger load more when reaching the end
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(feedProvider.notifier).loadMore();
            });
            return const Padding(
              padding: EdgeInsets.all(LostTossedCozyTheme.spaceMd),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final submission = feedState.submissions[index];
          return _buildSubmissionCard(context, submission);
        },
      ),
    );
  }

  Widget _buildSubmissionCard(BuildContext context, Submission submission) {
    final theme = Theme.of(context);
    final imageUrl = submission.imageUrls.displayUrl;
    final timeAgo = _formatTimeAgo(submission.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: LostTossedCozyTheme.spaceMd),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (imageUrl.isNotEmpty)
            SizedBox(
              height: 200,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.surfaceVariant,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.surfaceVariant,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 200,
              color: theme.colorScheme.surfaceVariant,
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
                // Category chip with emoji
                Chip(
                  avatar: Text(submission.category.emoji),
                  label: Text(submission.category.displayName),
                  labelStyle: theme.textTheme.labelSmall,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),

                const SizedBox(height: LostTossedCozyTheme.spaceSm),

                // Caption or micro-copy
                Text(
                  submission.caption?.isNotEmpty == true
                      ? submission.caption!
                      : submission.category.microCopy,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: submission.caption?.isNotEmpty == true
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: LostTossedCozyTheme.spaceSm),

                // Tags
                if (submission.tags != null && submission.tags!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: LostTossedCozyTheme.spaceSm),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: submission.tags!.take(5).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#$tag',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // Metadata row
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (submission.disposed == true) ...[
                      const SizedBox(width: LostTossedCozyTheme.spaceMd),
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Disposed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
