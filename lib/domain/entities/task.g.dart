// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskImpl _$$TaskImplFromJson(Map<String, dynamic> json) => _$TaskImpl(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  title: json['title'] as String,
  isCompleted: json['isCompleted'] as bool? ?? false,
  description: json['description'] as String?,
  recurrence: json['recurrence'] == null
      ? null
      : RecurrenceRule.fromJson(json['recurrence'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$TaskImplToJson(_$TaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'title': instance.title,
      'isCompleted': instance.isCompleted,
      'description': instance.description,
      'recurrence': instance.recurrence,
    };
