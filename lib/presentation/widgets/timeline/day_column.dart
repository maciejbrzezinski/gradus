import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/day.dart';
import 'timeline_item_widget.dart';
import 'empty_day_widget.dart';
import 'drop_zone_widget.dart';

class DayColumn extends StatefulWidget {
  final Day day;
  final bool isToday;

  const DayColumn({super.key, required this.day, required this.isToday});

  @override
  State<DayColumn> createState() => _DayColumnState();
}

class _DayColumnState extends State<DayColumn> {
  bool _isEditMode = false;

  void _enterEditMode() {
    setState(() {
      _isEditMode = true;
    });
  }

  void _exitEditMode() {
    setState(() {
      _isEditMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _enterEditMode,
      child: AnimatedContainer(
        duration: AppTheme.animationDuration,
        curve: AppTheme.animationCurve,
        decoration: BoxDecoration(
          color: _isEditMode 
            ? AppTheme.primaryColor.withValues(alpha: 0.03)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: _isEditMode 
            ? Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                width: 1.5,
              )
            : null,
        ),
        child: Column(
          children: [
            _buildDayHeader(context),
            Expanded(child: _buildItemsList(context)),
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

    // Sprawdź czy to dzisiaj, wczoraj lub jutro
    if (_isSameDay(widget.day.date, today)) {
      dayName = 'Today';
    } else if (_isSameDay(widget.day.date, yesterday)) {
      dayName = 'Yesterday';
    } else if (_isSameDay(widget.day.date, tomorrow)) {
      dayName = 'Tomorrow';
    } else {
      dayName = DateFormat('EEEE', 'en_US').format(widget.day.date);
    }

    final fullDateString = DateFormat('MMM d, yyyy').format(widget.day.date);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing24,
        AppTheme.spacing24,
        AppTheme.spacing24,
        AppTheme.spacing16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.isToday ? AppTheme.primaryColor : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            fullDateString,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  Widget _buildItemsList(BuildContext context) {
    if (widget.day.itemIds.isEmpty) {
      return Column(
        children: [
          // Drop zone for empty day
          DropZoneWidget(
            targetIndex: 0,
            day: widget.day,
          ),
          Expanded(
            child: EmptyDayWidget(
              day: widget.day,
              onItemCreated: _exitEditMode,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: widget.day.itemIds.length * 2 + 1, // Items + drop zones
      itemBuilder: (context, index) {
        if (index.isEven) {
          // Drop zone
          final dropIndex = index ~/ 2;
          return DropZoneWidget(
            targetIndex: dropIndex,
            day: widget.day,
            isLastZone: dropIndex == widget.day.itemIds.length,
          );
        } else {
          // Timeline item
          final itemIndex = index ~/ 2;
          final itemId = widget.day.itemIds[itemIndex];
          return TimelineItemWidget(
            key: ValueKey(itemId),
            itemId: itemId,
            day: widget.day,
          );
        }
      },
    );
  }
}
