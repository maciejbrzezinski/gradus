// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Block _$BlockFromJson(Map<String, dynamic> json) => _Block(
  id: json['id'] as String,
  type: json['type'] as String,
  content: json['content'],
  metadata: json['metadata'] as Map<String, dynamic>,
  children:
      (json['children'] as List<dynamic>)
          .map((e) => Block.fromJson(e as Map<String, dynamic>))
          .toList(),
  projectId: json['projectId'] as String?,
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$BlockToJson(_Block instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'content': instance.content,
  'metadata': instance.metadata,
  'children': instance.children,
  'projectId': instance.projectId,
  'date': instance.date?.toIso8601String(),
};
