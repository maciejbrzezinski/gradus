import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/timeline_item.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_type.dart';
import '../../core/services/auth_service.dart';

@injectable
class TimelineItemsDataSource {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  TimelineItemsDataSource(this._firestore, this._authService);

  String get _userId => _authService.currentUserId;

  CollectionReference get _timelineItemsCollection => 
    _firestore.collection('users').doc(_userId).collection('timeline_items');

  Stream<TimelineItem> watchTimelineItem(String itemId) {
    return _timelineItemsCollection
        .doc(itemId)
        .snapshots()
        .where((doc) => doc.exists)
        .map((doc) => _mapDocToTimelineItem(doc));
  }

  Future<TimelineItem> getTimelineItem(String itemId) async {
    final doc = await _timelineItemsCollection.doc(itemId).get();
    if (!doc.exists) {
      throw Exception('Timeline item not found: $itemId');
    }
    return _mapDocToTimelineItem(doc);
  }

  Future<void> createTimelineItem(TimelineItem item) async {
    final data = _mapTimelineItemToData(item);
    await _timelineItemsCollection.doc(item.id).set(data);
  }

  Future<void> updateTimelineItem(TimelineItem item) async {
    final doc = await _timelineItemsCollection.doc(item.id).get();
    if (!doc.exists) {
      throw Exception('Timeline item not found: ${item.id}');
    }
    final data = _mapTimelineItemToData(item);
    await _timelineItemsCollection.doc(item.id).update(data);
  }

  Future<void> deleteTimelineItem(String itemId) async {
    final doc = await _timelineItemsCollection.doc(itemId).get();
    if (!doc.exists) {
      throw Exception('Timeline item not found: $itemId');
    }
    await _timelineItemsCollection.doc(itemId).delete();
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
