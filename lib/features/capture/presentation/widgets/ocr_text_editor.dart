import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/theme/cozy_theme.dart';

/// Widget for displaying and editing OCR-extracted text from lost lists
class OCRTextEditor extends ConsumerStatefulWidget {
  final String? extractedText;
  final ValueChanged<String> onTextChanged;
  final VoidCallback? onRetryOCR;

  const OCRTextEditor({
    super.key,
    this.extractedText,
    required this.onTextChanged,
    this.onRetryOCR,
  });

  @override
  ConsumerState<OCRTextEditor> createState() => _OCRTextEditorState();
}

class _OCRTextEditorState extends ConsumerState<OCRTextEditor> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.extractedText ?? '');
  }

  @override
  void didUpdateWidget(OCRTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.extractedText != widget.extractedText && 
        widget.extractedText != null &&
        !_isEditing) {
      _controller.text = widget.extractedText!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(LostTossedCozyTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.text_fields,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: LostTossedCozyTheme.spaceSm),
                Expanded(
                  child: Text(
                    'Extracted List Text',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                if (widget.onRetryOCR != null)
                  TextButton.icon(
                    onPressed: widget.onRetryOCR,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceSm),
            
            if (widget.extractedText == null || widget.extractedText!.isEmpty)
              _buildEmptyState(theme)
            else
              _buildTextEditor(theme),
            
            const SizedBox(height: LostTossedCozyTheme.spaceSm),
            
            Text(
              _isEditing 
                  ? 'Editing mode - make corrections as needed'
                  : 'Tap the text to edit and correct any OCR errors',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(LostTossedCozyTheme.spaceLg),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(LostTossedCozyTheme.radiusSm),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.document_scanner,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceSm),
            Text(
              'No text detected',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try retaking the photo with better lighting',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextEditor(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditing = true;
        });
      },
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 120,
          maxHeight: 300,
        ),
        child: TextField(
          controller: _controller,
          maxLines: null,
          readOnly: !_isEditing,
          decoration: InputDecoration(
            filled: true,
            fillColor: _isEditing 
                ? theme.colorScheme.surface 
                : theme.colorScheme.surface.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LostTossedCozyTheme.radiusSm),
              borderSide: BorderSide(
                color: _isEditing 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LostTossedCozyTheme.radiusSm),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(LostTossedCozyTheme.spaceMd),
            suffixIcon: _isEditing
                ? IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      widget.onTextChanged(_controller.text);
                      setState(() {
                        _isEditing = false;
                      });
                      // Remove focus
                      FocusScope.of(context).unfocus();
                    },
                  )
                : const Icon(Icons.edit, size: 18),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            height: 1.5,
          ),
          onChanged: (text) {
            if (_isEditing) {
              widget.onTextChanged(text);
            }
          },
          onEditingComplete: () {
            setState(() {
              _isEditing = false;
            });
          },
        ),
      ),
    );
  }
}

/// Preview widget showing privacy blur areas
class PrivacyBlurPreview extends StatelessWidget {
  final String imagePath;
  final List<dynamic> blurAreas;
  final VoidCallback? onReprocess;

  const PrivacyBlurPreview({
    super.key,
    required this.imagePath,
    required this.blurAreas,
    this.onReprocess,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      margin: const EdgeInsets.symmetric(vertical: LostTossedCozyTheme.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(LostTossedCozyTheme.spaceMd),
            child: Row(
              children: [
                Icon(
                  Icons.privacy_tip,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: LostTossedCozyTheme.spaceSm),
                Expanded(
                  child: Text(
                    'Privacy Protection Applied',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                if (onReprocess != null)
                  TextButton(
                    onPressed: onReprocess,
                    child: const Text('Reprocess'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),
          
          if (blurAreas.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(LostTossedCozyTheme.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBlurSummary(theme),
                  const SizedBox(height: LostTossedCozyTheme.spaceSm),
                  Text(
                    'The image has been automatically processed to protect privacy. '
                    'Faces, license plates, and other sensitive information have been blurred.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBlurSummary(ThemeData theme) {
    // Count blur areas by type
    final Map<String, int> counts = {};
    for (final area in blurAreas) {
      final type = area is Map ? (area['type'] ?? 'unknown') : 'unknown';
      counts[type] = (counts[type] ?? 0) + 1;
    }

    final items = <Widget>[];
    counts.forEach((type, count) {
      final (icon, label) = _getTypeDisplay(type);
      items.add(
        Chip(
          avatar: Icon(icon, size: 16),
          label: Text('$count $label'),
          visualDensity: VisualDensity.compact,
        ),
      );
    });

    return Wrap(
      spacing: LostTossedCozyTheme.spaceXs,
      runSpacing: LostTossedCozyTheme.spaceXs,
      children: items,
    );
  }

  (IconData, String) _getTypeDisplay(String type) {
    switch (type) {
      case 'face':
        return (Icons.face, 'faces');
      case 'licensePlate':
        return (Icons.directions_car, 'plates');
      case 'sensitiveText':
        return (Icons.text_fields, 'text');
      case 'object':
        return (Icons.crop_free, 'objects');
      default:
        return (Icons.blur_on, 'areas');
    }
  }
}

/// Processing status indicator
class ProcessingStatusIndicator extends StatelessWidget {
  final String status;
  final double? progress;

  const ProcessingStatusIndicator({
    super.key,
    required this.status,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(LostTossedCozyTheme.spaceMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(LostTossedCozyTheme.radiusMd),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              value: progress,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: LostTossedCozyTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (progress != null)
                  Text(
                    '${(progress! * 100).toInt()}% complete',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
