import 'package:freezed_annotation/freezed_annotation.dart';

import 'task.dart';
import 'note.dart';

part 'timeline_item.freezed.dart';

@freezed
class TimelineItem with _$TimelineItem {
  const factory TimelineItem.task(Task task) = TimelineItemTask;
  const factory TimelineItem.note(Note note) = TimelineItemNote;
}

extension TimelineItemExtension on TimelineItem {
  String get id => when(
    task: (task) => task.id,
    note: (note) => note.id,
  );
  
  DateTime get updatedAt => when(
    task: (task) => task.updatedAt,
    note: (note) => note.updatedAt,
  );
}
