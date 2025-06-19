import 'package:flutter/material.dart';

import '../../../domain/entities/project.dart';

class ProjectSelector extends StatelessWidget {
  final Project? selectedProject;
  final List<Project> availableProjects;
  final Function(String) onProjectChanged;

  const ProjectSelector({
    super.key,
    required this.selectedProject,
    required this.availableProjects,
    required this.onProjectChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (availableProjects.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      onSelected: onProjectChanged,
      itemBuilder: (context) {
        return availableProjects.map((project) {
          return PopupMenuItem<String>(
            value: project.id,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: _getProjectColor(project.id), shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Text(project.name),
                if (selectedProject?.id == project.id) ...[
                  const Spacer(),
                  Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.primary),
                ],
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: _getProjectColor(selectedProject?.id), shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              selectedProject?.name ?? 'Wybierz projekt',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Color _getProjectColor(String? projectId) {
    switch (projectId) {
      case 'personal-project-id':
        return Colors.blue;
      case 'work-project-id':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
