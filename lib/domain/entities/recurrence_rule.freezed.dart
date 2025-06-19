// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurrence_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RecurrenceRule _$RecurrenceRuleFromJson(Map<String, dynamic> json) {
  return _RecurrenceRule.fromJson(json);
}

/// @nodoc
mixin _$RecurrenceRule {
  RecurrenceType get type => throw _privateConstructorUsedError;
  int get interval => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;

  /// Serializes this RecurrenceRule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecurrenceRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecurrenceRuleCopyWith<RecurrenceRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecurrenceRuleCopyWith<$Res> {
  factory $RecurrenceRuleCopyWith(
    RecurrenceRule value,
    $Res Function(RecurrenceRule) then,
  ) = _$RecurrenceRuleCopyWithImpl<$Res, RecurrenceRule>;
  @useResult
  $Res call({RecurrenceType type, int interval, DateTime? endDate, int? count});
}

/// @nodoc
class _$RecurrenceRuleCopyWithImpl<$Res, $Val extends RecurrenceRule>
    implements $RecurrenceRuleCopyWith<$Res> {
  _$RecurrenceRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecurrenceRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? interval = null,
    Object? endDate = freezed,
    Object? count = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as RecurrenceType,
            interval: null == interval
                ? _value.interval
                : interval // ignore: cast_nullable_to_non_nullable
                      as int,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            count: freezed == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecurrenceRuleImplCopyWith<$Res>
    implements $RecurrenceRuleCopyWith<$Res> {
  factory _$$RecurrenceRuleImplCopyWith(
    _$RecurrenceRuleImpl value,
    $Res Function(_$RecurrenceRuleImpl) then,
  ) = __$$RecurrenceRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({RecurrenceType type, int interval, DateTime? endDate, int? count});
}

/// @nodoc
class __$$RecurrenceRuleImplCopyWithImpl<$Res>
    extends _$RecurrenceRuleCopyWithImpl<$Res, _$RecurrenceRuleImpl>
    implements _$$RecurrenceRuleImplCopyWith<$Res> {
  __$$RecurrenceRuleImplCopyWithImpl(
    _$RecurrenceRuleImpl _value,
    $Res Function(_$RecurrenceRuleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecurrenceRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? interval = null,
    Object? endDate = freezed,
    Object? count = freezed,
  }) {
    return _then(
      _$RecurrenceRuleImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as RecurrenceType,
        interval: null == interval
            ? _value.interval
            : interval // ignore: cast_nullable_to_non_nullable
                  as int,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        count: freezed == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecurrenceRuleImpl implements _RecurrenceRule {
  const _$RecurrenceRuleImpl({
    required this.type,
    required this.interval,
    this.endDate,
    this.count,
  });

  factory _$RecurrenceRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecurrenceRuleImplFromJson(json);

  @override
  final RecurrenceType type;
  @override
  final int interval;
  @override
  final DateTime? endDate;
  @override
  final int? count;

  @override
  String toString() {
    return 'RecurrenceRule(type: $type, interval: $interval, endDate: $endDate, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecurrenceRuleImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, interval, endDate, count);

  /// Create a copy of RecurrenceRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecurrenceRuleImplCopyWith<_$RecurrenceRuleImpl> get copyWith =>
      __$$RecurrenceRuleImplCopyWithImpl<_$RecurrenceRuleImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecurrenceRuleImplToJson(this);
  }
}

abstract class _RecurrenceRule implements RecurrenceRule {
  const factory _RecurrenceRule({
    required final RecurrenceType type,
    required final int interval,
    final DateTime? endDate,
    final int? count,
  }) = _$RecurrenceRuleImpl;

  factory _RecurrenceRule.fromJson(Map<String, dynamic> json) =
      _$RecurrenceRuleImpl.fromJson;

  @override
  RecurrenceType get type;
  @override
  int get interval;
  @override
  DateTime? get endDate;
  @override
  int? get count;

  /// Create a copy of RecurrenceRule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecurrenceRuleImplCopyWith<_$RecurrenceRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
