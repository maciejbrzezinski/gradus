// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Document _$DocumentFromJson(Map<String, dynamic> json) => _Document(
      id: json['id'] as String,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      title: json['title'] as String?,
      icon: json['icon'] as String?,
      iconColor: json['iconColor'] as String?,
      blocks:
          (json['blocks'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$DocumentToJson(_Document instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date?.toIso8601String(),
      'title': instance.title,
      'icon': instance.icon,
      'iconColor': instance.iconColor,
      'blocks': instance.blocks,
    };
