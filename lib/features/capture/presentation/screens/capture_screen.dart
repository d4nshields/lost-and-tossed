import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../../../presentation/theme/cozy_theme.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../domain/models/submission_models.dart';
import '../../providers/capture_providers.dart';
import '../widgets/trace_details_form.dart';

/// Enhanced capture screen with all required features
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> with WidgetsBindingObserver {
  final _captionController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _tagController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    // Initialize SharedPreferences - will be used later when needed
    await SharedPreferences.getInstance();
    
    // Load existing draft if any
    final captureState = ref.read(captureNotifierProvider);
    if (captureState.caption != null) {
      _captionController.text = captureState.caption!;
    }
    
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _captionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Save draft when app goes to background
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive) {
      _saveDraft();
    }
  }

  void _saveDraft() {
    final notifier = ref.read(captureNotifierProvider.notifier);
    notifier.setCaption(_captionController.text);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        ref.read(captureNotifierProvider.notifier).setImage(File(pickedFile.path));
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
    final captureState = ref.watch(captureNotifierProvider);
    final tagsAsync = ref.watch(tagsProvider);

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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

    return WillPopScope(
      onWillPop: () async {
        _saveDraft();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Document a Find'),
          actions: [
            if (captureState.imagePath != null && captureState.category != null)
              TextButton(
                onPressed: captureState.isSubmitting ? null : _submitFind,
                child: captureState.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit'),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(LostTossedCozyTheme.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              _buildImageSection(theme, captureState),

              const SizedBox(height: LostTossedCozyTheme.spaceLg),

              // Category selection
              _buildCategorySection(theme, captureState),

              // Show trace details form if traces category is selected
              if (captureState.category == SubmissionCategory.traces) ...[
                const SizedBox(height: LostTossedCozyTheme.spaceLg),
                TraceDetailsForm(
                  initialDetails: captureState.traceDetails,
                  onDetailsChanged: (details) {
                    ref.read(captureNotifierProvider.notifier).updateTraceDetails(details);
                  },
                ),
              ],

              const SizedBox(height: LostTossedCozyTheme.spaceLg),

              // Tags section
              _buildTagsSection(theme, captureState, tagsAsync),

              const SizedBox(height: LostTossedCozyTheme.spaceLg),

              // Caption
              _buildCaptionSection(theme),

              const SizedBox(height: LostTossedCozyTheme.spaceLg),

              // License selection
              _buildLicenseSection(theme, captureState),

              const SizedBox(height: LostTossedCozyTheme.spaceLg),

              // Disposal status
              _buildDisposalSection(theme, captureState),

              const SizedBox(height: LostTossedCozyTheme.spaceXl),

              // Submit button
              _buildSubmitButton(theme, captureState),

              const SizedBox(height: LostTossedCozyTheme.spaceLg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(ThemeData theme, CaptureState state) {
    if (state.imagePath == null) {
      return InkWell(
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
                  'Document Your Find',
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
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(LostTossedCozyTheme.radiusMd),
          child: Image.file(
            File(state.imagePath!),
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
    );
  }

  Widget _buildCategorySection(ThemeData theme, CaptureState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What did you find?',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: LostTossedCozyTheme.spaceSm),
        Wrap(
          spacing: LostTossedCozyTheme.spaceXs,
          runSpacing: LostTossedCozyTheme.spaceXs,
          children: SubmissionCategory.values.map((category) {
            final isSelected = state.category == category;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(category.emoji),
                  const SizedBox(width: 4),
                  Text(category.displayName),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(captureNotifierProvider.notifier).setCategory(category);
                }
              },
            );
          }).toList(),
        ),
        if (state.category != null) ...[
          const SizedBox(height: LostTossedCozyTheme.spaceXs),
          Text(
            state.category!.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTagsSection(ThemeData theme, CaptureState state, AsyncValue<List<Tag>> tagsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add playful tags',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: LostTossedCozyTheme.spaceSm),
        tagsAsync.when(
          data: (tags) {
            final availableTags = tags.map((t) => t.name).toList();
            // Add some suggested tags if not in database
            final suggestedTags = [
              'shiny', 'tiny', 'mystery', 'colorful', 'vintage', 
              'forgotten', 'weathered', 'handmade', 'broken', 'unusual'
            ];
            final allTags = {...availableTags, ...suggestedTags}.toList()..sort();
            
            return Wrap(
              spacing: LostTossedCozyTheme.spaceXs,
              runSpacing: LostTossedCozyTheme.spaceXs,
              children: allTags.map((tag) {
                final isSelected = state.selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    ref.read(captureNotifierProvider.notifier).toggleTag(tag);
                  },
                );
              }).toList(),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Failed to load tags: $error'),
        ),
        const SizedBox(height: LostTossedCozyTheme.spaceSm),
        // Custom tag input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: 'Add custom tag...',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(LostTossedCozyTheme.radiusSm),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    final cleanTag = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_-]'), '');
                    if (cleanTag.isNotEmpty) {
                      ref.read(captureNotifierProvider.notifier).toggleTag(cleanTag);
                      _tagController.clear();
                    }
                  }
                },
              ),
            ),
            const SizedBox(width: LostTossedCozyTheme.spaceSm),
            IconButton(
              onPressed: () {
                final value = _tagController.text;
                if (value.isNotEmpty) {
                  final cleanTag = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_-]'), '');
                  if (cleanTag.isNotEmpty) {
                    ref.read(captureNotifierProvider.notifier).toggleTag(cleanTag);
                    _tagController.clear();
                  }
                }
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCaptionSection(ThemeData theme) {
    final playfulHints = [
      "A glove begins its solo adventure...",
      "Poster's still here, but the event is long gone.",
      "The snack that left only a clue.",
      "Someone's story, half-told.",
      "Nature's temporary art installation.",
      "Urban archaeology in progress.",
    ];
    final hint = playfulHints[DateTime.now().millisecondsSinceEpoch % playfulHints.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            hintText: hint,
            hintStyle: TextStyle(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LostTossedCozyTheme.radiusMd),
            ),
          ),
          style: const TextStyle(fontStyle: FontStyle.italic),
          onChanged: (value) {
            ref.read(captureNotifierProvider.notifier).setCaption(value);
          },
        ),
      ],
    );
  }

  Widget _buildLicenseSection(ThemeData theme, CaptureState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'License',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: LostTossedCozyTheme.spaceSm),
        SegmentedButton<LicenseType>(
          segments: LicenseType.values.map((license) {
            return ButtonSegment(
              value: license,
              label: Text(license.displayName),
              tooltip: license.description,
            );
          }).toList(),
          selected: {state.license},
          onSelectionChanged: (Set<LicenseType> selection) {
            ref.read(captureNotifierProvider.notifier).setLicense(selection.first);
          },
        ),
        const SizedBox(height: LostTossedCozyTheme.spaceSm),
        Text(
          state.license.description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDisposalSection(ThemeData theme, CaptureState state) {
    return SwitchListTile(
      title: const Text('Disposed'),
      subtitle: const Text('I cleaned this up after documenting'),
      value: state.disposed,
      onChanged: (value) {
        ref.read(captureNotifierProvider.notifier).setDisposed(value);
      },
      tileColor: state.disposed 
          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LostTossedCozyTheme.radiusMd),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme, CaptureState state) {
    final canSubmit = state.imagePath != null && 
                      state.category != null && 
                      !state.isSubmitting;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: canSubmit ? _submitFind : null,
        icon: state.isSubmitting 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.upload),
        label: Text(state.isSubmitting ? 'Submitting...' : 'Submit Find'),
      ),
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
            if (ref.read(captureNotifierProvider).imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(captureNotifierProvider.notifier).setImage(null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFind() async {
    try {
      await ref.read(captureNotifierProvider.notifier).submit();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Find submitted successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
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
