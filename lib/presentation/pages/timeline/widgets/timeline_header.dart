import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradus/core/theme/app_theme.dart';

import '../../../cubits/timeline/timeline_cubit.dart';
import '../../../cubits/timeline/timeline_state.dart';
import '../../../widgets/shared/animated_project_tabs.dart';

class TimelineHeader extends StatelessWidget {
  const TimelineHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: const BorderRadius.all(Radius.circular(AppTheme.radiusXLarge)),
          boxShadow: AppTheme.subtleShadow,
        ),
        child: Row(
          children: [
            Container(
              width: AppTheme.spacing24,
              height: AppTheme.spacing24,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(Icons.timeline, color: AppTheme.textOnPrimary, size: 16),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Text(
              'Gradus', 
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            // Animated project tabs
            BlocBuilder<TimelineCubit, TimelineState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const SizedBox(
                    width: AppTheme.spacing20,
                    height: AppTheme.spacing20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  loaded: (days, selectedProject, availableProjects, _, _) {
                    return AnimatedProjectTabs(
                      selectedProject: selectedProject,
                      availableProjects: availableProjects,
                      onProjectChanged: (projectId) {
                        context.read<TimelineCubit>().switchProject(projectId);
                      },
                    );
                  },
                  error: (failure) => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
