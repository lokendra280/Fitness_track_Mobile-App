import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/tracking_models.dart';
import '../../data/repositories/journey_repository_provider.dart';

const _angles = ['front', 'side', 'back'];

/// Copies the picked image into an app-private directory (never uploaded)
/// and records the path. Satisfies `progress_photos.private_storage`.
class ProgressPhotoController extends Notifier<List<ProgressPhoto>> {
  @override
  List<ProgressPhoto> build() => ref.read(journeyRepositoryProvider).progressPhotos();

  Future<void> capture(String angle, ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 90);
    if (picked == null) return;
    final dir = await getApplicationSupportDirectory();
    final privateDir = Directory('${dir.path}/progress_photos')..createSync(recursive: true);
    final dest = '${privateDir.path}/${DateTime.now().millisecondsSinceEpoch}_$angle.jpg';
    await File(picked.path).copy(dest);
    final photo = ProgressPhoto(date: DateTime.now(), angle: angle, path: dest);
    await ref.read(journeyRepositoryProvider).addProgressPhoto(photo);
    state = [...state, photo];
  }
}

final progressPhotoControllerProvider = NotifierProvider<ProgressPhotoController, List<ProgressPhoto>>(ProgressPhotoController.new);

/// front/side/back comparison — latest photo per angle, tap to pick a new one.
class PhotoComparisonWidget extends ConsumerWidget {
  const PhotoComparisonWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(progressPhotoControllerProvider);
    return Row(
      children: _angles.map((angle) {
        final latest = photos.where((p) => p.angle == angle).lastOrNull;
        return Expanded(
          child: GestureDetector(
            onTap: () => _pick(context, ref, angle),
            child: Container(
              margin: const EdgeInsets.all(4),
              height: 160,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
              child: latest == null
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.add_a_photo), Text(angle)]))
                  : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(latest.path), fit: BoxFit.cover)),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _pick(BuildContext context, WidgetRef ref, String angle) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'), onTap: () { ref.read(progressPhotoControllerProvider.notifier).capture(angle, ImageSource.camera); Navigator.pop(ctx); }),
          ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () { ref.read(progressPhotoControllerProvider.notifier).capture(angle, ImageSource.gallery); Navigator.pop(ctx); }),
        ]),
      ),
    );
  }
}
