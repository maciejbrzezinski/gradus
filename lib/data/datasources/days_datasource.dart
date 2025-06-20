import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/day.dart';
import '../../core/services/auth_service.dart';

@injectable
class DaysDataSource {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  DaysDataSource(this._firestore, this._authService);

  String get _userId => _authService.currentUserId;

  CollectionReference get _daysCollection => 
    _firestore.collection('users').doc(_userId).collection('days');

  Stream<List<Day>> watchDays({required String projectId, required DateTime startDate, required DateTime endDate}) {
    return _daysCollection
        .where('projectId', isEqualTo: projectId)
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .snapshots()
        .map((snapshot) {
      final existingDays = <String, Day>{};
      
      // Map existing days from Firestore
      for (final doc in snapshot.docs) {
        final day = _mapDocToDay(doc);
        final dayKey = _getDayDocId(day.date, day.projectId);
        existingDays[dayKey] = day;
      }
      
      // Generate complete list including empty days
      final allDays = <Day>[];
      for (
        DateTime date = startDate;
        date.isBefore(endDate.add(Duration(days: 1)));
        date = date.add(Duration(days: 1))
      ) {
        final dayKey = _getDayDocId(date, projectId);
        final existingDay = existingDays[dayKey];
        
        if (existingDay != null) {
          allDays.add(existingDay);
        } else {
          // Create empty day if not exists
          allDays.add(Day(date: date, projectId: projectId, itemIds: []));
        }
      }
      
      return allDays;
    });
  }

  Future<Day> updateDay(Day day) async {
    final dayId = _getDayDocId(day.date, day.projectId);
    final dayData = _mapDayToData(day);
    
    await _daysCollection.doc(dayId).set(dayData);
    return day;
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

  Day _mapDocToDay(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return _mapDataToDay(data);
  }

  Map<String, dynamic> _mapDayToData(Day day) {
    return {'date': day.date.toIso8601String(), 'projectId': day.projectId, 'itemIds': day.itemIds};
  }

  String _getDayDocId(DateTime date, String projectId) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return '${projectId}_$dateStr';
  }

  Future<List<Day>> getDays({required String projectId, required DateTime startDate, required DateTime endDate}) async {
    final snapshot = await _daysCollection
        .where('projectId', isEqualTo: projectId)
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .get();

    final existingDays = <String, Day>{};
    
    // Map existing days from Firestore
    for (final doc in snapshot.docs) {
      final day = _mapDocToDay(doc);
      final dayKey = _getDayDocId(day.date, day.projectId);
      existingDays[dayKey] = day;
    }
    
    // Generate complete list including empty days
    final allDays = <Day>[];
    for (
      DateTime date = startDate;
      date.isBefore(endDate.add(Duration(days: 1)));
      date = date.add(Duration(days: 1))
    ) {
      final dayKey = _getDayDocId(date, projectId);
      final existingDay = existingDays[dayKey];
      
      if (existingDay != null) {
        allDays.add(existingDay);
      } else {
        // Create empty day if not exists
        allDays.add(Day(date: date, projectId: projectId, itemIds: []));
      }
    }
    
    return allDays;
  }
}
