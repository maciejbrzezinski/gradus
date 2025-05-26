/// Abstrakcyjna klasa Document - bazowa encja dla wszystkich dokumentów
/// US-002: Abstrakcyjny model Document
abstract class Document {
  final String id;
  final DateTime? date; // nullable dla projektów
  final String? title; // dla projektów
  final String? icon; // dla projektów
  final String? iconColor; // dla projektów
  final List<String> blocks; // uporządkowana lista ID bloków

  const Document({
    required this.id,
    this.date,
    this.title,
    this.icon,
    this.iconColor,
    required this.blocks,
  });
}
