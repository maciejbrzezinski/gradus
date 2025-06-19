// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DayImpl _$$DayImplFromJson(Map<String, dynamic> json) => _$DayImpl(
  date: DateTime.parse(json['date'] as String),
  projectId: json['projectId'] as String,
  itemIds: (json['itemIds'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$$DayImplToJson(_$DayImpl instance) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'projectId': instance.projectId,
  'itemIds': instance.itemIds,
};
