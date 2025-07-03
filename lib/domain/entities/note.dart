import 'package:freezed_annotation/freezed_annotation.dart';

import 'note_type.dart';

part 'note.freezed.dart';

part 'note.g.dart';

@freezed
abstract class Note with _$Note {
  const factory Note({
    required String id,
    @Default('note') String type,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String content,
    @Default(NoteType.text) NoteType noteType,
  }) = _Note;

  factory Note.create({required String content, NoteType noteType = NoteType.text}) {
    final now = DateTime.now();
    return Note(
      id: 'note_${now.millisecondsSinceEpoch}',
      createdAt: now,
      updatedAt: now,
      content: content,
      noteType: noteType,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
