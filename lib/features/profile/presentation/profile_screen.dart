import 'package:flutter/material.dart';

import '../../../presentation/theme/cozy_theme.dart';

/// Profile screen showing user information
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(LostTossedCozyTheme.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: LostTossedCozyTheme.goldenAmber.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: LostTossedCozyTheme.goldenAmber,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: LostTossedCozyTheme.goldenAmber,
              ),
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceLg),
            
            // User name
            const Text(
              'Community Explorer',
              style: LostTossedCozyTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceSm),
            
            LostTossedCozyTheme.createMicroCopy(
              "Every discovery adds to our shared story.",
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceXl),
            
            // Stats cards
            Row(
              children: [
                Expanded(
                  child: LostTossedCozyTheme.createDiscoveryCard(
                    child: Column(
                      children: [
                        const Text(
                          '0',
                          style: LostTossedCozyTheme.headingLarge,
                        ),
                        const Text(
                          'Discoveries',
                          style: LostTossedCozyTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: LostTossedCozyTheme.spaceMd),
                Expanded(
                  child: LostTossedCozyTheme.createDiscoveryCard(
                    child: Column(
                      children: [
                        const Text(
                          '0',
                          style: LostTossedCozyTheme.headingLarge,
                        ),
                        const Text(
                          'Contributions',
                          style: LostTossedCozyTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceXl),
            
            // Action buttons
            SizedBox(
              width: double.infinity,
              child: LostTossedCozyTheme.createCommunityButton(
                text: "Edit Profile",
                onPressed: () {
                  // TODO: Navigate to edit profile
                },
                icon: Icons.edit,
                isPrimary: true,
              ),
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceMd),
            
            SizedBox(
              width: double.infinity,
              child: LostTossedCozyTheme.createCommunityButton(
                text: "Settings",
                onPressed: () {
                  // TODO: Navigate to settings
                },
                icon: Icons.settings,
                isPrimary: false,
              ),
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceMd),
            
            SizedBox(
              width: double.infinity,
              child: LostTossedCozyTheme.createCommunityButton(
                text: "Sign Out",
                onPressed: () {
                  // TODO: Sign out
                },
                icon: Icons.logout,
                isAlert: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
