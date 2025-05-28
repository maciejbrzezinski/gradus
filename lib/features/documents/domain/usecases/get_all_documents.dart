import '../entities/document.dart';
import '../repositories/document_repository.dart';

/// Use Case for getting all documents
/// US-005: Use Cases (Domain Layer)
class GetAllDocuments {
  final DocumentRepository repository;

  GetAllDocuments(this.repository);

  /// Gets all documents from repository
  Future<List<Document>> call() async {
    return await repository.getAllDocuments();
  }
}
