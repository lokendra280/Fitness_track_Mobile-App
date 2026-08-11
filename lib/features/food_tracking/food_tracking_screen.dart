import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/tracking_models.dart';
import '../../data/repositories/journey_repository_provider.dart';
import '../ai_plan/providers/ai_plan_provider.dart';

final foodLogProvider = NotifierProvider.family<FoodLogController, List<FoodEntry>, DateTime>(FoodLogController.new);

class FoodLogController extends FamilyNotifier<List<FoodEntry>, DateTime> {
  @override
  List<FoodEntry> build(DateTime day) => ref.read(journeyRepositoryProvider).foodEntriesFor(day);

  Future<void> addEntry(FoodEntry e) async {
    await ref.read(journeyRepositoryProvider).saveFoodEntry(arg, e);
    await ref.read(journeyRepositoryProvider).recordRecentFood(e.name);
    await ref.read(journeyRepositoryProvider).recordActivity('meal_tracking');
    state = [...state, e];
  }
}

final recentFoodsProvider = Provider<List<String>>((ref) => ref.watch(journeyRepositoryProvider).recentFoodNames());
final favoriteFoodsProvider = Provider<List<String>>((ref) => ref.watch(journeyRepositoryProvider).favoriteFoodNames());

class FavoriteFoodController extends Notifier<List<String>> {
  @override
  List<String> build() => ref.read(journeyRepositoryProvider).favoriteFoodNames();
  Future<void> toggle(String name) async {
    await ref.read(journeyRepositoryProvider).toggleFavoriteFood(name);
    state = ref.read(journeyRepositoryProvider).favoriteFoodNames();
  }
}

final favoriteFoodControllerProvider = NotifierProvider<FavoriteFoodController, List<String>>(FavoriteFoodController.new);

/// Phase 4b: AI food scanner — camera/gallery photo → Gemini vision →
/// candidate entries. Result must be user-confirmed before it's saved.
final aiFoodScanProvider = FutureProvider.autoDispose.family<List<FoodEntry>, File>((ref, image) async {
  final gemini = ref.watch(geminiServiceProvider);
  return gemini.detectFood(await image.readAsBytes());
});

const _mealIcons = {'breakfast': Icons.wb_sunny_outlined, 'lunch': Icons.lunch_dining, 'dinner': Icons.dinner_dining, 'snack': Icons.cookie_outlined};

