import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/project.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/logger_service.dart';

@injectable
class ProjectsDataSource {
  final FirebaseFirestore _firestore;
  final AuthService _authService;
  final LoggerService _logger;

  ProjectsDataSource(this._firestore, this._authService, this._logger);

  String get _userId => _authService.currentUserId;

  CollectionReference get _projectsCollection => _firestore.collection('users').doc(_userId).collection('projects');

  Future<void> _ensureDefaultProjects() async {
    _logger.d('🔧 [ProjectsDataSource] _ensureDefaultProjects - checking for default projects');
    
    try {
      final snapshot = await _projectsCollection.get();
      _logger.d('📊 [ProjectsDataSource] _ensureDefaultProjects - found ${snapshot.docs.length} existing projects');

      if (snapshot.docs.isEmpty) {
        _logger.i('🏗️ [ProjectsDataSource] _ensureDefaultProjects - creating default projects');
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
        _logger.i('✅ [ProjectsDataSource] _ensureDefaultProjects - default projects created');
      } else {
        _logger.d('✅ [ProjectsDataSource] _ensureDefaultProjects - default projects already exist');
      }
    } catch (e) {
      _logger.e('❌ [ProjectsDataSource] _ensureDefaultProjects - error ensuring default projects', error: e);
      rethrow;
    }
  }

  Stream<List<Project>> watchProjects() {
    _logger.i('🔍 [ProjectsDataSource] watchProjects - starting to watch projects');
    
    return _projectsCollection.orderBy('createdAt').snapshots().asyncMap((snapshot) async {
      _logger.d('📊 [ProjectsDataSource] watchProjects - received ${snapshot.docs.length} documents from Firestore');
      
      await _ensureDefaultProjects();
      final projects = snapshot.docs.map((doc) => _mapDocToProject(doc)).toList();
      
      _logger.i('✅ [ProjectsDataSource] watchProjects - returning ${projects.length} projects');
      return projects;
    });
  }

  Future<List<Project>> getProjects() async {
    _logger.i('📋 [ProjectsDataSource] getProjects - fetching all projects');
    
    try {
      await _ensureDefaultProjects();
      final snapshot = await _projectsCollection.get();
      
      _logger.d('📊 [ProjectsDataSource] getProjects - received ${snapshot.docs.length} documents from Firestore');
      
      final projects = snapshot.docs.map((doc) => _mapDocToProject(doc)).toList();
      _logger.i('✅ [ProjectsDataSource] getProjects - returning ${projects.length} projects');
      
      return projects;
    } catch (e) {
      _logger.e('❌ [ProjectsDataSource] getProjects - error fetching projects', error: e);
      rethrow;
    }
  }

  Future<Project?> getProjectById(String projectId) async {
    _logger.i('🔍 [ProjectsDataSource] getProjectById - projectId: $projectId');
    
    try {
      final doc = await _projectsCollection.doc(projectId).get();
      
      if (!doc.exists) {
        _logger.w('⚠️ [ProjectsDataSource] getProjectById - project not found: $projectId');
        return null;
      }
      
      final project = _mapDocToProject(doc);
      _logger.i('✅ [ProjectsDataSource] getProjectById - found project: ${project.name}');
      
      return project;
    } catch (e) {
      _logger.e('❌ [ProjectsDataSource] getProjectById - error fetching project: $projectId', error: e);
      rethrow;
    }
  }

  Future<void> createProject(Project project) async {
    _logger.i('➕ [ProjectsDataSource] createProject - id: ${project.id}, name: ${project.name}');
    
    try {
      final projectData = _mapProjectToData(project);
      await _projectsCollection.doc(project.id).set(projectData);
      
      _logger.i('✅ [ProjectsDataSource] createProject - successfully created project: ${project.id}');
    } catch (e) {
      _logger.e('❌ [ProjectsDataSource] createProject - error creating project: ${project.id}', error: e);
      rethrow;
    }
  }

  Future<void> updateProject(Project project) async {
    _logger.i('✏️ [ProjectsDataSource] updateProject - id: ${project.id}, name: ${project.name}');
    
    try {
      final doc = await _projectsCollection.doc(project.id).get();
      if (!doc.exists) {
        _logger.e('❌ [ProjectsDataSource] updateProject - project not found: ${project.id}');
        throw Exception('Project not found: ${project.id}');
      }
      
      final projectData = _mapProjectToData(project);
      await _projectsCollection.doc(project.id).update(projectData);
      
      _logger.i('✅ [ProjectsDataSource] updateProject - successfully updated project: ${project.id}');
    } catch (e) {
      _logger.e('❌ [ProjectsDataSource] updateProject - error updating project: ${project.id}', error: e);
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    _logger.i('🗑️ [ProjectsDataSource] deleteProject - projectId: $projectId');
    
    try {
      final doc = await _projectsCollection.doc(projectId).get();
      if (!doc.exists) {
        _logger.e('❌ [ProjectsDataSource] deleteProject - project not found: $projectId');
        throw Exception('Project not found: $projectId');
      }
      
      await _projectsCollection.doc(projectId).delete();
      
      _logger.i('✅ [ProjectsDataSource] deleteProject - successfully deleted project: $projectId');
    } catch (e) {
      _logger.e('❌ [ProjectsDataSource] deleteProject - error deleting project: $projectId', error: e);
      rethrow;
    }
  }

  Project _mapDataToProject(Map<String, dynamic> data) {
    return Project(id: data['id'], name: data['name'], createdAt: DateTime.parse(data['createdAt']));
  }

  Project _mapDocToProject(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return _mapDataToProject(data);
  }

  Map<String, dynamic> _mapProjectToData(Project project) {
    return {'id': project.id, 'name': project.name, 'createdAt': project.createdAt.toIso8601String()};
  }
}
