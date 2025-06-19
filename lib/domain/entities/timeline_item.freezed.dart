// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TimelineItem {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Task task) task,
    required TResult Function(Note note) note,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Task task)? task,
    TResult? Function(Note note)? note,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Task task)? task,
    TResult Function(Note note)? note,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TimelineItemTask value) task,
    required TResult Function(TimelineItemNote value) note,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TimelineItemTask value)? task,
    TResult? Function(TimelineItemNote value)? note,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TimelineItemTask value)? task,
    TResult Function(TimelineItemNote value)? note,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimelineItemCopyWith<$Res> {
  factory $TimelineItemCopyWith(
    TimelineItem value,
    $Res Function(TimelineItem) then,
  ) = _$TimelineItemCopyWithImpl<$Res, TimelineItem>;
}

/// @nodoc
class _$TimelineItemCopyWithImpl<$Res, $Val extends TimelineItem>
    implements $TimelineItemCopyWith<$Res> {
  _$TimelineItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimelineItem
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$TimelineItemTaskImplCopyWith<$Res> {
  factory _$$TimelineItemTaskImplCopyWith(
    _$TimelineItemTaskImpl value,
    $Res Function(_$TimelineItemTaskImpl) then,
  ) = __$$TimelineItemTaskImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Task task});

  $TaskCopyWith<$Res> get task;
}

/// @nodoc
class __$$TimelineItemTaskImplCopyWithImpl<$Res>
    extends _$TimelineItemCopyWithImpl<$Res, _$TimelineItemTaskImpl>
    implements _$$TimelineItemTaskImplCopyWith<$Res> {
  __$$TimelineItemTaskImplCopyWithImpl(
    _$TimelineItemTaskImpl _value,
    $Res Function(_$TimelineItemTaskImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimelineItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? task = null}) {
    return _then(
      _$TimelineItemTaskImpl(
        null == task
            ? _value.task
            : task // ignore: cast_nullable_to_non_nullable
                  as Task,
      ),
    );
  }

  /// Create a copy of TimelineItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TaskCopyWith<$Res> get task {
    return $TaskCopyWith<$Res>(_value.task, (value) {
      return _then(_value.copyWith(task: value));
    });
  }
}

/// @nodoc

class _$TimelineItemTaskImpl implements TimelineItemTask {
  const _$TimelineItemTaskImpl(this.task);

  @override
  final Task task;

  @override
  String toString() {
    return 'TimelineItem.task(task: $task)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimelineItemTaskImpl &&
            (identical(other.task, task) || other.task == task));
  }

  @override
  int get hashCode => Object.hash(runtimeType, task);

  /// Create a copy of TimelineItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimelineItemTaskImplCopyWith<_$TimelineItemTaskImpl> get copyWith =>
      __$$TimelineItemTaskImplCopyWithImpl<_$TimelineItemTaskImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Task task) task,
    required TResult Function(Note note) note,
  }) {
    return task(this.task);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Task task)? task,
    TResult? Function(Note note)? note,
  }) {
    return task?.call(this.task);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Task task)? task,
    TResult Function(Note note)? note,
    required TResult orElse(),
  }) {
    if (task != null) {
      return task(this.task);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TimelineItemTask value) task,
    required TResult Function(TimelineItemNote value) note,
  }) {
    return task(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TimelineItemTask value)? task,
    TResult? Function(TimelineItemNote value)? note,
  }) {
    return task?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TimelineItemTask value)? task,
    TResult Function(TimelineItemNote value)? note,
    required TResult orElse(),
  }) {
    if (task != null) {
      return task(this);
    }
    return orElse();
  }
}

abstract class TimelineItemTask implements TimelineItem {
  const factory TimelineItemTask(final Task task) = _$TimelineItemTaskImpl;

  Task get task;

  /// Create a copy of TimelineItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimelineItemTaskImplCopyWith<_$TimelineItemTaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TimelineItemNoteImplCopyWith<$Res> {
  factory _$$TimelineItemNoteImplCopyWith(
    _$TimelineItemNoteImpl value,
    $Res Function(_$TimelineItemNoteImpl) then,
  ) = __$$TimelineItemNoteImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Note note});

  $NoteCopyWith<$Res> get note;
}

/// @nodoc
class __$$TimelineItemNoteImplCopyWithImpl<$Res>
    extends _$TimelineItemCopyWithImpl<$Res, _$TimelineItemNoteImpl>
    implements _$$TimelineItemNoteImplCopyWith<$Res> {
  __$$TimelineItemNoteImplCopyWithImpl(
    _$TimelineItemNoteImpl _value,
    $Res Function(_$TimelineItemNoteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimelineItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? note = null}) {
    return _then(
      _$TimelineItemNoteImpl(
        null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as Note,
      ),
    );
  }

  /// Create a copy of TimelineItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NoteCopyWith<$Res> get note {
    return $NoteCopyWith<$Res>(_value.note, (value) {
      return _then(_value.copyWith(note: value));
    });
  }
}

/// @nodoc

class _$TimelineItemNoteImpl implements TimelineItemNote {
  const _$TimelineItemNoteImpl(this.note);

  @override
  final Note note;

  @override
  String toString() {
    return 'TimelineItem.note(note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimelineItemNoteImpl &&
            (identical(other.note, note) || other.note == note));
  }

  @override
  int get hashCode => Object.hash(runtimeType, note);

  /// Create a copy of TimelineItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimelineItemNoteImplCopyWith<_$TimelineItemNoteImpl> get copyWith =>
      __$$TimelineItemNoteImplCopyWithImpl<_$TimelineItemNoteImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Task task) task,
    required TResult Function(Note note) note,
  }) {
    return note(this.note);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Task task)? task,
    TResult? Function(Note note)? note,
  }) {
    return note?.call(this.note);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Task task)? task,
    TResult Function(Note note)? note,
    required TResult orElse(),
  }) {
    if (note != null) {
      return note(this.note);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TimelineItemTask value) task,
    required TResult Function(TimelineItemNote value) note,
  }) {
    return note(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TimelineItemTask value)? task,
    TResult? Function(TimelineItemNote value)? note,
  }) {
    return note?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TimelineItemTask value)? task,
    TResult Function(TimelineItemNote value)? note,
    required TResult orElse(),
  }) {
    if (note != null) {
      return note(this);
    }
    return orElse();
  }
}

abstract class TimelineItemNote implements TimelineItem {
  const factory TimelineItemNote(final Note note) = _$TimelineItemNoteImpl;

  Note get note;

  /// Create a copy of TimelineItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimelineItemNoteImplCopyWith<_$TimelineItemNoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
