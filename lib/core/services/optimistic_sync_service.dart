import 'dart:async';
import 'package:injectable/injectable.dart';

import '../../domain/entities/day.dart';
import '../../domain/entities/timeline_item.dart';
import '../../domain/repositories/days_repository.dart';
import '../../domain/repositories/timeline_items_repository.dart';
import '../../domain/usecases/days/remove_item_from_day_usecase.dart';
import '../../domain/usecases/timeline_items/delete_timeline_item_usecase.dart';
import 'logger_service.dart';

@injectable
class OptimisticSyncService {
  final DaysRepository _daysRepository;
  final TimelineItemsRepository _timelineItemsRepository;
  final RemoveItemFromDayUseCase _removeItemFromDayUseCase;
  final DeleteTimelineItemUseCase _deleteTimelineItemUseCase;
  final LoggerService _logger;

  final Map<String, Completer<void>> _pendingOperations = {};

  OptimisticSyncService(
    this._daysRepository,
    this._timelineItemsRepository,
    this._removeItemFromDayUseCase,
    this._deleteTimelineItemUseCase,
    this._logger,
  );

  /// Sync a day update in the background
  Future<void> syncDayUpdate(Day day, String operationId) async {
    _logger.i('🔄 [OptimisticSyncService] Starting day sync: $operationId');
    
    final completer = Completer<void>();
    _pendingOperations[operationId] = completer;

    try {
      final result = await _daysRepository.updateDay(day);
      
      result.fold(
        (failure) {
          _logger.e('❌ [OptimisticSyncService] Day sync failed: $operationId', error: failure);
          completer.completeError(failure);
        },
        (_) {
          _logger.i('✅ [OptimisticSyncService] Day sync completed: $operationId');
          completer.complete();
        },
      );
    } catch (e) {
      _logger.e('❌ [OptimisticSyncService] Day sync error: $operationId', error: e);
      completer.completeError(e);
    } finally {
      _pendingOperations.remove(operationId);
    }
  }

  /// Sync a timeline item creation in the background
  Future<void> syncTimelineItemCreation(TimelineItem item, String operationId) async {
    _logger.i('🔄 [OptimisticSyncService] Starting item creation sync: $operationId');
    
    final completer = Completer<void>();
    _pendingOperations[operationId] = completer;

    try {
      final result = await _timelineItemsRepository.createTimelineItem(item);
      
      result.fold(
        (failure) {
          _logger.e('❌ [OptimisticSyncService] Item creation sync failed: $operationId', error: failure);
          completer.completeError(failure);
        },
        (_) {
          _logger.i('✅ [OptimisticSyncService] Item creation sync completed: $operationId');
          completer.complete();
        },
      );
    } catch (e) {
      _logger.e('❌ [OptimisticSyncService] Item creation sync error: $operationId', error: e);
      completer.completeError(e);
    } finally {
      _pendingOperations.remove(operationId);
    }
  }

  /// Sync a timeline item update in the background
  Future<void> syncTimelineItemUpdate(TimelineItem item, String operationId) async {
    _logger.i('🔄 [OptimisticSyncService] Starting item update sync: $operationId');
    
    final completer = Completer<void>();
    _pendingOperations[operationId] = completer;

    try {
      final result = await _timelineItemsRepository.updateTimelineItem(item);
      
      result.fold(
        (failure) {
          _logger.e('❌ [OptimisticSyncService] Item update sync failed: $operationId', error: failure);
          completer.completeError(failure);
        },
        (_) {
          _logger.i('✅ [OptimisticSyncService] Item update sync completed: $operationId');
          completer.complete();
        },
      );
    } catch (e) {
      _logger.e('❌ [OptimisticSyncService] Item update sync error: $operationId', error: e);
      completer.completeError(e);
    } finally {
      _pendingOperations.remove(operationId);
    }
  }

  /// Sync a move operation in the background
  Future<void> syncMoveOperation({
    required String itemId,
    required Day fromDay,
    required Day toDay,
    required int toIndex,
    required String operationId,
  }) async {
    _logger.i('🔄 [OptimisticSyncService] Starting move sync: $operationId');
    
    final completer = Completer<void>();
    _pendingOperations[operationId] = completer;

    try {
      final result = await _daysRepository.moveItemBetweenDays(
        itemId: itemId,
        fromDay: fromDay,
        toDay: toDay,
        toIndex: toIndex,
      );
      
      result.fold(
        (failure) {
          _logger.e('❌ [OptimisticSyncService] Move sync failed: $operationId', error: failure);
          completer.completeError(failure);
        },
        (_) {
          _logger.i('✅ [OptimisticSyncService] Move sync completed: $operationId');
          completer.complete();
        },
      );
    } catch (e) {
      _logger.e('❌ [OptimisticSyncService] Move sync error: $operationId', error: e);
      completer.completeError(e);
    } finally {
      _pendingOperations.remove(operationId);
    }
  }

  /// Check if an operation is still pending
  bool isOperationPending(String operationId) {
    return _pendingOperations.containsKey(operationId);
  }

  /// Wait for a specific operation to complete
  Future<void> waitForOperation(String operationId) async {
    final completer = _pendingOperations[operationId];
    if (completer != null) {
      await completer.future;
    }
  }

  /// Sync an item deletion in the background
  Future<void> syncItemDeletion({
    required String itemId,
    required Day day,
    required String operationId,
  }) async {
    _logger.i('🔄 [OptimisticSyncService] Starting item deletion sync: $operationId');
    
    final completer = Completer<void>();
    _pendingOperations[operationId] = completer;

    try {
      // First remove from day
      final removeResult = await _removeItemFromDayUseCase(
        itemId: itemId,
        day: day,
      );
      
      await removeResult.fold(
        (failure) async {
          _logger.e('❌ [OptimisticSyncService] Remove from day failed: $operationId', error: failure);
          completer.completeError(failure);
        },
        (_) async {
          // Then delete the timeline item
          final deleteResult = await _deleteTimelineItemUseCase(itemId);
          
          deleteResult.fold(
            (failure) {
              _logger.e('❌ [OptimisticSyncService] Item deletion sync failed: $operationId', error: failure);
              completer.completeError(failure);
            },
            (_) {
              _logger.i('✅ [OptimisticSyncService] Item deletion sync completed: $operationId');
              completer.complete();
            },
          );
        },
      );
    } catch (e) {
      _logger.e('❌ [OptimisticSyncService] Item deletion sync error: $operationId', error: e);
      completer.completeError(e);
    } finally {
      _pendingOperations.remove(operationId);
    }
  }

  /// Get all pending operation IDs
  Set<String> get pendingOperationIds => _pendingOperations.keys.toSet();

  /// Cancel all pending operations
  void cancelAllOperations() {
    for (final completer in _pendingOperations.values) {
      if (!completer.isCompleted) {
        completer.completeError('Operation cancelled');
      }
    }
    _pendingOperations.clear();
  }
}
