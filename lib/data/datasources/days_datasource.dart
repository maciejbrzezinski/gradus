import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/day.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/logger_service.dart';

@injectable
class DaysDataSource {
  final FirebaseFirestore _firestore;
  final AuthService _authService;
  final LoggerService _logger;

  DaysDataSource(this._firestore, this._authService, this._logger);

  String get _userId => _authService.currentUserId;

  CollectionReference get _daysCollection => 
    _firestore.collection('users').doc(_userId).collection('days');

  Stream<List<Day>> watchDays({required String projectId, required DateTime startDate, required DateTime endDate}) {
    _logger.i('🔍 [DaysDataSource] watchDays - projectId: $projectId, startDate: $startDate, endDate: $endDate');
    
    return _daysCollection
        .where('projectId', isEqualTo: projectId)
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .snapshots()
        .map((snapshot) {
      _logger.d('📊 [DaysDataSource] watchDays - received ${snapshot.docs.length} documents from Firestore');
      
      final existingDays = <String, Day>{};
      
      // Map existing days from Firestore
      for (final doc in snapshot.docs) {
        final day = _mapDocToDay(doc);
        final dayKey = _getDayDocId(day.date, day.projectId);
        existingDays[dayKey] = day;
        _logger.d('📅 [DaysDataSource] watchDays - mapped day: ${day.date} with ${day.itemIds.length} items');
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
      
      _logger.i('✅ [DaysDataSource] watchDays - returning ${allDays.length} days total');
      return allDays;
    });
  }

  Future<Day> updateDay(Day day) async {
    final dayId = _getDayDocId(day.date, day.projectId);
    final dayData = _mapDayToData(day);
    
    _logger.i('💾 [DaysDataSource] updateDay - dayId: $dayId, itemIds: ${day.itemIds}');
    
    try {
      await _daysCollection.doc(dayId).set(dayData);
      _logger.i('✅ [DaysDataSource] updateDay - successfully updated day: $dayId');
      return day;
    } catch (e) {
      _logger.e('❌ [DaysDataSource] updateDay - error updating day: $dayId', error: e);
      rethrow;
    }
  }

  Future<void> moveItemBetweenDays({
    required String itemId,
    required Day fromDay,
    required Day toDay,
    required int toIndex,
  }) async {
    _logger.i('🔄 [DaysDataSource] moveItemBetweenDays - itemId: $itemId, from: ${fromDay.date}, to: ${toDay.date}, toIndex: $toIndex');
    
    try {
      // Check if it's the same day (same date and projectId)
      final isSameDay = fromDay.date.isAtSameMomentAs(toDay.date) && 
                       fromDay.projectId == toDay.projectId;
      
      if (isSameDay) {
        _logger.i('🔄 [DaysDataSource] moveItemBetweenDays - same day reordering detected');
        
        // Handle same-day reordering
        final currentIndex = fromDay.itemIds.indexOf(itemId);
        if (currentIndex == -1) {
          _logger.w('⚠️ [DaysDataSource] moveItemBetweenDays - item not found in source day: $itemId');
          return;
        }
        
        final updatedItemIds = List<String>.from(fromDay.itemIds);
        updatedItemIds.removeAt(currentIndex);
        
        // Adjust target index if moving within same list
        final adjustedIndex = toIndex > currentIndex ? toIndex - 1 : toIndex;
        final finalIndex = adjustedIndex.clamp(0, updatedItemIds.length);
        updatedItemIds.insert(finalIndex, itemId);
        
        final updatedDay = fromDay.copyWith(itemIds: updatedItemIds);
        await updateDay(updatedDay);
        
        _logger.i('✅ [DaysDataSource] moveItemBetweenDays - successfully reordered item within same day: $itemId ($currentIndex -> $finalIndex)');
      } else {
        _logger.i('🔄 [DaysDataSource] moveItemBetweenDays - cross-day move detected');
        
        // Handle cross-day moves (existing logic)
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
        
        _logger.i('✅ [DaysDataSource] moveItemBetweenDays - successfully moved item between days: $itemId');
      }
    } catch (e) {
      _logger.e('❌ [DaysDataSource] moveItemBetweenDays - error moving item: $itemId', error: e);
      rethrow;
    }
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
    _logger.i('📋 [DaysDataSource] getDays - projectId: $projectId, startDate: $startDate, endDate: $endDate');
    
    try {
      final snapshot = await _daysCollection
          .where('projectId', isEqualTo: projectId)
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      _logger.d('📊 [DaysDataSource] getDays - received ${snapshot.docs.length} documents from Firestore');

      final existingDays = <String, Day>{};
      
      // Map existing days from Firestore
      for (final doc in snapshot.docs) {
        final day = _mapDocToDay(doc);
        final dayKey = _getDayDocId(day.date, day.projectId);
        existingDays[dayKey] = day;
        _logger.d('📅 [DaysDataSource] getDays - mapped day: ${day.date} with ${day.itemIds.length} items');
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
      
      _logger.i('✅ [DaysDataSource] getDays - returning ${allDays.length} days total');
      return allDays;
    } catch (e) {
      _logger.e('❌ [DaysDataSource] getDays - error fetching days', error: e);
      rethrow;
    }
  }
}
