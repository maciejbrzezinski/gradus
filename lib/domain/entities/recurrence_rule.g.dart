// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurrence_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecurrenceRuleImpl _$$RecurrenceRuleImplFromJson(Map<String, dynamic> json) =>
    _$RecurrenceRuleImpl(
      type: $enumDecode(_$RecurrenceTypeEnumMap, json['type']),
      interval: (json['interval'] as num).toInt(),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      count: (json['count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$RecurrenceRuleImplToJson(
  _$RecurrenceRuleImpl instance,
) => <String, dynamic>{
  'type': _$RecurrenceTypeEnumMap[instance.type]!,
  'interval': instance.interval,
  'endDate': instance.endDate?.toIso8601String(),
  'count': instance.count,
};

const _$RecurrenceTypeEnumMap = {
  RecurrenceType.daily: 'daily',
  RecurrenceType.weekly: 'weekly',
  RecurrenceType.monthly: 'monthly',
  RecurrenceType.yearly: 'yearly',
};
