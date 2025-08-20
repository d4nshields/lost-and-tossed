import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../presentation/theme/cozy_theme.dart';
import '../../../auth/providers/auth_providers.dart';

/// Capture screen for documenting finds
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final _captionController = TextEditingController();
  final _imagePicker = ImagePicker();
  
  File? _imageFile;
  String _selectedCategory = 'curious';
  bool _isDisposed = false;
  String _license = 'CC_BY_NC';

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAuthenticated = ref.watch(authUserProvider).value != null;

    if (!isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Capture'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text('Please sign in to capture finds'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  // Navigate to login
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Find'),
        actions: [
          if (_imageFile != null)
            TextButton(
              onPressed: _submitFind,
              child: const Text('Submit'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(LostTossedCozyTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            if (_imageFile == null)
              InkWell(
                onTap: () => _showImageSourceDialog(context),
                borderRadius: BorderRadius.circular(LostTossedCozyTheme.radiusMd),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(LostTossedCozyTheme.radiusMd),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: LostTossedCozyTheme.spaceSm),
                        Text(
                          'Add Photo',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to capture or select',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(LostTossedCozyTheme.radiusMd),
                    child: Image.file(
                      _imageFile!,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filled(
                      onPressed: () => _showImageSourceDialog(context),
                      icon: const Icon(Icons.edit),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
                        foregroundColor: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: LostTossedCozyTheme.spaceLg),

            // Category selection
            Text(
              'Category',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceSm),
            Wrap(
              spacing: LostTossedCozyTheme.spaceXs,
              children: [
                _buildCategoryChip('lost', 'Lost', '🧤'),
                _buildCategoryChip('tossed', 'Tossed', '🥤'),
                _buildCategoryChip('posted', 'Posted', '📋'),
                _buildCategoryChip('marked', 'Marked', '✏️'),
                _buildCategoryChip('curious', 'Curious', '🤔'),
                _buildCategoryChip('traces', 'Traces', '👣'),
              ],
            ),

            const SizedBox(height: LostTossedCozyTheme.spaceLg),

            // Caption
            Text(
              'Caption',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceSm),
            TextField(
              controller: _captionController,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Add a playful caption...',
                hintStyle: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(LostTossedCozyTheme.radiusMd),
                ),
              ),
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),

            const SizedBox(height: LostTossedCozyTheme.spaceLg),

            // Disposal status
            SwitchListTile(
              title: const Text('Disposed'),
              subtitle: const Text('I cleaned this up after documenting'),
              value: _isDisposed,
              onChanged: (value) {
                setState(() {
                  _isDisposed = value;
                });
              },
            ),

            const SizedBox(height: LostTossedCozyTheme.spaceLg),

            // License selection
            Text(
              'License',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceSm),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'CC_BY_NC',
                  label: Text('CC BY-NC'),
                  tooltip: 'Creative Commons Attribution-NonCommercial',
                ),
                ButtonSegment(
                  value: 'CC0',
                  label: Text('CC0'),
                  tooltip: 'Public Domain',
                ),
              ],
              selected: {_license},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _license = selection.first;
                });
              },
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceSm),
            Text(
              _license == 'CC0'
                  ? 'Public domain - no rights reserved'
                  : 'Others can share with attribution, non-commercial only',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: LostTossedCozyTheme.spaceXl),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _imageFile != null ? _submitFind : null,
                icon: const Icon(Icons.upload),
                label: const Text('Submit Find'),
              ),
            ),

            const SizedBox(height: LostTossedCozyTheme.spaceLg),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label, String emoji) {
    final isSelected = _selectedCategory == value;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imageFile != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _imageFile = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFind() async {
    if (_imageFile == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    try {
      // TODO: Implement actual submission logic
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close capture screen
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Find submitted successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
