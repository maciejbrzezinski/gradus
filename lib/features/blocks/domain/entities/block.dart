import 'package:freezed_annotation/freezed_annotation.dart';

part 'block.freezed.dart';
part 'block.g.dart';

/// Abstract Block class - base entity for all blocks
/// US-003: Abstract Block model
@freezed
abstract class Block with _$Block {
  const factory Block({
    required String id,
    required String type,
    required dynamic content,
    required Map<String, dynamic> metadata,
    required List<Block> children,
    String? projectId, // nullable
    DateTime? date, // nullable
  }) = _Block;

  factory Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);
}