class FoodTrackingScreen extends ConsumerWidget {
  const FoodTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = DateTime.now();
    final entries = ref.watch(foodLogProvider(day));
    final totalCal = entries.fold<double>(0, (s, e) => s + e.calories);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary, colors.primary.withValues(alpha: 0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TODAY', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${totalCal.round()}', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, height: 1)),
                        const Padding(padding: EdgeInsets.only(bottom: 6, left: 4), child: Text('kcal logged', style: TextStyle(color: Colors.white70, fontSize: 14))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: _ScanButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Scan food',
                        subtitle: 'AI-powered',
                        onTap: () => _scan(context, ref, day, ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ScanButton(
                        icon: Icons.photo_library_rounded,
                        label: 'Upload photo',
                        subtitle: 'From gallery',
                        onTap: () => _scan(context, ref, day, ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            if (entries.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.restaurant_menu, size: 48, color: colors.outline),
                    const SizedBox(height: 12),
                    Text('Nothing logged yet', style: TextStyle(color: colors.outline)),
                  ]),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList.builder(
                  itemCount: entries.length,
                  itemBuilder: (_, i) => _FoodCard(entry: entries[i], colors: colors),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addManualEntry(context, ref, day),
        icon: const Icon(Icons.add),
        label: const Text('Add manually'),
      ),
    );
  }

  Future<void> _scan(BuildContext context, WidgetRef ref, DateTime day, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null || !context.mounted) return;
    final file = File(picked.path);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ScanResultSheet(image: file, day: day),
    );
  }

  void _addManualEntry(BuildContext context, WidgetRef ref, DateTime day) {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final fiberCtrl = TextEditingController();
    final servingCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    String meal = 'breakfast';
    final recents = ref.read(recentFoodsProvider);
    final favorites = ref.read(favoriteFoodsProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Add food', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (favorites.isNotEmpty) ...[
                const Text('Favorites', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Wrap(spacing: 6, children: favorites.map((f) => ActionChip(avatar: const Icon(Icons.star, size: 14), label: Text(f), onPressed: () => nameCtrl.text = f)).toList()),
                const SizedBox(height: 8),
              ],
              if (recents.isNotEmpty) ...[
                const Text('Recent', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Wrap(spacing: 6, children: recents.take(8).map((f) => ActionChip(label: Text(f), onPressed: () => nameCtrl.text = f)).toList()),
                const SizedBox(height: 12),
              ],
              DropdownButtonFormField<String>(
                value: meal,
                items: _mealIcons.keys.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setState(() => meal = v ?? meal),
                decoration: const InputDecoration(labelText: 'Meal', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Food name', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: calCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calories', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: servingCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Serving size (g)', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()))),
              ]),
              const SizedBox(height: 12),
              TextField(controller: fiberCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fiber (g)', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final cal = double.tryParse(calCtrl.text);
                      if (nameCtrl.text.isEmpty || cal == null) return;
                      ref.read(foodLogProvider(day).notifier).addEntry(FoodEntry(
                            mealType: meal, name: nameCtrl.text, calories: cal,
                            fiber: double.tryParse(fiberCtrl.text), servingSize: double.tryParse(servingCtrl.text), quantity: double.tryParse(qtyCtrl.text),
                          ));
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Add'),
                  ),
                ),
                IconButton(
                  icon: Icon(favorites.contains(nameCtrl.text) ? Icons.star : Icons.star_border),
                  onPressed: nameCtrl.text.isEmpty ? null : () => ref.read(favoriteFoodControllerProvider.notifier).toggle(nameCtrl.text),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final VoidCallback onTap;
  const _ScanButton({required this.icon, required this.label, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                child: Icon(icon, color: colors.onPrimaryContainer),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(subtitle, style: TextStyle(fontSize: 11, color: colors.outline)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final FoodEntry entry;
  final ColorScheme colors;
  const _FoodCard({required this.entry, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: colors.secondaryContainer, borderRadius: BorderRadius.circular(12)),
            child: Icon(_mealIcons[entry.mealType] ?? Icons.restaurant, color: colors.onSecondaryContainer, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(entry.mealType, style: TextStyle(fontSize: 12, color: colors.outline)),
              ],
            ),
          ),
          Text('${entry.calories.round()} kcal', style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Confirmation sheet shown after a scan — nothing is saved until the user
/// taps "Add all" (or edits/removes items first).
class _ScanResultSheet extends ConsumerStatefulWidget {
  final File image;
  final DateTime day;
  const _ScanResultSheet({required this.image, required this.day});

  @override
  ConsumerState<_ScanResultSheet> createState() => _ScanResultSheetState();
}

class _ScanResultSheetState extends ConsumerState<_ScanResultSheet> {
  List<FoodEntry>? _editable;

  @override
  Widget build(BuildContext context) {
    final scan = ref.watch(aiFoodScanProvider(widget.image));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollCtrl) {
          return scan.when(
            loading: () => Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 40),
              ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(widget.image, height: 140, fit: BoxFit.cover)),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              const Text('Analyzing your photo…'),
              const SizedBox(height: 40),
            ]),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 12),
                Text('$e', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
              ]),
            ),
            data: (results) {
              _editable ??= List.of(results);
              if (_editable!.isEmpty) {
                return const Padding(padding: EdgeInsets.all(32), child: Text('No food detected — try a clearer photo or add manually.'));
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(children: [
                      const Text('Detected items', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const Spacer(),
                      Text('${_editable!.fold<double>(0, (s, e) => s + e.calories).round()} kcal total'),
                    ]),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _editable!.length,
                      itemBuilder: (_, i) {
                        final e = _editable![i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(e.name),
                            subtitle: Text('${e.mealType} · ${e.calories.round()} kcal'),
                            trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _editable!.removeAt(i))),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: FilledButton(
                      onPressed: () async {
                        for (final e in _editable!) {
                          await ref.read(foodLogProvider(widget.day).notifier).addEntry(e);
                        }
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      child: Text('Add all (${_editable!.length})'),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
