import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/project.dart';
import '../../core/services/auth_service.dart';

@injectable
class ProjectsDataSource {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  ProjectsDataSource(this._firestore, this._authService);

  String get _userId => _authService.currentUserId;

  CollectionReference get _projectsCollection => 
    _firestore.collection('users').doc(_userId).collection('projects');

  Future<void> _ensureDefaultProjects() async {
    final snapshot = await _projectsCollection.get();
    
    if (snapshot.docs.isEmpty) {
      final now = DateTime.now();
      
      // Create default projects
      final personalProject = Project(
        id: 'personal-project-id',
        name: 'Personal',
        createdAt: now.subtract(const Duration(days: 30)),
      );
      
      final workProject = Project(
        id: 'work-project-id',
        name: 'Work',
        createdAt: now.subtract(const Duration(days: 25)),
      );
      
      await createProject(personalProject);
      await createProject(workProject);
    }
  }

  Stream<List<Project>> watchProjects() {
    return _projectsCollection
        .orderBy('createdAt')
        .snapshots()
        .asyncMap((snapshot) async {
      await _ensureDefaultProjects();
      return snapshot.docs
          .map((doc) => _mapDocToProject(doc))
          .toList();
    });
  }

  Future<List<Project>> getProjects() async {
    await _ensureDefaultProjects();
    final snapshot = await _projectsCollection
        .orderBy('createdAt')
        .get();
    
    return snapshot.docs
        .map((doc) => _mapDocToProject(doc))
        .toList();
  }

  Future<Project?> getProjectById(String projectId) async {
    final doc = await _projectsCollection.doc(projectId).get();
    if (!doc.exists) return null;
    return _mapDocToProject(doc);
  }

  Future<void> createProject(Project project) async {
    final projectData = _mapProjectToData(project);
    await _projectsCollection.doc(project.id).set(projectData);
  }

  Future<void> updateProject(Project project) async {
    final doc = await _projectsCollection.doc(project.id).get();
    if (!doc.exists) {
      throw Exception('Project not found: ${project.id}');
    }
    final projectData = _mapProjectToData(project);
    await _projectsCollection.doc(project.id).update(projectData);
  }

  Future<void> deleteProject(String projectId) async {
    final doc = await _projectsCollection.doc(projectId).get();
    if (!doc.exists) {
      throw Exception('Project not found: $projectId');
    }
    await _projectsCollection.doc(projectId).delete();
  }

  Project _mapDataToProject(Map<String, dynamic> data) {
    return Project(
      id: data['id'],
      name: data['name'],
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  Project _mapDocToProject(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return _mapDataToProject(data);
  }

  Map<String, dynamic> _mapProjectToData(Project project) {
    return {
      'id': project.id,
      'name': project.name,
      'createdAt': project.createdAt.toIso8601String(),
    };
  }
}
