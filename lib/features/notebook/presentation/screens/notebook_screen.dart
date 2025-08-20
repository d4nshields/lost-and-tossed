import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/theme/cozy_theme.dart';
import '../../../auth/providers/auth_providers.dart';

/// Notebook screen showing user's own finds
class NotebookScreen extends ConsumerWidget {
  const NotebookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Get current user if needed for filtering
    // final user = ref.watch(authUserProvider).value;
    final userProfile = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notebook'),
        actions: [
          IconButton(
            onPressed: () {
              // Filter/sort options
              _showFilterSheet(context);
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: userProfile.when(
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text('Loading profile...'),
            );
          }

          return CustomScrollView(
            slivers: [
              // Stats header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(LostTossedCozyTheme.spaceLg),
                  child: Column(
                    children: [
                      // User info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            backgroundImage: profile.avatarUrl != null
                                ? NetworkImage(profile.avatarUrl!)
                                : null,
                            child: profile.avatarUrl == null
                                ? Text(
                                    profile.handle[0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: LostTossedCozyTheme.spaceMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '@${profile.handle}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (profile.bio != null)
                                  Text(
                                    profile.bio!,
                                    style: theme.textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: LostTossedCozyTheme.spaceLg),
                      
                      // Stats cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Total Finds',
                              profile.submissionCount.toString(),
                              Icons.camera_alt_outlined,
                            ),
                          ),
                          const SizedBox(width: LostTossedCozyTheme.spaceMd),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'This Month',
                              '0', // Placeholder
                              Icons.calendar_today_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Category breakdown
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: LostTossedCozyTheme.spaceLg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Categories',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: LostTossedCozyTheme.spaceSm),
                      Wrap(
                        spacing: LostTossedCozyTheme.spaceXs,
                        children: [
                          _buildCategoryChip(context, 'Lost', 0),
                          _buildCategoryChip(context, 'Tossed', 0),
                          _buildCategoryChip(context, 'Posted', 0),
                          _buildCategoryChip(context, 'Marked', 0),
                          _buildCategoryChip(context, 'Curious', 0),
                          _buildCategoryChip(context, 'Traces', 0),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(
                child: SizedBox(height: LostTossedCozyTheme.spaceLg),
              ),
              
              // Finds grid
              if (profile.submissionCount == 0)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: LostTossedCozyTheme.spaceMd),
                        Text(
                          'Your notebook is empty',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: LostTossedCozyTheme.spaceSm),
                        Text(
                          'Start documenting finds to build your collection',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: LostTossedCozyTheme.spaceLg),
                        FilledButton.icon(
                          onPressed: () {
                            // Navigate to capture
                          },
                          icon: const Icon(Icons.photo_camera),
                          label: const Text('Capture First Find'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(LostTossedCozyTheme.spaceMd),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: LostTossedCozyTheme.spaceMd,
                      crossAxisSpacing: LostTossedCozyTheme.spaceMd,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildFindCard(context, index);
                      },
                      childCount: 0, // Will be replaced with actual finds
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: LostTossedCozyTheme.spaceMd),
              Text(
                'Failed to load profile',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: LostTossedCozyTheme.spaceSm),
              FilledButton(
                onPressed: () {
                  ref.invalidate(currentUserProfileProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(LostTossedCozyTheme.spaceMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(LostTossedCozyTheme.radiusMd),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: LostTossedCozyTheme.spaceXs),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String category, int count) {
    final theme = Theme.of(context);
    
    return Chip(
      label: Text('$category ($count)'),
      labelStyle: theme.textTheme.labelSmall,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildFindCard(BuildContext context, int index) {
    final theme = Theme.of(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigate to detail
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Container(
                color: theme.colorScheme.surfaceVariant,
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 32,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            
            // Info
            Padding(
              padding: const EdgeInsets.all(LostTossedCozyTheme.spaceSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Caption here',
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '2 days ago',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(LostTossedCozyTheme.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter & Sort',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: LostTossedCozyTheme.spaceLg),
              
              // Sort options
              Text(
                'Sort by',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: LostTossedCozyTheme.spaceSm),
              Wrap(
                spacing: LostTossedCozyTheme.spaceXs,
                children: [
                  ChoiceChip(
                    label: const Text('Newest'),
                    selected: true,
                    onSelected: (value) {},
                  ),
                  ChoiceChip(
                    label: const Text('Oldest'),
                    selected: false,
                    onSelected: (value) {},
                  ),
                  ChoiceChip(
                    label: const Text('Category'),
                    selected: false,
                    onSelected: (value) {},
                  ),
                ],
              ),
              
              const SizedBox(height: LostTossedCozyTheme.spaceLg),
              
              // Category filters
              Text(
                'Categories',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: LostTossedCozyTheme.spaceSm),
              Wrap(
                spacing: LostTossedCozyTheme.spaceXs,
                children: [
                  FilterChip(
                    label: const Text('Lost'),
                    selected: true,
                    onSelected: (value) {},
                  ),
                  FilterChip(
                    label: const Text('Tossed'),
                    selected: true,
                    onSelected: (value) {},
                  ),
                  FilterChip(
                    label: const Text('Posted'),
                    selected: true,
                    onSelected: (value) {},
                  ),
                  FilterChip(
                    label: const Text('Marked'),
                    selected: true,
                    onSelected: (value) {},
                  ),
                  FilterChip(
                    label: const Text('Curious'),
                    selected: true,
                    onSelected: (value) {},
                  ),
                  FilterChip(
                    label: const Text('Traces'),
                    selected: true,
                    onSelected: (value) {},
                  ),
                ],
              ),
              
              const SizedBox(height: LostTossedCozyTheme.spaceLg),
              
              // Apply button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
