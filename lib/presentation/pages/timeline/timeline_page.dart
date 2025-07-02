import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../cubits/timeline/projects/projects_cubit.dart';
import '../../cubits/timeline/projects/projects_state.dart';
import '../../cubits/timeline/timeline_cubit.dart';
import '../../cubits/timeline/timeline_state.dart';
import '../../widgets/timeline/timeline_view.dart';
import '../../widgets/shared/gradus_button.dart';
import 'widgets/timeline_header.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ProjectsCubit>()),
        BlocProvider(create: (context) => getIt<TimelineCubit>()),
      ],
      child: _TimelinePageContent(),
    );
  }
}

class _TimelinePageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectsCubit, ProjectsState>(
      listener: (context, state) {
        if (state is ProjectsLoaded && state.selectedProject != null) {
          final timelineState = context.read<TimelineCubit>().state;
          final dateRange = timelineState is TimelineLoaded 
            ? (timelineState.startDate, timelineState.endDate)
            : (DateTime.now().subtract(const Duration(days: 7)), DateTime.now().add(const Duration(days: 7)));
          
          context.read<TimelineCubit>().loadTimelineForProject(
            state.selectedProject!.id,
            dateRange.$1,
            dateRange.$2,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              const TimelineHeader(),
              const SizedBox(height: AppTheme.spacing16),
              Expanded(
                child: BlocBuilder<TimelineCubit, TimelineState>(
                  builder: (context, timelineState) {
                    return BlocBuilder<ProjectsCubit, ProjectsState>(
                      builder: (context, projectsState) {
                        if (timelineState is TimelineLoading || projectsState is ProjectsLoading) {
                          return _buildLoadingState();
                        }
                        
                        if (timelineState is TimelineError) {
                          return _buildErrorState(context, timelineState.failure);
                        }
                        
                        if (projectsState is ProjectsError) {
                          return _buildErrorState(context, projectsState.failure);
                        }
                        
                        if (timelineState is TimelineLoaded && projectsState is ProjectsLoaded) {
                          return TimelineView(
                            days: timelineState.days,
                            selectedProject: projectsState.selectedProject,
                            onLoadMoreDays: (loadPrevious) {
                              context.read<TimelineCubit>().loadMoreDays(loadPrevious: loadPrevious);
                            },
                            dateFrom: timelineState.startDate,
                            dateTo: timelineState.endDate,
                          );
                        }
                        
                        return _buildLoadingState();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 3),
          SizedBox(height: AppTheme.spacing16),
          Text('Loading your timeline...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, failure) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.all(AppTheme.spacing24),
        padding: const EdgeInsets.all(AppTheme.spacing32),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.subtleShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: const Icon(Icons.error_outline, size: 32, color: AppTheme.error),
            ),
            const SizedBox(height: AppTheme.spacing24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              failure.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing32),
            GradusButton.primary(
              text: 'Try Again',
              isFullWidth: true,
              onPressed: () {
                context.read<ProjectsCubit>().loadProjects();
              },
            ),
          ],
        ),
      ),
    );
  }
}
