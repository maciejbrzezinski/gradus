// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoteImpl _$$NoteImplFromJson(Map<String, dynamic> json) => _$NoteImpl(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  content: json['content'] as String,
  type: $enumDecodeNullable(_$NoteTypeEnumMap, json['type']) ?? NoteType.text,
);

Map<String, dynamic> _$$NoteImplToJson(_$NoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'content': instance.content,
      'type': _$NoteTypeEnumMap[instance.type]!,
    };

const _$NoteTypeEnumMap = {
  NoteType.text: 'text',
  NoteType.headline1: 'headline1',
  NoteType.headline2: 'headline2',
  NoteType.headline3: 'headline3',
};
