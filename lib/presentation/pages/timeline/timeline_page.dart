import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../cubits/timeline/timeline_cubit.dart';
import '../../cubits/timeline/timeline_state.dart';
import '../../widgets/timeline/timeline_view.dart';
import '../../widgets/shared/project_selector.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => getIt<TimelineCubit>(), child: const TimelinePageView());
  }
}

class TimelinePageView extends StatelessWidget {
  const TimelinePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Jasne tło jak na designie
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16), // Dodatkowa przestrzeń pod headerem
            Expanded(
              child: BlocBuilder<TimelineCubit, TimelineState>(
                builder: (context, state) {
                  return state.when(
                    initial: () => const Center(child: CircularProgressIndicator()),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    loaded: (days, selectedProject, availableProjects) {
                      return TimelineView(
                        days: days,
                        selectedProject: selectedProject,
                        onLoadMoreDays: (loadPrevious) {
                          context.read<TimelineCubit>().loadMoreDays(loadPrevious: loadPrevious);
                        },
                      );
                    },
                    error: (failure) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
                          const SizedBox(height: 16),
                          Text('Wystąpił błąd', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 8),
                          Text(
                            failure.message,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: () {
                              // todo ponownie załaduj dane
                            },
                            child: const Text('Spróbuj ponownie'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          // Ikona Gradus (placeholder - można zastąpić właściwą ikoną)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
            child: const Icon(Icons.timeline, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            'Gradus',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const Spacer(),
          // Project selector w headerze
          BlocBuilder<TimelineCubit, TimelineState>(
            builder: (context, state) {
              return state.when(
                initial: () => const SizedBox.shrink(),
                loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                loaded: (days, selectedProject, availableProjects) {
                  return ProjectSelector(
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
    );
  }
}
