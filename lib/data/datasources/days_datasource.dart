import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/day.dart';

@injectable
class DaysDataSource {
  // Mock data storage - in real implementation this would be Firestore
  final Map<String, Map<String, dynamic>> _days = {};
  final StreamController<Map<String, Map<String, dynamic>>> _daysController =
      StreamController<Map<String, Map<String, dynamic>>>.broadcast();

  DaysDataSource() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Initialize with some mock data
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Generate mock days for 15 days with item IDs
    for (int i = -7; i <= 7; i++) {
      final date = today.add(Duration(days: i));
      _generateDayForDate(date);
    }

    _daysController.add(Map.from(_days));
  }

  void _generateDayForDate(DateTime date) {
    final dayOfWeek = date.weekday;

    // Create days for both projects with appropriate item IDs
    final workItemIds = <String>[];
    final personalItemIds = <String>[];

    // Generate item IDs based on day of week (matching the timeline items data source)
    if (dayOfWeek <= 5) {
      // Weekdays
      workItemIds.add('task_${date.millisecondsSinceEpoch}_1');
      personalItemIds.add('task_${date.millisecondsSinceEpoch}_2');
    }

    if (dayOfWeek == 1) {
      // Monday
      workItemIds.addAll(['note_${date.millisecondsSinceEpoch}_1', 'note_${date.millisecondsSinceEpoch}_2']);
    }

    // Create days for both projects
    final workDayId = _getDayDocId(date, 'work-project-id');
    _days[workDayId] = {'date': date.toIso8601String(), 'projectId': 'work-project-id', 'itemIds': workItemIds};

    final personalDayId = _getDayDocId(date, 'personal-project-id');
    _days[personalDayId] = {
      'date': date.toIso8601String(),
      'projectId': 'personal-project-id',
      'itemIds': personalItemIds,
    };
  }

  Stream<List<Day>> watchDays({required String projectId, required DateTime startDate, required DateTime endDate}) {
    return _daysController.stream.map((daysData) {
      final filteredDays = <Day>[];

      for (
        DateTime date = startDate;
        date.isBefore(endDate.add(Duration(days: 1)));
        date = date.add(Duration(days: 1))
      ) {
        final dayId = _getDayDocId(date, projectId);
        final dayData = daysData[dayId];

        if (dayData != null) {
          filteredDays.add(_mapDataToDay(dayData));
        } else {
          // Create empty day if not exists
          filteredDays.add(Day(date: date, projectId: projectId, itemIds: []));
        }
      }

      return filteredDays;
    });
  }

  Future<Day> updateDay(Day day) async {
    final dayId = _getDayDocId(day.date, day.projectId);
    _days[dayId] = _mapDayToData(day);
    _daysController.add(Map.from(_days));
    return day; // Return the updated day
  }

  Future<void> moveItemBetweenDays({
    required String itemId,
    required Day fromDay,
    required Day toDay,
    required int toIndex,
  }) async {
    // Remove from source day
    final updatedFromItemIds = List<String>.from(fromDay.itemIds)..remove(itemId);
    final updatedFromDay = fromDay.copyWith(itemIds: updatedFromItemIds);

    // Add to target day
    final updatedToItemIds = List<String>.from(toDay.itemIds);
    updatedToItemIds.insert(toIndex.clamp(0, updatedToItemIds.length), itemId);
    final updatedToDay = toDay.copyWith(itemIds: updatedToItemIds);

    // Update both days
    await updateDay(updatedFromDay);
    await updateDay(updatedToDay);
  }

  Day _mapDataToDay(Map<String, dynamic> data) {
    return Day(
      date: DateTime.parse(data['date']),
      projectId: data['projectId'],
      itemIds: List<String>.from(data['itemIds'] ?? []),
    );
  }

  Map<String, dynamic> _mapDayToData(Day day) {
    return {'date': day.date.toIso8601String(), 'projectId': day.projectId, 'itemIds': day.itemIds};
  }

  String _getDayDocId(DateTime date, String projectId) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return '${projectId}_$dateStr';
  }

  void dispose() {
    _daysController.close();
  }

  Future<List<Day>> getDays({required String projectId, required DateTime startDate, required DateTime endDate}) async {
    final filteredDays = <Day>[];

    for (
    DateTime date = startDate;
    date.isBefore(endDate.add(Duration(days: 1)));
    date = date.add(Duration(days: 1))
    ) {
      final dayId = _getDayDocId(date, projectId);
      final dayData = _days[dayId];

      if (dayData != null) {
        filteredDays.add(_mapDataToDay(dayData));
      } else {
        // Create empty day if not exists
        filteredDays.add(Day(date: date, projectId: projectId, itemIds: []));
      }
    }

    return filteredDays;
  }
}
