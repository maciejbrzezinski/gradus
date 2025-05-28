import '../entities/document.dart';
import '../repositories/document_repository.dart';

/// Use Case for getting documents in date range
/// US-005: Use Cases (Domain Layer)
class GetDocumentsByDateRange {
  final DocumentRepository repository;

  GetDocumentsByDateRange(this.repository);

  /// Gets documents in date range (lazy loading for timeline)
  Future<List<Document>> call(DateTime startDate, DateTime endDate) async {
    // Business validation
    if (startDate.isAfter(endDate)) {
      throw ArgumentError('Start date cannot be after end date');
    }

    return await repository.getDocumentsByDateRange(startDate, endDate);
  }
}
