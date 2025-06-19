// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_item_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TimelineItemState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(TimelineItem item) loaded,
    required TResult Function(Failure failure) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(TimelineItem item)? loaded,
    TResult? Function(Failure failure)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(TimelineItem item)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TimelineItemLoading value) loading,
    required TResult Function(TimelineItemLoaded value) loaded,
    required TResult Function(TimelineItemError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TimelineItemLoading value)? loading,
    TResult? Function(TimelineItemLoaded value)? loaded,
    TResult? Function(TimelineItemError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TimelineItemLoading value)? loading,
    TResult Function(TimelineItemLoaded value)? loaded,
    TResult Function(TimelineItemError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimelineItemStateCopyWith<$Res> {
  factory $TimelineItemStateCopyWith(
    TimelineItemState value,
    $Res Function(TimelineItemState) then,
  ) = _$TimelineItemStateCopyWithImpl<$Res, TimelineItemState>;
}

/// @nodoc
class _$TimelineItemStateCopyWithImpl<$Res, $Val extends TimelineItemState>
    implements $TimelineItemStateCopyWith<$Res> {
  _$TimelineItemStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimelineItemState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$TimelineItemLoadingImplCopyWith<$Res> {
  factory _$$TimelineItemLoadingImplCopyWith(
    _$TimelineItemLoadingImpl value,
    $Res Function(_$TimelineItemLoadingImpl) then,
  ) = __$$TimelineItemLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TimelineItemLoadingImplCopyWithImpl<$Res>
    extends _$TimelineItemStateCopyWithImpl<$Res, _$TimelineItemLoadingImpl>
    implements _$$TimelineItemLoadingImplCopyWith<$Res> {
  __$$TimelineItemLoadingImplCopyWithImpl(
    _$TimelineItemLoadingImpl _value,
    $Res Function(_$TimelineItemLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimelineItemState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$TimelineItemLoadingImpl implements TimelineItemLoading {
  const _$TimelineItemLoadingImpl();

  @override
  String toString() {
    return 'TimelineItemState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimelineItemLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(TimelineItem item) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(TimelineItem item)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(TimelineItem item)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TimelineItemLoading value) loading,
    required TResult Function(TimelineItemLoaded value) loaded,
    required TResult Function(TimelineItemError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TimelineItemLoading value)? loading,
    TResult? Function(TimelineItemLoaded value)? loaded,
    TResult? Function(TimelineItemError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TimelineItemLoading value)? loading,
    TResult Function(TimelineItemLoaded value)? loaded,
    TResult Function(TimelineItemError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class TimelineItemLoading implements TimelineItemState {
  const factory TimelineItemLoading() = _$TimelineItemLoadingImpl;
}

/// @nodoc
abstract class _$$TimelineItemLoadedImplCopyWith<$Res> {
  factory _$$TimelineItemLoadedImplCopyWith(
    _$TimelineItemLoadedImpl value,
    $Res Function(_$TimelineItemLoadedImpl) then,
  ) = __$$TimelineItemLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({TimelineItem item});

  $TimelineItemCopyWith<$Res> get item;
}

/// @nodoc
class __$$TimelineItemLoadedImplCopyWithImpl<$Res>
    extends _$TimelineItemStateCopyWithImpl<$Res, _$TimelineItemLoadedImpl>
    implements _$$TimelineItemLoadedImplCopyWith<$Res> {
  __$$TimelineItemLoadedImplCopyWithImpl(
    _$TimelineItemLoadedImpl _value,
    $Res Function(_$TimelineItemLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimelineItemState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? item = null}) {
    return _then(
      _$TimelineItemLoadedImpl(
        null == item
            ? _value.item
            : item // ignore: cast_nullable_to_non_nullable
                  as TimelineItem,
      ),
    );
  }

  /// Create a copy of TimelineItemState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimelineItemCopyWith<$Res> get item {
    return $TimelineItemCopyWith<$Res>(_value.item, (value) {
      return _then(_value.copyWith(item: value));
    });
  }
}

/// @nodoc

class _$TimelineItemLoadedImpl implements TimelineItemLoaded {
  const _$TimelineItemLoadedImpl(this.item);

  @override
  final TimelineItem item;

  @override
  String toString() {
    return 'TimelineItemState.loaded(item: $item)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimelineItemLoadedImpl &&
            (identical(other.item, item) || other.item == item));
  }

  @override
  int get hashCode => Object.hash(runtimeType, item);

  /// Create a copy of TimelineItemState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimelineItemLoadedImplCopyWith<_$TimelineItemLoadedImpl> get copyWith =>
      __$$TimelineItemLoadedImplCopyWithImpl<_$TimelineItemLoadedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(TimelineItem item) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loaded(item);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(TimelineItem item)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loaded?.call(item);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(TimelineItem item)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(item);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TimelineItemLoading value) loading,
    required TResult Function(TimelineItemLoaded value) loaded,
    required TResult Function(TimelineItemError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TimelineItemLoading value)? loading,
    TResult? Function(TimelineItemLoaded value)? loaded,
    TResult? Function(TimelineItemError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TimelineItemLoading value)? loading,
    TResult Function(TimelineItemLoaded value)? loaded,
    TResult Function(TimelineItemError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class TimelineItemLoaded implements TimelineItemState {
  const factory TimelineItemLoaded(final TimelineItem item) =
      _$TimelineItemLoadedImpl;

  TimelineItem get item;

  /// Create a copy of TimelineItemState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimelineItemLoadedImplCopyWith<_$TimelineItemLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TimelineItemErrorImplCopyWith<$Res> {
  factory _$$TimelineItemErrorImplCopyWith(
    _$TimelineItemErrorImpl value,
    $Res Function(_$TimelineItemErrorImpl) then,
  ) = __$$TimelineItemErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure});

  $FailureCopyWith<$Res> get failure;
}

/// @nodoc
class __$$TimelineItemErrorImplCopyWithImpl<$Res>
    extends _$TimelineItemStateCopyWithImpl<$Res, _$TimelineItemErrorImpl>
    implements _$$TimelineItemErrorImplCopyWith<$Res> {
  __$$TimelineItemErrorImplCopyWithImpl(
    _$TimelineItemErrorImpl _value,
    $Res Function(_$TimelineItemErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimelineItemState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? failure = null}) {
    return _then(
      _$TimelineItemErrorImpl(
        null == failure
            ? _value.failure
            : failure // ignore: cast_nullable_to_non_nullable
                  as Failure,
      ),
    );
  }

  /// Create a copy of TimelineItemState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FailureCopyWith<$Res> get failure {
    return $FailureCopyWith<$Res>(_value.failure, (value) {
      return _then(_value.copyWith(failure: value));
    });
  }
}

/// @nodoc

class _$TimelineItemErrorImpl implements TimelineItemError {
  const _$TimelineItemErrorImpl(this.failure);

  @override
  final Failure failure;

  @override
  String toString() {
    return 'TimelineItemState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimelineItemErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of TimelineItemState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimelineItemErrorImplCopyWith<_$TimelineItemErrorImpl> get copyWith =>
      __$$TimelineItemErrorImplCopyWithImpl<_$TimelineItemErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(TimelineItem item) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(TimelineItem item)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(TimelineItem item)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(failure);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TimelineItemLoading value) loading,
    required TResult Function(TimelineItemLoaded value) loaded,
    required TResult Function(TimelineItemError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TimelineItemLoading value)? loading,
    TResult? Function(TimelineItemLoaded value)? loaded,
    TResult? Function(TimelineItemError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TimelineItemLoading value)? loading,
    TResult Function(TimelineItemLoaded value)? loaded,
    TResult Function(TimelineItemError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class TimelineItemError implements TimelineItemState {
  const factory TimelineItemError(final Failure failure) =
      _$TimelineItemErrorImpl;

  Failure get failure;

  /// Create a copy of TimelineItemState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimelineItemErrorImplCopyWith<_$TimelineItemErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
