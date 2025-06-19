import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../domain/entities/project.dart';

@injectable
class ProjectsDataSource {
  // Mock data storage - in real implementation this would be Firestore
  final Map<String, Map<String, dynamic>> _projects = {};
  final StreamController<Map<String, Map<String, dynamic>>> _projectsController = 
      StreamController<Map<String, Map<String, dynamic>>>.broadcast();

  ProjectsDataSource() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    
    // Create default projects
    _projects['personal-project-id'] = {
      'id': 'personal-project-id',
      'name': 'Personal',
      'createdAt': now.subtract(const Duration(days: 30)).toIso8601String(),
    };
    
    _projects['work-project-id'] = {
      'id': 'work-project-id',
      'name': 'Work',
      'createdAt': now.subtract(const Duration(days: 25)).toIso8601String(),
    };
    
    _projectsController.add(Map.from(_projects));
  }

  Stream<List<Project>> watchProjects() {
    return _projectsController.stream
        .map((projectsData) => projectsData.values
            .map((data) => _mapDataToProject(data))
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt)));
  }

  Future<List<Project>> getProjects() async {
    return _projects.values
        .map((data) => _mapDataToProject(data))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<Project?> getProjectById(String projectId) async {
    final projectData = _projects[projectId];
    if (projectData == null) return null;
    return _mapDataToProject(projectData);
  }

  Future<void> createProject(Project project) async {
    _projects[project.id] = _mapProjectToData(project);
    _projectsController.add(Map.from(_projects));
  }

  Future<void> updateProject(Project project) async {
    if (!_projects.containsKey(project.id)) {
      throw Exception('Project not found: ${project.id}');
    }
    _projects[project.id] = _mapProjectToData(project);
    _projectsController.add(Map.from(_projects));
  }

  Future<void> deleteProject(String projectId) async {
    if (!_projects.containsKey(projectId)) {
      throw Exception('Project not found: $projectId');
    }
    _projects.remove(projectId);
    _projectsController.add(Map.from(_projects));
  }

  Project _mapDataToProject(Map<String, dynamic> data) {
    return Project(
      id: data['id'],
      name: data['name'],
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  Map<String, dynamic> _mapProjectToData(Project project) {
    return {
      'id': project.id,
      'name': project.name,
      'createdAt': project.createdAt.toIso8601String(),
    };
  }

  void dispose() {
    _projectsController.close();
  }
}
