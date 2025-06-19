// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DayData {
  Day get day => throw _privateConstructorUsedError;
  List<Task> get tasks => throw _privateConstructorUsedError;
  List<Note> get notes => throw _privateConstructorUsedError;

  /// Create a copy of DayData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DayDataCopyWith<DayData> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DayDataCopyWith<$Res> {
  factory $DayDataCopyWith(DayData value, $Res Function(DayData) then) =
      _$DayDataCopyWithImpl<$Res, DayData>;
  @useResult
  $Res call({Day day, List<Task> tasks, List<Note> notes});

  $DayCopyWith<$Res> get day;
}

/// @nodoc
class _$DayDataCopyWithImpl<$Res, $Val extends DayData>
    implements $DayDataCopyWith<$Res> {
  _$DayDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DayData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? day = null, Object? tasks = null, Object? notes = null}) {
    return _then(
      _value.copyWith(
            day: null == day
                ? _value.day
                : day // ignore: cast_nullable_to_non_nullable
                      as Day,
            tasks: null == tasks
                ? _value.tasks
                : tasks // ignore: cast_nullable_to_non_nullable
                      as List<Task>,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as List<Note>,
          )
          as $Val,
    );
  }

  /// Create a copy of DayData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DayCopyWith<$Res> get day {
    return $DayCopyWith<$Res>(_value.day, (value) {
      return _then(_value.copyWith(day: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DayDataImplCopyWith<$Res> implements $DayDataCopyWith<$Res> {
  factory _$$DayDataImplCopyWith(
    _$DayDataImpl value,
    $Res Function(_$DayDataImpl) then,
  ) = __$$DayDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Day day, List<Task> tasks, List<Note> notes});

  @override
  $DayCopyWith<$Res> get day;
}

/// @nodoc
class __$$DayDataImplCopyWithImpl<$Res>
    extends _$DayDataCopyWithImpl<$Res, _$DayDataImpl>
    implements _$$DayDataImplCopyWith<$Res> {
  __$$DayDataImplCopyWithImpl(
    _$DayDataImpl _value,
    $Res Function(_$DayDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DayData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? day = null, Object? tasks = null, Object? notes = null}) {
    return _then(
      _$DayDataImpl(
        day: null == day
            ? _value.day
            : day // ignore: cast_nullable_to_non_nullable
                  as Day,
        tasks: null == tasks
            ? _value._tasks
            : tasks // ignore: cast_nullable_to_non_nullable
                  as List<Task>,
        notes: null == notes
            ? _value._notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as List<Note>,
      ),
    );
  }
}

/// @nodoc

class _$DayDataImpl implements _DayData {
  const _$DayDataImpl({
    required this.day,
    required final List<Task> tasks,
    required final List<Note> notes,
  }) : _tasks = tasks,
       _notes = notes;

  @override
  final Day day;
  final List<Task> _tasks;
  @override
  List<Task> get tasks {
    if (_tasks is EqualUnmodifiableListView) return _tasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tasks);
  }

  final List<Note> _notes;
  @override
  List<Note> get notes {
    if (_notes is EqualUnmodifiableListView) return _notes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notes);
  }

  @override
  String toString() {
    return 'DayData(day: $day, tasks: $tasks, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DayDataImpl &&
            (identical(other.day, day) || other.day == day) &&
            const DeepCollectionEquality().equals(other._tasks, _tasks) &&
            const DeepCollectionEquality().equals(other._notes, _notes));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    day,
    const DeepCollectionEquality().hash(_tasks),
    const DeepCollectionEquality().hash(_notes),
  );

  /// Create a copy of DayData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DayDataImplCopyWith<_$DayDataImpl> get copyWith =>
      __$$DayDataImplCopyWithImpl<_$DayDataImpl>(this, _$identity);
}

abstract class _DayData implements DayData {
  const factory _DayData({
    required final Day day,
    required final List<Task> tasks,
    required final List<Note> notes,
  }) = _$DayDataImpl;

  @override
  Day get day;
  @override
  List<Task> get tasks;
  @override
  List<Note> get notes;

  /// Create a copy of DayData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DayDataImplCopyWith<_$DayDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
