// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'block.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Block {

 String get id; String get type; dynamic get content; Map<String, dynamic> get metadata; List<Block> get children; String? get projectId;// nullable
 DateTime? get date;
/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlockCopyWith<Block> get copyWith => _$BlockCopyWithImpl<Block>(this as Block, _$identity);

  /// Serializes this Block to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Block&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.content, content)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&const DeepCollectionEquality().equals(other.children, children)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,const DeepCollectionEquality().hash(content),const DeepCollectionEquality().hash(metadata),const DeepCollectionEquality().hash(children),projectId,date);

@override
String toString() {
  return 'Block(id: $id, type: $type, content: $content, metadata: $metadata, children: $children, projectId: $projectId, date: $date)';
}


}

/// @nodoc
abstract mixin class $BlockCopyWith<$Res>  {
  factory $BlockCopyWith(Block value, $Res Function(Block) _then) = _$BlockCopyWithImpl;
@useResult
$Res call({
 String id, String type, dynamic content, Map<String, dynamic> metadata, List<Block> children, String? projectId, DateTime? date
});




}
/// @nodoc
class _$BlockCopyWithImpl<$Res>
    implements $BlockCopyWith<$Res> {
  _$BlockCopyWithImpl(this._self, this._then);

  final Block _self;
  final $Res Function(Block) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? content = freezed,Object? metadata = null,Object? children = null,Object? projectId = freezed,Object? date = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as dynamic,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<Block>,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Block implements Block {
  const _Block({required this.id, required this.type, required this.content, required final  Map<String, dynamic> metadata, required final  List<Block> children, this.projectId, this.date}): _metadata = metadata,_children = children;
  factory _Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);

@override final  String id;
@override final  String type;
@override final  dynamic content;
 final  Map<String, dynamic> _metadata;
@override Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

 final  List<Block> _children;
@override List<Block> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}

@override final  String? projectId;
// nullable
@override final  DateTime? date;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlockCopyWith<_Block> get copyWith => __$BlockCopyWithImpl<_Block>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BlockToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Block&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.content, content)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&const DeepCollectionEquality().equals(other._children, _children)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,const DeepCollectionEquality().hash(content),const DeepCollectionEquality().hash(_metadata),const DeepCollectionEquality().hash(_children),projectId,date);

@override
String toString() {
  return 'Block(id: $id, type: $type, content: $content, metadata: $metadata, children: $children, projectId: $projectId, date: $date)';
}


}

/// @nodoc
abstract mixin class _$BlockCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory _$BlockCopyWith(_Block value, $Res Function(_Block) _then) = __$BlockCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, dynamic content, Map<String, dynamic> metadata, List<Block> children, String? projectId, DateTime? date
});




}
/// @nodoc
class __$BlockCopyWithImpl<$Res>
    implements _$BlockCopyWith<$Res> {
  __$BlockCopyWithImpl(this._self, this._then);

  final _Block _self;
  final $Res Function(_Block) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? content = freezed,Object? metadata = null,Object? children = null,Object? projectId = freezed,Object? date = freezed,}) {
  return _then(_Block(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as dynamic,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<Block>,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
