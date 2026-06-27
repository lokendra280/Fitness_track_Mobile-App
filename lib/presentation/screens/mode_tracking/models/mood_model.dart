// mood_model.dart — Hive model, typeId = 5
// Run: flutter pub run build_runner build --delete-conflicting-outputs

import 'package:hive/hive.dart';
part 'mood_model.g.dart';

@HiveType(typeId: 5)
class MoodModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  int levelIndex; // MoodLevel.index
  @HiveField(2)
  List<int> tagIndexes; // MoodTag.index list
  @HiveField(3)
  String note;
  @HiveField(4)
  DateTime timestamp;
  @HiveField(5)
  bool isSynced;
  @HiveField(6)
  DateTime? updatedAt;

  MoodModel({
    required this.id,
    required this.levelIndex,
    required this.tagIndexes,
    required this.note,
    required this.timestamp,
    this.isSynced = false,
    this.updatedAt,
  });
}

// ── Manual adapter (use if skipping build_runner) ─────────────────────────────
//
// class MoodModelAdapter extends TypeAdapter<MoodModel> {
//   @override final int typeId = 5;
//
//   @override
//   MoodModel read(BinaryReader r) => MoodModel(
//     id:           r.readString(),
//     levelIndex:   r.readInt(),
//     tagIndexes:   r.readList().cast<int>(),
//     note:         r.readString(),
//     timestamp:    DateTime.fromMillisecondsSinceEpoch(r.readInt()),
//     isSynced:     r.readBool(),
//     updatedAt:    r.readBool()
//                     ? DateTime.fromMillisecondsSinceEpoch(r.readInt())
//                     : null,
//   );
//
//   @override
//   void write(BinaryWriter w, MoodModel o) {
//     w.writeString(o.id);
//     w.writeInt(o.levelIndex);
//     w.writeList(o.tagIndexes);
//     w.writeString(o.note);
//     w.writeInt(o.timestamp.millisecondsSinceEpoch);
//     w.writeBool(o.isSynced);
//     w.writeBool(o.updatedAt != null);
//     if (o.updatedAt != null) w.writeInt(o.updatedAt!.millisecondsSinceEpoch);
//   }
// }
