import '../entities/document.dart';
import '../repositories/document_repository.dart';

/// Use Case for getting project timeline documents in date range
/// US-005: Use Cases (Domain Layer)
class GetProjectTimelineDocuments {
  final DocumentRepository repository;

  GetProjectTimelineDocuments(this.repository);

  /// Gets project timeline documents in date range
  Future<List<Document>> call(
    String projectId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Business validation
    if (projectId.isEmpty) {
      throw ArgumentError('Project ID cannot be empty');
    }

    if (startDate.isAfter(endDate)) {
      throw ArgumentError('Start date cannot be after end date');
    }

    return await repository.getProjectTimelineDocuments(
      projectId,
      startDate,
      endDate,
    );
  }
}
