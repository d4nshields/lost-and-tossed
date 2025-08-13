import 'package:flutter/material.dart';

import '../../../presentation/theme/cozy_theme.dart';

/// Capture screen for documenting new discoveries
class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Discovery')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt,
              size: 64,
              color: LostTossedCozyTheme.terracotta,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceLg),
            const Text(
              'Document a Discovery',
              style: LostTossedCozyTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceMd),
            LostTossedCozyTheme.createMicroCopy(
              "What curious thing caught your eye today?",
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceXl),
            
            // Category selection buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: LostTossedCozyTheme.spaceLg),
              child: Wrap(
                spacing: LostTossedCozyTheme.spaceSm,
                runSpacing: LostTossedCozyTheme.spaceSm,
                alignment: WrapAlignment.center,
                children: [
                  LostTossedCozyTheme.createCommunityButton(
                    text: "Lost",
                    onPressed: () {},
                    category: 'lost',
                    isPrimary: false,
                  ),
                  LostTossedCozyTheme.createCommunityButton(
                    text: "Tossed",
                    onPressed: () {},
                    category: 'tossed',
                    isPrimary: false,
                  ),
                  LostTossedCozyTheme.createCommunityButton(
                    text: "Posted",
                    onPressed: () {},
                    category: 'posted',
                    isPrimary: false,
                  ),
                  LostTossedCozyTheme.createCommunityButton(
                    text: "Marked",
                    onPressed: () {},
                    category: 'marked',
                    isPrimary: false,
                  ),
                  LostTossedCozyTheme.createCommunityButton(
                    text: "Curious",
                    onPressed: () {},
                    category: 'curious',
                    isPrimary: false,
                  ),
                  LostTossedCozyTheme.createCommunityButton(
                    text: "Traces",
                    onPressed: () {},
                    category: 'traces',
                    isPrimary: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceXl),
            
            // Primary action button
            LostTossedCozyTheme.createCommunityButton(
              text: "Start Documenting",
              onPressed: () {
                // TODO: Launch camera
              },
              icon: Icons.camera_alt,
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }
}
