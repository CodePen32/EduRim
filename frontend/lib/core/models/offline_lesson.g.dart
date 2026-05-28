// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_lesson.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineLessonAdapter extends TypeAdapter<OfflineLesson> {
  @override
  final int typeId = 0;

  @override
  OfflineLesson read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineLesson(
      lessonId: fields[0] as int,
      subjectId: fields[1] as int,
      title: fields[2] as String,
      description: fields[3] as String,
      durationMinutes: fields[4] as int,
      localVideoPath: fields[5] as String,
      localSummaryPath: fields[6] as String,
      localCoverPath: fields[7] as String,
      originalVideoUrl: fields[8] as String,
      originalSummaryUrl: fields[9] as String,
      originalCoverUrl: fields[10] as String,
      downloadedAt: fields[11] as DateTime,
      totalSizeBytes: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineLesson obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.lessonId)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.durationMinutes)
      ..writeByte(5)
      ..write(obj.localVideoPath)
      ..writeByte(6)
      ..write(obj.localSummaryPath)
      ..writeByte(7)
      ..write(obj.localCoverPath)
      ..writeByte(8)
      ..write(obj.originalVideoUrl)
      ..writeByte(9)
      ..write(obj.originalSummaryUrl)
      ..writeByte(10)
      ..write(obj.originalCoverUrl)
      ..writeByte(11)
      ..write(obj.downloadedAt)
      ..writeByte(12)
      ..write(obj.totalSizeBytes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineLessonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
