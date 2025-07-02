// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TimelineState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<Day> days,
      List<TimelineItem> items,
      DateTime startDate,
      DateTime endDate,
      String? currentProjectId,
    )
    loaded,
    required TResult Function(Failure failure) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<Day> days,
      List<TimelineItem> items,
      DateTime startDate,
      DateTime endDate,
      String? currentProjectId,
    )?
    loaded,
    TResult? Function(Failure failure)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<Day> days,
      List<TimelineItem> items,
      DateTime startDate,
      DateTime endDate,
      String? currentProjectId,
    )?
    loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TimelineInitial value) initial,
    required TResult Function(TimelineLoading value) loading,
    required TResult Function(TimelineLoaded value) loaded,
    required TResult Function(TimelineError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TimelineInitial value)? initial,
    TResult? Function(TimelineLoading value)? loading,
    TResult? Function(TimelineLoaded value)? loaded,
    TResult? Function(TimelineError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TimelineInitial value)? initial,
    TResult Function(TimelineLoading value)? loading,
    TResult Function(TimelineLoaded value)? loaded,
    TResult Function(TimelineError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimelineStateCopyWith<$Res> {
  factory $TimelineStateCopyWith(
    TimelineState value,
    $Res Function(TimelineState) then,
  ) = _$TimelineStateCopyWithImpl<$Res, TimelineState>;
}

/// @nodoc
class _$TimelineStateCopyWithImpl<$Res, $Val extends TimelineState>
    implements $TimelineStateCopyWith<$Res> {
  _$TimelineStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimelineState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$TimelineInitialImplCopyWith<$Res> {
  factory _$$TimelineInitialImplCopyWith(
    _$TimelineInitialImpl value,
    $Res Function(_$TimelineInitialImpl) then,
  ) = __$$TimelineInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TimelineInitialImplCopyWithImpl<$Res>
    extends _$TimelineStateCopyWithImpl<$Res, _$TimelineInitialImpl>
    implements _$$TimelineInitialImplCopyWith<$Res> {
  __$$TimelineInitialImplCopyWithImpl(
    _$TimelineInitialImpl _value,
    $Res Function(_$TimelineInitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimelineState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$TimelineInitialImpl implements TimelineInitial {
  const _$TimelineInitialImpl();

  @override
  String toString() {
    return 'TimelineState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$TimelineInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<Day> days,
      List<TimelineItem> items,
      DateTime startDate,
      DateTime endDate,
      String? currentProjectId,
    )
    loaded,
    required TResult Function(Failure failure) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<Day> days,
      List<TimelineItem> items,
      DateTime startDate,
      DateTime endDate,
      String? currentProjectId,
    )?
    loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<Day> days,
      List<TimelineItem> items,
      DateTime startDate,
      DateTime endDate,
      String? currentProjectId,
    )?
    loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TimelineInitial value) initial,
    required TResult Function(TimelineLoading value) loading,
    required TResult Function(TimelineLoaded value) loaded,
    required TResult Function(TimelineError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TimelineInitial value)? initial,
    TResult? Function(TimelineLoading value)? loading,
    TResult? Function(TimelineLoaded value)? loaded,
    TResult? Function(TimelineError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TimelineInitial value)? initial,
    TResult Function(TimelineLoading value)? loading,
    TResult Function(TimelineLoaded value)? loaded,
    TResult Function(TimelineError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class TimelineInitial implements TimelineState {
  const factory TimelineInitial() = _$TimelineInitialImpl;
}

/// @nodoc
abstract class _$$TimelineLoadingImplCopyWith<$Res> {
  factory _$$TimelineLoadingImplCopyWith(
    _$TimelineLoadingImpl value,
    $Res Function(_$TimelineLoadingImpl) then,
  ) = __$$TimelineLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TimelineLoadingImplCopyWithImpl<$Res>
    extends _$TimelineStateCopyWithImpl<$Res, _$TimelineLoadingImpl>
    implements _$$TimelineLoadingImplCopyWith<$Res> {
  __$$TimelineLoadingImplCopyWithImpl(
    _$TimelineLoadingImpl _value,
    $Res Function(_$TimelineLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimelineState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$TimelineLoadingImpl implements TimelineLoading {
  const _$TimelineLoadingImpl();

  @override
  String toString() {
    return 'TimelineState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$TimelineLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<Day> days,
      List<TimelineItem> items,
      DateTime startDate,
      DateTime endDate,
      String? currentProjectId,
    )
    loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<Day> days,
      List<TimelineItem> items,
      DateTime startDate,
      DateTime endDate,
      String? currentProjectId,
    )?
    loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<Day> days,
      List<TimelineItem> items,
      DateTime startDate,
      DateTime endDate,
      String? currentProjectId,
    )?
    loaded,
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
    required TResult Function(TimelineInitial value) initial,
    required TResult Function(TimelineLoading value) loading,
    required TResult Function(TimelineLoaded value) loaded,
    required TResult Function(TimelineError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TimelineInitial value)? initial,
    TResult? Function(TimelineLoading value)? loading,
    TResult? Function(TimelineLoaded value)? loaded,
    TResult? Function(TimelineError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TimelineInitial value)? initial,
    TResult Function(TimelineLoading value)? loading,
    TResult Function(TimelineLoaded value)? loaded,
    TResult Function(TimelineError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class TimelineLoading implements TimelineState {
  const factory TimelineLoading() = _$TimelineLoadingImpl;
}

/// @nodoc
abstract class _$$TimelineLoadedImplCopyWith<$Res> {
  factory _$$TimelineLoadedImplCopyWith(
    _$TimelineLoadedImpl value,
    $Res Function(_$TimelineLoadedImpl) then,
  ) = __$$TimelineLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    List<Day> days,
    List<TimelineItem> items,
    DateTime startDate,
    DateTime endDate,
    String? currentProjectId,
  });
}

/// @nodoc
class __$$TimelineLoadedImplCopyWithImpl<$Res>
    extends _$TimelineStateCopyWithImpl<$Res, _$TimelineLoadedImpl>
    implements _$$TimelineLoadedImplCopyWith<$Res> {
  __$$TimelineLoadedImplCopyWithImpl(
    _$TimelineLoadedImpl _value,
    $Res Function(_$TimelineLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimelineState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? days = null,
    Object? items = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? currentProjectId = freezed,
  }) {
    return _then(
      _$TimelineLoadedImpl(
        days: null == days
            ? _value._days
            : days // ignore: cast_nullable_to_non_nullable
                  as List<Day>,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<TimelineItem>,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        currentProjectId: freezed == currentProjectId
            ? _value.currentProjectId
            : currentProjectId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$TimelineLoadedImpl implements TimelineLoaded {
  const _$TimelineLoadedImpl({
    required final List<Day> days,
    required final List<TimelineItem> items,
    required this.startDate,
    required this.endDate,
    required this.currentProjectId,
  }) : _days = days,
       _items = items;

  final List<Day> _days;
  @override
  List<Day> get days {
    if (_days is EqualUnmodifiableListView) return _days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_days);
  }

  final List<TimelineItem> _items;
  @override
  List<TimelineItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final String? currentProjectId;

  @override
  String toString() {
    return 'TimelineState.loaded(days: $days, items: $items, startDate: $startDate, endDate: $endDate, currentProjectId: $currentProjectId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimelineLoadedImpl &&
            const DeepCollectionEquality().equals(other._days, _days) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.currentProjectId, currentProjectId) ||
                other.currentProjectId == currentProjectId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_days),
    const DeepCollectionEquality().hash(_items),
    startDate,
    endDate,
    currentProjectId,
  );

  /// Create a copy of TimelineState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimelineLoadedImplCopyWith<_$TimelineLoadedImpl> get copyWith =>
      __$$TimelineLoadedImplCopyWithImpl<_$TimelineLoadedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<Day> days,
      List<TimelineItem> items,
      DateTime startDate,
      DateTime endDate,
      String? currentProjectId,
    )
    loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loaded(days, items, startDate, endDate, currentProjectId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<Day> days,
      List<TimelineItem> items,
      DateTime startDate,
      DateTime endDate,
      String? currentProjectId,
    )?
    loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loaded?.call(days, items, startDate, endDate, currentProjectId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<Day> days,
      List<TimelineItem> items,
      DateTime startDate,
      DateTime endDate,
      String? currentProjectId,
    )?
    loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(days, items, startDate, endDate, currentProjectId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TimelineInitial value) initial,
    required TResult Function(TimelineLoading value) loading,
    required TResult Function(TimelineLoaded value) loaded,
    required TResult Function(TimelineError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TimelineInitial value)? initial,
    TResult? Function(TimelineLoading value)? loading,
    TResult? Function(TimelineLoaded value)? loaded,
    TResult? Function(TimelineError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TimelineInitial value)? initial,
    TResult Function(TimelineLoading value)? loading,
    TResult Function(TimelineLoaded value)? loaded,
    TResult Function(TimelineError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class TimelineLoaded implements TimelineState {
  const factory TimelineLoaded({
    required final List<Day> days,
    required final List<TimelineItem> items,
    required final DateTime startDate,
    required final DateTime endDate,
    required final String? currentProjectId,
  }) = _$TimelineLoadedImpl;

  List<Day> get days;
  List<TimelineItem> get items;
  DateTime get startDate;
  DateTime get endDate;
  String? get currentProjectId;

  /// Create a copy of TimelineState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimelineLoadedImplCopyWith<_$TimelineLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TimelineErrorImplCopyWith<$Res> {
  factory _$$TimelineErrorImplCopyWith(
    _$TimelineErrorImpl value,
    $Res Function(_$TimelineErrorImpl) then,
  ) = __$$TimelineErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure});

  $FailureCopyWith<$Res> get failure;
}

/// @nodoc
class __$$TimelineErrorImplCopyWithImpl<$Res>
    extends _$TimelineStateCopyWithImpl<$Res, _$TimelineErrorImpl>
    implements _$$TimelineErrorImplCopyWith<$Res> {
  __$$TimelineErrorImplCopyWithImpl(
    _$TimelineErrorImpl _value,
    $Res Function(_$TimelineErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimelineState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? failure = null}) {
    return _then(
      _$TimelineErrorImpl(
        failure: null == failure
            ? _value.failure
            : failure // ignore: cast_nullable_to_non_nullable
                  as Failure,
      ),
    );
  }

  /// Create a copy of TimelineState
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

class _$TimelineErrorImpl implements TimelineError {
  const _$TimelineErrorImpl({required this.failure});

  @override
  final Failure failure;

  @override
  String toString() {
    return 'TimelineState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimelineErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of TimelineState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimelineErrorImplCopyWith<_$TimelineErrorImpl> get copyWith =>
      __$$TimelineErrorImplCopyWithImpl<_$TimelineErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<Day> days,
      List<TimelineItem> items,
      DateTime startDate,
      DateTime endDate,
      String? currentProjectId,
    )
    loaded,
    required TResult Function(Failure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<Day> days,
      List<TimelineItem> items,
      DateTime startDate,
      DateTime endDate,
      String? currentProjectId,
    )?
    loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<Day> days,
      List<TimelineItem> items,
      DateTime startDate,
      DateTime endDate,
      String? currentProjectId,
    )?
    loaded,
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
    required TResult Function(TimelineInitial value) initial,
    required TResult Function(TimelineLoading value) loading,
    required TResult Function(TimelineLoaded value) loaded,
    required TResult Function(TimelineError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TimelineInitial value)? initial,
    TResult? Function(TimelineLoading value)? loading,
    TResult? Function(TimelineLoaded value)? loaded,
    TResult? Function(TimelineError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TimelineInitial value)? initial,
    TResult Function(TimelineLoading value)? loading,
    TResult Function(TimelineLoaded value)? loaded,
    TResult Function(TimelineError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class TimelineError implements TimelineState {
  const factory TimelineError({required final Failure failure}) =
      _$TimelineErrorImpl;

  Failure get failure;

  /// Create a copy of TimelineState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimelineErrorImplCopyWith<_$TimelineErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
