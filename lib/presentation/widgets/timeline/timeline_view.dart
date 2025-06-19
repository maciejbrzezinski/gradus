import 'package:flutter/material.dart';

import '../../../domain/entities/day.dart';
import '../../../domain/entities/project.dart';
import 'day_column.dart';

class TimelineView extends StatefulWidget {
  final List<Day> days;
  final Project? selectedProject;
  final Function(bool loadPrevious) onLoadMoreDays;

  const TimelineView({super.key, required this.days, required this.selectedProject, required this.onLoadMoreDays});

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
      return const Center(child: Text('Brak dni do wyświetlenia'));
    }

    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.days.length,
      itemBuilder: (context, index) {
        final day = widget.days[index];

        return Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            width: dayWidth,
            child: DayColumn(day: day, isToday: _isToday(day.date)),
          ),
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year && date.month == today.month && date.day == today.day;
  }
}
