import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurrence_rule.freezed.dart';

part 'recurrence_rule.g.dart';

@JsonEnum(alwaysCreate: true)
enum RecurrenceType { daily, weekly, monthly, yearly }

@freezed
class RecurrenceRule with _$RecurrenceRule {
  factory RecurrenceRule({required RecurrenceType type, required int interval, DateTime? endDate, int? count}) =
      _RecurrenceRule;

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) => _$RecurrenceRuleFromJson(json);
}
