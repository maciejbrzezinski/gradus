import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/timeline_item.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_type.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/logger_service.dart';

@injectable
class TimelineItemsDataSource {
  final FirebaseFirestore _firestore;
  final AuthService _authService;
  final LoggerService _logger;

  TimelineItemsDataSource(this._firestore, this._authService, this._logger);

  String get _userId => _authService.currentUserId;

  CollectionReference get _timelineItemsCollection => 
    _firestore.collection('users').doc(_userId).collection('timeline_items');

  Stream<TimelineItem> watchTimelineItem(String itemId) {
    _logger.i('🔍 [TimelineItemsDataSource] watchTimelineItem - itemId: $itemId');
    
    return _timelineItemsCollection
        .doc(itemId)
        .snapshots()
        .where((doc) => doc.exists)
        .map((doc) {
          final item = _mapDocToTimelineItem(doc);
          _logger.d('📊 [TimelineItemsDataSource] watchTimelineItem - received update for item: $itemId, type: ${item.runtimeType}');
          return item;
        });
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
      final data = _mapTimelineItemToData(item);
      await _timelineItemsCollection.doc(item.id).set(data);
      
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
      final doc = await _timelineItemsCollection.doc(item.id).get();
      if (!doc.exists) {
        _logger.e('❌ [TimelineItemsDataSource] updateTimelineItem - timeline item not found: ${item.id}');
        throw Exception('Timeline item not found: ${item.id}');
      }
      
      final data = _mapTimelineItemToData(item);
      await _timelineItemsCollection.doc(item.id).update(data);
      
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

  TimelineItem _mapDataToTimelineItem(Map<String, dynamic> data) {
    final type = data['type'] as String;
    
    switch (type) {
      case 'task':
        final task = Task(
          id: data['id'],
          createdAt: DateTime.parse(data['createdAt']),
          updatedAt: DateTime.parse(data['updatedAt']),
          title: data['title'],
          isCompleted: data['isCompleted'] ?? false,
          description: data['description'],
        );
        return TimelineItem.task(task);
      case 'note':
        final note = Note(
          id: data['id'],
          createdAt: DateTime.parse(data['createdAt']),
          updatedAt: DateTime.parse(data['updatedAt']),
          content: data['content'],
          type: _parseNoteType(data['noteType']),
        );
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
    return item.when(
      task: (task) => {
        'id': task.id,
        'type': 'task',
        'createdAt': task.createdAt.toIso8601String(),
        'updatedAt': task.updatedAt.toIso8601String(),
        'title': task.title,
        'isCompleted': task.isCompleted,
        'description': task.description,
      },
      note: (note) => {
        'id': note.id,
        'type': 'note',
        'createdAt': note.createdAt.toIso8601String(),
        'updatedAt': note.updatedAt.toIso8601String(),
        'content': note.content,
        'noteType': note.type.name,
      },
    );
  }

  NoteType _parseNoteType(String? noteType) {
    switch (noteType) {
      case 'headline1':
        return NoteType.headline1;
      case 'headline2':
        return NoteType.headline2;
      case 'headline3':
        return NoteType.headline3;
      case 'text':
      default:
        return NoteType.text;
    }
  }

}
