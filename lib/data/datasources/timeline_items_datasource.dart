import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/timeline_item.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/note.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/logger_service.dart';

@injectable
class TimelineItemsDataSource {
  final FirebaseFirestore _firestore;
  final AuthService _authService;
  final LoggerService _logger;

  final StreamController<TimelineItem> _itemsController = StreamController<TimelineItem>.broadcast();
  bool _firestoreStreamInitialized = false;

  TimelineItemsDataSource(this._firestore, this._authService, this._logger);

  String get _userId {
    try {
      final userId = _authService.currentUserId;
      _logger.d('🔍 [TimelineItemsDataSource] Current userId: $userId');
      return userId;
    } catch (e) {
      _logger.e('❌ [TimelineItemsDataSource] Failed to get userId: $e');
      rethrow;
    }
  }

  CollectionReference get _timelineItemsCollection =>
      _firestore.collection('users').doc(_userId).collection('timeline_items');

  void _initializeFirestoreStream() {
    if (_firestoreStreamInitialized) return;

    _firestoreStreamInitialized = true;
    _logger.i('🔄 [TimelineItemsDataSource] Initializing Firestore stream');

    // Listen to all changes in the timeline items collection
    _timelineItemsCollection.snapshots().listen(
      (snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.doc.exists) {
            try {
              final item = _mapDocToTimelineItem(change.doc);
              _logger.d('📊 [TimelineItemsDataSource] Firestore update - item: ${item.id}, type: ${item.runtimeType}');
              _itemsController.add(item);
            } catch (e) {
              _logger.e('❌ [TimelineItemsDataSource] Error mapping Firestore doc: ${change.doc.id}', error: e);
            }
          }
        }
      },
      onError: (error) {
        _logger.e('❌ [TimelineItemsDataSource] Firestore stream error', error: error);
      },
    );
  }

  Future<TimelineItem> getTimelineItem(String itemId) async {
    _logger.i('📋 [TimelineItemsDataSource] getTimelineItem - itemId: $itemId');

    try {
      final doc = await _timelineItemsCollection.doc(itemId).get();

      if (!doc.exists) {
        _logger.e('❌ [TimelineItemsDataSource] getTimelineItem - timeline item not found: $itemId');
        throw Exception('Timeline item not found: $itemId');
      }

      final item = _mapDocToTimelineItem(doc);
      _logger.i('✅ [TimelineItemsDataSource] getTimelineItem - found item: $itemId, type: ${item.runtimeType}');

      return item;
    } catch (e) {
      _logger.e('❌ [TimelineItemsDataSource] getTimelineItem - error fetching item: $itemId', error: e);
      rethrow;
    }
  }

  Future<void> createTimelineItem(TimelineItem item) async {
    final itemType = item.when(task: (_) => 'task', note: (_) => 'note');
    _logger.i('➕ [TimelineItemsDataSource] createTimelineItem - id: ${item.id}, type: $itemType');

    try {
      // 2. Save to Firestore in background
      final data = _mapTimelineItemToData(item);
      await _timelineItemsCollection.doc(item.id).set(data);
      _itemsController.add(item);

      _logger.i('✅ [TimelineItemsDataSource] createTimelineItem - successfully created item: ${item.id}');
    } catch (e) {
      _logger.e('❌ [TimelineItemsDataSource] createTimelineItem - error creating item: ${item.id}', error: e);
      rethrow;
    }
  }

  Future<void> updateTimelineItem(TimelineItem item) async {
    final itemType = item.when(task: (_) => 'task', note: (_) => 'note');
    _logger.i('✏️ [TimelineItemsDataSource] updateTimelineItem - id: ${item.id}, type: $itemType');

    try {
      // 2. Check if item exists and update in Firestore
      final doc = await _timelineItemsCollection.doc(item.id).get();
      if (!doc.exists) {
        _logger.e('❌ [TimelineItemsDataSource] updateTimelineItem - timeline item not found: ${item.id}');
        throw Exception('Timeline item not found: ${item.id}');
      }

      final data = _mapTimelineItemToData(item);
      await _timelineItemsCollection.doc(item.id).update(data);
      _itemsController.add(item);

      _logger.i('✅ [TimelineItemsDataSource] updateTimelineItem - successfully updated item: ${item.id}');
    } catch (e) {
      _logger.e('❌ [TimelineItemsDataSource] updateTimelineItem - error updating item: ${item.id}', error: e);
      rethrow;
    }
  }

  Future<void> deleteTimelineItem(String itemId) async {
    _logger.i('🗑️ [TimelineItemsDataSource] deleteTimelineItem - itemId: $itemId');

    try {
      final doc = await _timelineItemsCollection.doc(itemId).get();
      if (!doc.exists) {
        _logger.e('❌ [TimelineItemsDataSource] deleteTimelineItem - timeline item not found: $itemId');
        throw Exception('Timeline item not found: $itemId');
      }

      await _timelineItemsCollection.doc(itemId).delete();

      _logger.i('✅ [TimelineItemsDataSource] deleteTimelineItem - successfully deleted item: $itemId');
    } catch (e) {
      _logger.e('❌ [TimelineItemsDataSource] deleteTimelineItem - error deleting item: $itemId', error: e);
      rethrow;
    }
  }

  Future<List<TimelineItem>> getTimelineItems(List<String> itemIds) async {
    _logger.i('📋 [TimelineItemsDataSource] getTimelineItems - itemIds: ${itemIds.length} items');

    if (itemIds.isEmpty) return [];

    try {
      final items = <TimelineItem>[];

      // Firestore has a limit of 10 items per 'in' query, so we batch them
      const batchSize = 10;
      for (int i = 0; i < itemIds.length; i += batchSize) {
        final batch = itemIds.skip(i).take(batchSize).toList();

        final querySnapshot = await _timelineItemsCollection.where(FieldPath.documentId, whereIn: batch).get();

        for (final doc in querySnapshot.docs) {
          if (doc.exists) {
            try {
              final item = _mapDocToTimelineItem(doc);
              items.add(item);
            } catch (e) {
              _logger.e('❌ [TimelineItemsDataSource] Error mapping doc: ${doc.id}', error: e);
            }
          }
        }
      }

      _logger.i('✅ [TimelineItemsDataSource] getTimelineItems - found ${items.length} items');
      return items;
    } catch (e) {
      _logger.e('❌ [TimelineItemsDataSource] getTimelineItems - error', error: e);
      rethrow;
    }
  }

  Stream<TimelineItem> watchTimelineItems() {
    _logger.i('🔍 [TimelineItemsDataSource] watchTimelineItems');
    _initializeFirestoreStream();
    return _itemsController.stream.distinct();
  }

  TimelineItem _mapDataToTimelineItem(Map<String, dynamic> data) {
    final type = data['type'] as String;

    switch (type) {
      case 'task':
        final task = Task.fromJson(data);
        return TimelineItem.task(task);
      case 'note':
      case 'text':
        if (data['type'] == 'note') {
          data['type'] = 'text';
        }
        final note = Note.fromJson(data);
        return TimelineItem.note(note);
      default:
        throw Exception('Unknown timeline item type: $type');
    }
  }

  TimelineItem _mapDocToTimelineItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return _mapDataToTimelineItem(data);
  }

  Map<String, dynamic> _mapTimelineItemToData(TimelineItem item) {
    return item.when(task: (task) => task.toJson(), note: (note) => note.toJson());
  }

  void dispose() {
    _itemsController.close();
    _logger.d('🧹 [TimelineItemsDataSource] Stream controller disposed');
  }
}
