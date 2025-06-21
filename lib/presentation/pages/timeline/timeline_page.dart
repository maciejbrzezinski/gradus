import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../cubits/timeline/timeline_cubit.dart';
import '../../cubits/timeline/timeline_state.dart';
import '../../widgets/timeline/timeline_view.dart';
import '../../widgets/shared/gradus_button.dart';
import 'widgets/timeline_header.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TimelineCubit>(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              const TimelineHeader(),
              const SizedBox(height: AppTheme.spacing16),
              Expanded(
                child: BlocBuilder<TimelineCubit, TimelineState>(
                  builder: (context, state) {
                    return state.when(
                      initial: () => _buildLoadingState(),
                      loading: () => _buildLoadingState(),
                      loaded: (days, selectedProject, availableProjects) {
                        return TimelineView(
                          days: days,
                          selectedProject: selectedProject,
                          onLoadMoreDays: (loadPrevious) {
                            context.read<TimelineCubit>().loadMoreDays(loadPrevious: loadPrevious);
                          },
                        );
                      },
                      error: (failure) => _buildErrorState(context, failure),
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
                context.read<TimelineCubit>().loadInitialData();
              },
            ),
          ],
        ),
      ),
    );
  }
}
