// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskImpl _$$TaskImplFromJson(Map<String, dynamic> json) => _$TaskImpl(
  id: json['id'] as String,
  type: $enumDecodeNullable(_$ItemTypeEnumMap, json['type']) ?? ItemType.task,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  title: json['title'] as String,
  isCompleted: json['isCompleted'] as bool? ?? false,
  description: json['description'] as String?,
  recurrence: json['recurrence'] == null
      ? null
      : RecurrenceRule.fromJson(json['recurrence'] as Map<String, dynamic>),
  nextRecurringTaskId: json['nextRecurringTaskId'] as String?,
  previousRecurringTaskId: json['previousRecurringTaskId'] as String?,
);

Map<String, dynamic> _$$TaskImplToJson(_$TaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ItemTypeEnumMap[instance.type]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'title': instance.title,
      'isCompleted': instance.isCompleted,
      'description': instance.description,
      'recurrence': instance.recurrence?.toJson(),
      'nextRecurringTaskId': instance.nextRecurringTaskId,
      'previousRecurringTaskId': instance.previousRecurringTaskId,
    };

const _$ItemTypeEnumMap = {
  ItemType.text: 'text',
  ItemType.headline1: 'headline1',
  ItemType.headline2: 'headline2',
  ItemType.headline3: 'headline3',
  ItemType.task: 'task',
  ItemType.note: 'note',
  ItemType.bulletPoint: 'bulletPoint',
};
