import '../entities/document.dart';
import '../repositories/document_repository.dart';

/// Use Case for getting document by specific date
/// US-005: Use Cases (Domain Layer)
class GetDocumentByDate {
  final DocumentRepository repository;

  GetDocumentByDate(this.repository);

  /// Gets document for specific date (timeline)
  Future<Document?> call(DateTime date) async {
    return await repository.getDocumentByDate(date);
  }
}
