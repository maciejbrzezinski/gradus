/// Abstrakcyjna klasa Block - bazowa encja dla wszystkich bloków
/// US-003: Abstrakcyjny model Block
abstract class Block {
  final String id;
  final String type;
  final dynamic content;
  final Map<String, dynamic> metadata;
  final List<Block> children;
  final String? projectId; // nullable
  final DateTime? date; // nullable

  const Block({
    required this.id,
    required this.type,
    required this.content,
    required this.metadata,
    required this.children,
    this.projectId,
    this.date,
  });
}
