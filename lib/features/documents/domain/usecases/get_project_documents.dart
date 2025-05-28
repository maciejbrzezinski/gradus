import '../entities/document.dart';
import '../repositories/document_repository.dart';

/// Use Case for getting all project documents
/// US-005: Use Cases (Domain Layer)
class GetProjectDocuments {
  final DocumentRepository repository;

  GetProjectDocuments(this.repository);

  /// Gets all project documents (documents without dates)
  Future<List<Document>> call() async {
    return await repository.getProjectDocuments();
  }
}
