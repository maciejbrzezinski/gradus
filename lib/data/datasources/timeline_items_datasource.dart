import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../domain/entities/timeline_item.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_type.dart';

@injectable
class TimelineItemsDataSource {
  // Mock data storage - in real implementation this would be Firestore
  final Map<String, Map<String, dynamic>> _items = {};
  final StreamController<Map<String, Map<String, dynamic>>> _itemsController = 
      StreamController<Map<String, Map<String, dynamic>>>.broadcast();

  TimelineItemsDataSource() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Initialize with some mock data that matches the existing hardcoded data
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Generate mock timeline items for 15 days
    for (int i = -7; i <= 7; i++) {
      final date = today.add(Duration(days: i));
      _generateItemsForDay(date);
    }
    
    _itemsController.add(Map.from(_items));
  }

  void _generateItemsForDay(DateTime date) {
    final now = DateTime.now();
    final dayOfWeek = date.weekday;
    
    // Generate tasks
    if (dayOfWeek <= 5) { // Weekdays
      final taskId1 = 'task_${date.millisecondsSinceEpoch}_1';
      _items[taskId1] = {
        'id': taskId1,
        'type': 'task',
        'projectId': 'work-project-id',
        'createdAt': now.subtract(Duration(days: 1)).toIso8601String(),
        'updatedAt': now.subtract(Duration(days: 1)).toIso8601String(),
        'title': 'Daily standup meeting',
        'isCompleted': date.isBefore(DateTime.now()),
        'date': date.toIso8601String(),
        'description': 'Team synchronization meeting',
      };

      final taskId2 = 'task_${date.millisecondsSinceEpoch}_2';
      _items[taskId2] = {
        'id': taskId2,
        'type': 'task',
        'projectId': 'personal-project-id',
        'createdAt': now.subtract(Duration(days: 1)).toIso8601String(),
        'updatedAt': now.subtract(Duration(days: 1)).toIso8601String(),
        'title': 'Morning workout',
        'isCompleted': date.isBefore(DateTime.now()) && date.weekday % 2 == 0,
        'date': date.toIso8601String(),
        'description': '30 minutes cardio exercise',
      };
    }
    
    // Generate notes
    if (dayOfWeek == 1) { // Monday
      final noteId1 = 'note_${date.millisecondsSinceEpoch}_1';
      _items[noteId1] = {
        'id': noteId1,
        'type': 'note',
        'projectId': 'work-project-id',
        'createdAt': now.subtract(Duration(days: 1)).toIso8601String(),
        'updatedAt': now.subtract(Duration(days: 1)).toIso8601String(),
        'content': 'Weekly Goals',
        'noteType': 'headline1',
      };

      final noteId2 = 'note_${date.millisecondsSinceEpoch}_2';
      _items[noteId2] = {
        'id': noteId2,
        'type': 'note',
        'projectId': 'work-project-id',
        'createdAt': now.subtract(Duration(days: 1)).toIso8601String(),
        'updatedAt': now.subtract(Duration(days: 1)).toIso8601String(),
        'content': 'Focus on completing the new feature implementation.',
        'noteType': 'text',
      };
    }
  }

  Stream<TimelineItem> watchTimelineItem(String itemId) {
    return _itemsController.stream
        .map((items) => items[itemId])
        .where((item) => item != null)
        .map((item) => _mapDataToTimelineItem(item!));
  }

  Future<TimelineItem> getTimelineItem(String itemId) async {
    final item = _items[itemId];
    if (item == null) {
      throw Exception('Timeline item not found: $itemId');
    }
    return _mapDataToTimelineItem(item);
  }

  Future<void> createTimelineItem(TimelineItem item) async {
    final data = _mapTimelineItemToData(item);
    _items[item.id] = data;
    _itemsController.add(Map.from(_items));
  }

  Future<void> updateTimelineItem(TimelineItem item) async {
    if (!_items.containsKey(item.id)) {
      throw Exception('Timeline item not found: ${item.id}');
    }
    final data = _mapTimelineItemToData(item);
    _items[item.id] = data;
    _itemsController.add(Map.from(_items));
  }

  Future<void> deleteTimelineItem(String itemId) async {
    if (!_items.containsKey(itemId)) {
      throw Exception('Timeline item not found: $itemId');
    }
    _items.remove(itemId);
    _itemsController.add(Map.from(_items));
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

  void dispose() {
    _itemsController.close();
  }
}
