import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/day.dart';
import '../../cubits/timeline/timeline_cubit.dart';
import 'timeline_item_widget.dart';

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

    return Container(
      padding: const EdgeInsets.all(20),
      child: Text(
        dayName,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  Widget _buildItemsList(BuildContext context) {
    if (widget.day.itemIds.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No items',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return DragTarget<Map<String, dynamic>>(
      onAcceptWithDetails: (details) {
        final data = details.data;
        final itemId = data['itemId'] as String;
        final fromDay = data['fromDay'] as Day;

        context.read<TimelineCubit>().moveItemBetweenDays(itemId: itemId, fromDay: fromDay, toDay: widget.day);
      },
      builder: (context, candidateData, rejectedData) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: widget.day.itemIds.length,
          itemBuilder: (context, index) {
            final itemId = widget.day.itemIds[index];
            return TimelineItemWidget(key: ValueKey(itemId), itemId: itemId, day: widget.day);
          },
        );
      },
    );
  }
}
