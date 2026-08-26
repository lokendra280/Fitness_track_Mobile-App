import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/habit_proof_provider.dart';

/// Routes to the right proof-capture UI based on [proofType], and
/// returns `true` via Navigator.pop once the user confirms completion
/// (so the caller knows whether to actually mark the habit done).
Future<bool> showHabitCompletionSheet(
  BuildContext context,
  WidgetRef ref, {
  required String habitName,
  required HabitProofType proofType,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => proofType == HabitProofType.photo
        ? _PhotoProofSheet(habitName: habitName)
        : _WaterGlassSheet(habitName: habitName),
  );
  return result ?? false;
}

// ---------------------------------------------------------------------------
// Photo proof — camera capture with preview + retake
// ---------------------------------------------------------------------------

class _PhotoProofSheet extends ConsumerStatefulWidget {
  final String habitName;
  const _PhotoProofSheet({required this.habitName});

  @override
  ConsumerState<_PhotoProofSheet> createState() => _PhotoProofSheetState();
}

class _PhotoProofSheetState extends ConsumerState<_PhotoProofSheet> {
  File? _photo;
  bool _capturing = false;

  Future<void> _capture(ImageSource source) async {
    setState(() => _capturing = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _photo = File(picked.path));
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  void _confirm() {
    if (_photo == null) return;
    ref.read(habitProofProvider.notifier).update((state) => {
          ...state,
          widget.habitName: HabitProof(
            photoPath: _photo!.path,
            capturedAt: DateTime.now(),
          ),
        });
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Snap proof', style: text.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${widget.habitName} — take a quick photo to mark this complete.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 18),
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.4)),
                ),
                clipBehavior: Clip.antiAlias,
                child: _capturing
                    ? const Center(child: CircularProgressIndicator())
                    : _photo != null
                        ? Image.file(_photo!, fit: BoxFit.cover)
                        : Center(
                            child: Icon(Icons.camera_alt_outlined,
                                size: 40, color: scheme.outline),
                          ),
              ),
            ),
            const SizedBox(height: 16),
            if (_photo == null) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _capture(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _capture(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _photo = null),
                      child: const Text('Retake'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _confirm,
                      child: const Text('Mark complete'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Water glass proof — tap-to-fill glass counter
// ---------------------------------------------------------------------------

class _WaterGlassSheet extends ConsumerStatefulWidget {
  final String habitName;
  const _WaterGlassSheet({required this.habitName});

  @override
  ConsumerState<_WaterGlassSheet> createState() => _WaterGlassSheetState();
}

class _WaterGlassSheetState extends ConsumerState<_WaterGlassSheet> {
  static const _target =
      8; // TODO: pull from habit's real daily target if one exists
  int _filled = 0;

  void _confirm() {
    ref.read(habitProofProvider.notifier).update((state) => {
          ...state,
          widget.habitName: HabitProof(
            glassesFilled: _filled,
            capturedAt: DateTime.now(),
          ),
        });
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How much water?', style: text.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Tap the glasses you\'ve had today.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 24),
            Center(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: List.generate(_target, (i) {
                  final filled = i < _filled;
                  return GestureDetector(
                    onTap: () => setState(() => _filled = i + 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: filled
                            ? scheme.primary.withValues(alpha: 0.15)
                            : scheme.surfaceContainerLow,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              filled ? scheme.primary : scheme.outlineVariant,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.local_drink_rounded,
                        color: filled ? scheme.primary : scheme.outline,
                        size: 22,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '$_filled / $_target glasses',
                style: text.titleMedium?.copyWith(
                    color: scheme.primary, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _filled > 0 ? _confirm : null,
                child: const Text('Mark complete'),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
