import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/features/food_tracking/bar_code_scanner.dart';
import 'package:habitflow/features/food_tracking/providers/food_tracking_provider.dart';
import 'package:habitflow/features/food_tracking/widgets/food_scan_result.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/scan_button.dart';
import 'widgets/food_card.dart';
import 'widgets/add_food_sheet.dart';

class FoodTrackingScreen extends ConsumerWidget {
  const FoodTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = DateTime.now();
    final entries = ref.watch(foodLogProvider(day));
    final totalCal = entries.fold<double>(0, (s, e) => s + e.calories);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Track Calories',
          )),
      backgroundColor: scheme.surfaceContainerLowest,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _CalorieHeader(totalCal: totalCal)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Row(children: [
                Expanded(
                    child: ScanButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Scan food',
                        subtitle: 'AI-powered',
                        onTap: () =>
                            _scan(context, ref, day, ImageSource.camera))),
                const SizedBox(width: 12),
                // Expanded(
                //   child: ScanButton(
                //     icon: Icons.photo_library_rounded,
                //     label: 'Upload photo',
                //     subtitle: 'From gallery',
                //     onTap: () => _scan(context, ref, day, ImageSource.gallery),
                //   ),
                // ),
                Expanded(
                  child: ScanButton(
                      icon: Icons.scanner_rounded,
                      label: "BarCode Scanner",
                      subtitle: "From Camera Or Gallery",
                      onTap: () => context.go('/barcode')),
                )
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          if (entries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.restaurant_menu, size: 48, color: scheme.outline),
                  const SizedBox(height: 12),
                  Text('Nothing logged yet', style: text.bodyMedium),
                ]),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList.builder(
                  itemCount: entries.length,
                  itemBuilder: (_, i) => FoodCard(entry: entries[i])),
            ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddFoodSheet(context, ref, day),
        icon: const Icon(Icons.add),
        label: const Text('Add manually'),
      ),
    );
  }

  Future<void> _scan(BuildContext context, WidgetRef ref, DateTime day,
      ImageSource source) async {
    final picked =
        await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null || !context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FoodScanResultSheet(image: File(picked.path), day: day),
    );
  }
}

class _CalorieHeader extends StatelessWidget {
  final double totalCal;
  const _CalorieHeader({required this.totalCal});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [scheme.primary, scheme.primary.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: scheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TODAY',
            style: text.labelMedium
                ?.copyWith(color: Colors.white70, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${totalCal.round()}',
              style:
                  text.displayLarge?.copyWith(color: Colors.white, height: 1)),
          Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 4),
              child: Text('kcal logged',
                  style: text.bodyMedium?.copyWith(color: Colors.white70))),
        ]),
      ]),
    );
  }
}
