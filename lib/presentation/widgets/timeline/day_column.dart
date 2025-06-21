import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/day.dart';
import '../../cubits/timeline/timeline_cubit.dart';
import 'timeline_item_widget.dart';
import 'add_item_widget.dart';

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
    return Column(
      children: [
        _buildDayHeader(context),
        Expanded(child: _buildItemsList(context)),
      ],
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
    return DragTarget<Map<String, dynamic>>(
      onAcceptWithDetails: (details) {
        final data = details.data;
        final itemId = data['itemId'] as String;
        final fromDay = data['fromDay'] as Day;

        context.read<TimelineCubit>().moveItemBetweenDays(itemId: itemId, fromDay: fromDay, toDay: widget.day);
      },
      builder: (context, candidateData, rejectedData) {
        final isDragOver = candidateData.isNotEmpty;
        
        return Column(
          children: [
            if (widget.day.itemIds.isEmpty && isDragOver)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing24,
                  vertical: AppTheme.spacing16,
                ),
                child: Container(
                  width: double.infinity,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            Expanded(
              child: Container(
                decoration: isDragOver && widget.day.itemIds.isNotEmpty
                  ? BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.02),
                    )
                  : null,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: widget.day.itemIds.length + 1, // +1 for AddItemWidget
                  itemBuilder: (context, index) {
                    if (index == widget.day.itemIds.length) {
                      // Last item is the AddItemWidget
                      return AddItemWidget(day: widget.day);
                    }
                    
                    final itemId = widget.day.itemIds[index];
                    return TimelineItemWidget(
                      key: ValueKey(itemId), 
                      itemId: itemId, 
                      day: widget.day,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
