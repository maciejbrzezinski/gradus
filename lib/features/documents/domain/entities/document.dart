import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';
part 'document.g.dart';

/// Abstrakcyjna klasa Document - bazowa encja dla wszystkich dokumentów
/// US-002: Abstrakcyjny model Document
@freezed
abstract class Document with _$Document {
  const factory Document({
    required String id,
    DateTime? date, // nullable dla projektów
    String? title, // dla projektów
    String? icon, // dla projektów
    String? iconColor, // dla projektów
    required List<String> blocks, // uporządkowana lista ID bloków
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);
}
