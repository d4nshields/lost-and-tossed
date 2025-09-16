import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/submission_models.dart';
import '../../../../presentation/theme/cozy_theme.dart';

/// Form widget for collecting trace-specific details
class TraceDetailsForm extends StatefulWidget {
  final TraceDetailsDraft? initialDetails;
  final ValueChanged<TraceDetailsDraft> onDetailsChanged;

  const TraceDetailsForm({
    super.key,
    this.initialDetails,
    required this.onDetailsChanged,
  });

  @override
  State<TraceDetailsForm> createState() => _TraceDetailsFormState();
}

class _TraceDetailsFormState extends State<TraceDetailsForm> {
  TraceSurface? _surface;
  TraceFreshness? _freshness;
  TracePermanence? _permanence;
  double? _directionDeg;
  final _directionController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialDetails != null) {
      _surface = widget.initialDetails!.surface;
      _freshness = widget.initialDetails!.freshness;
      _permanence = widget.initialDetails!.permanence;
      _directionDeg = widget.initialDetails!.directionDeg;
      _directionController.text = _directionDeg?.toStringAsFixed(0) ?? '';
      _notesController.text = widget.initialDetails!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _directionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateDetails() {
    widget.onDetailsChanged(TraceDetailsDraft(
      surface: _surface,
      freshness: _freshness,
      permanence: _permanence,
      directionDeg: _directionDeg,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(LostTossedCozyTheme.spaceMd),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trace tip
            Container(
              padding: const EdgeInsets.all(LostTossedCozyTheme.spaceSm),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(LostTossedCozyTheme.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    size: 20,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: LostTossedCozyTheme.spaceXs),
                  Expanded(
                    child: Text(
                      'Pro tip: Wide shot + macro detail + scale object',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: LostTossedCozyTheme.spaceMd),

            // Surface selection
            Text(
              'Surface',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceXs),
            Wrap(
              spacing: LostTossedCozyTheme.spaceXs,
              runSpacing: LostTossedCozyTheme.spaceXs,
              children: TraceSurface.values.map((surface) {
                final isSelected = _surface == surface;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(surface.emoji),
                      const SizedBox(width: 4),
                      Text(surface.displayName),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _surface = selected ? surface : null;
                    });
                    _updateDetails();
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: LostTossedCozyTheme.spaceMd),

            // Freshness selection
            Text(
              'Freshness',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceXs),
            Wrap(
              spacing: LostTossedCozyTheme.spaceXs,
              children: TraceFreshness.values.map((freshness) {
                final isSelected = _freshness == freshness;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(freshness.emoji),
                      const SizedBox(width: 4),
                      Text(freshness.displayName),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _freshness = selected ? freshness : null;
                    });
                    _updateDetails();
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: LostTossedCozyTheme.spaceMd),

            // Permanence selection
            Text(
              'Permanence',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceXs),
            Wrap(
              spacing: LostTossedCozyTheme.spaceXs,
              children: TracePermanence.values.map((permanence) {
                final isSelected = _permanence == permanence;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(permanence.emoji),
                      const SizedBox(width: 4),
                      Text(permanence.displayName),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _permanence = selected ? permanence : null;
                    });
                    _updateDetails();
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: LostTossedCozyTheme.spaceMd),

            // Direction input
            Text(
              'Direction (optional)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceXs),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _directionController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _DirectionInputFormatter(),
                    ],
                    decoration: InputDecoration(
                      hintText: '0-359°',
                      prefixIcon: const Icon(Icons.explore),
                      suffixText: '°',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(LostTossedCozyTheme.radiusSm),
                      ),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _directionDeg = value.isEmpty ? null : double.tryParse(value);
                      });
                      _updateDetails();
                    },
                  ),
                ),
                const SizedBox(width: LostTossedCozyTheme.spaceSm),
                // Compass helper buttons
                IconButton(
                  onPressed: () => _setDirection(0),
                  icon: const Icon(Icons.north),
                  tooltip: 'North (0°)',
                ),
                IconButton(
                  onPressed: () => _setDirection(90),
                  icon: const Icon(Icons.east),
                  tooltip: 'East (90°)',
                ),
                IconButton(
                  onPressed: () => _setDirection(180),
                  icon: const Icon(Icons.south),
                  tooltip: 'South (180°)',
                ),
                IconButton(
                  onPressed: () => _setDirection(270),
                  icon: const Icon(Icons.west),
                  tooltip: 'West (270°)',
                ),
              ],
            ),

            const SizedBox(height: LostTossedCozyTheme.spaceMd),

            // Notes field
            Text(
              'Additional notes (optional)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceXs),
            TextField(
              controller: _notesController,
              maxLines: 2,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Any other observations about this trace...',
                hintStyle: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(LostTossedCozyTheme.radiusSm),
                ),
              ),
              onChanged: (_) => _updateDetails(),
            ),
          ],
          ),
        ),
      ),
    );
  }

  void _setDirection(double degrees) {
    setState(() {
      _directionDeg = degrees;
      _directionController.text = degrees.toStringAsFixed(0);
    });
    _updateDetails();
  }
}

/// Input formatter to ensure direction stays within 0-359 range
class _DirectionInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    
    final value = int.tryParse(newValue.text);
    if (value == null) return oldValue;
    
    if (value > 359) {
      return TextEditingValue(
        text: '359',
        selection: const TextSelection.collapsed(offset: 3),
      );
    }
    
    return newValue;
  }
}
