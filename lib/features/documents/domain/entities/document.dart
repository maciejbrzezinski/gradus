import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';
part 'document.g.dart';

/// Abstract Document class - base entity for all documents
/// US-002: Abstract Document model
@freezed
abstract class Document with _$Document {
  const factory Document({
    required String id,
    DateTime? date, // nullable for projects
    String? title, // for projects
    String? icon, // for projects
    String? iconColor, // for projects
    required List<String> blocks, // ordered list of block IDs
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);
}
