// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoteImpl _$$NoteImplFromJson(Map<String, dynamic> json) => _$NoteImpl(
  id: json['id'] as String,
  type: json['type'] as String? ?? 'note',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  content: json['content'] as String,
  noteType:
      $enumDecodeNullable(_$NoteTypeEnumMap, json['noteType']) ?? NoteType.text,
);

Map<String, dynamic> _$$NoteImplToJson(_$NoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'content': instance.content,
      'noteType': _$NoteTypeEnumMap[instance.noteType]!,
    };

const _$NoteTypeEnumMap = {
  NoteType.text: 'text',
  NoteType.headline1: 'headline1',
  NoteType.headline2: 'headline2',
  NoteType.headline3: 'headline3',
};
