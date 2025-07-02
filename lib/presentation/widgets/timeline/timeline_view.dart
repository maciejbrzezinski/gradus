import 'package:flutter/material.dart';
import 'package:gradus/core/utils/date_utils.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/day.dart';
import '../../../domain/entities/project.dart';
import 'day_column.dart';

class TimelineView extends StatefulWidget {
  final List<Day> days;
  final Project? selectedProject;
  final DateTime dateFrom;
  final DateTime dateTo;
  final Function(bool loadPrevious) onLoadMoreDays;

  const TimelineView({
    super.key,
    required this.days,
    required this.selectedProject,
    required this.onLoadMoreDays,
    required this.dateFrom,
    required this.dateTo,
  });

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  late ScrollController _scrollController;
  PageController? _pageController;

  static const double dayWidth = 500.0;
  static const double loadThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageController ??= PageController(viewportFraction: dayWidth / MediaQuery.of(context).size.width);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  void _scrollToToday() {
    final today = DateTime.now();
    final todayIndex = widget.days.indexWhere(
      (day) => day.date.year == today.year && day.date.month == today.month && day.date.day == today.day,
    );

    if (todayIndex != -1) {
      final targetOffset = todayIndex * dayWidth;
      _scrollController.animateTo(targetOffset, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Załaduj poprzednie dni gdy przewijamy w lewo
    if (currentScroll < loadThreshold) {
      // widget.onLoadMoreDays(true);
    }

    // Załaduj następne dni gdy przewijamy w prawo
    if (currentScroll > maxScroll - loadThreshold) {
      // widget.onLoadMoreDays(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.days.isEmpty) {
      return _buildEmptyState(context);
    }
    final daysCount = widget.dateFrom.difference(widget.dateTo).inDays.abs() + 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: daysCount,
        itemBuilder: (context, index) {
          final date = widget.dateFrom.add(Duration(days: index));

          final day = widget.days.firstWhere(
            (day) => day.date.isSameDay(date),
            orElse: () => Day(date: date, projectId: widget.selectedProject?.id ?? '', itemIds: [], updatedAt: DateTime.now()),
          );
          final isToday = day.date.isToday();

          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacing16),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                boxShadow: AppTheme.subtleShadow,
                border: isToday ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 2) : null,
              ),
              width: dayWidth,
              child: DayColumn(day: day, isToday: isToday),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
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
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: const Icon(Icons.calendar_today, size: 32, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: AppTheme.spacing24),
            Text(
              'No days to display',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Your timeline will appear here once data is loaded',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
