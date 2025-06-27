import 'package:flutter/material.dart';
import 'package:gradus/core/utils/date_utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/day.dart';
import 'timeline_item_widget.dart';
import 'empty_day_widget.dart';
import 'drop_zone_widget.dart';
import '../../cubits/focus/focus_cubit.dart';

class DayColumn extends StatefulWidget {
  final Day day;
  final bool isToday;

  const DayColumn({super.key, required this.day, required this.isToday});

  @override
  State<DayColumn> createState() => _DayColumnState();
}

class _DayColumnState extends State<DayColumn> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.day.itemIds.isNotEmpty) {
          final firstItemId = widget.day.itemIds.first;
          context.read<FocusCubit>().setFocus(firstItemId);
        }
      },
      child: AnimatedContainer(
        duration: AppTheme.animationDuration,
        curve: AppTheme.animationCurve,
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
        child: Column(
          children: [
            _buildDayHeader(context),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (widget.day.itemIds.isNotEmpty) {
                    final firstItemId = widget.day.itemIds.last;
                    context.read<FocusCubit>().setFocus(firstItemId);
                  }
                },
                child: _buildItemsList(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayHeader(BuildContext context) {
    String dayName;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    if (widget.day.date.isSameDay(today)) {
      dayName = 'Today';
    } else if (widget.day.date.isSameDay(yesterday)) {
      dayName = 'Yesterday';
    } else if (widget.day.date.isSameDay(tomorrow)) {
      dayName = 'Tomorrow';
    } else {
      dayName = DateFormat('EEEE', 'en_US').format(widget.day.date);
    }

    final fullDateString = DateFormat('MMM d, yyyy').format(widget.day.date);

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Text(
        '$dayName, $fullDateString',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: widget.isToday ? AppTheme.primaryColor : AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildItemsList(BuildContext context) {
    if (widget.day.itemIds.isEmpty) {
      return Column(
        children: [
          // Drop zone for empty day
          DropZoneWidget(targetIndex: 0, day: widget.day),
          Expanded(child: EmptyDayWidget(day: widget.day)),
        ],
      );
    }

    final itemCount = widget.day.itemIds.length * 2 + 1; // Items + drop zones + bottom tap zone

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index.isEven) {
          // Drop zone
          final dropIndex = index ~/ 2;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (dropIndex < widget.day.itemIds.length) {
                final itemId = widget.day.itemIds[dropIndex];
                context.read<FocusCubit>().setFocus(itemId);
              }
            },
            child: DropZoneWidget(
              targetIndex: dropIndex,
              day: widget.day,
              isLastZone: dropIndex == widget.day.itemIds.length,
            ),
          );
        } else {
          // Timeline item
          final itemIndex = index ~/ 2;
          final itemId = widget.day.itemIds[itemIndex];
          return TimelineItemWidget(key: ValueKey(itemId), itemId: itemId, day: widget.day);
        }
      },
    );
  }
}
