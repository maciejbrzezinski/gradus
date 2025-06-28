import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/day.dart';

@injectable
class FocusCubit extends Cubit<String?> {
  FocusCubit() : super(null);
  
  /// Set focus to a specific item by its ID
  void setFocus(String itemId) {
    emit(itemId);
  }
  
  /// Clear focus from all items
  void clearFocus() {
    emit(null);
  }
  
  /// Check if a specific item has focus
  bool isFocused(String itemId) {
    return state == itemId;
  }
  
  /// Get the currently focused item ID
  String? get focusedItemId => state;
  
  /// Navigate to the previous item in the timeline
  void focusPreviousItem(String currentItemId, List<Day> days) {
    final previousItemId = findPreviousItemId(currentItemId, days);
    if (previousItemId != null) {
      setFocus(previousItemId);
    }
  }
  
  /// Navigate to the next item in the timeline
  void focusNextItem(String currentItemId, List<Day> days) {
    final nextItemId = findNextItemId(currentItemId, days);
    if (nextItemId != null) {
      setFocus(nextItemId);
    }
  }
  
  /// Find the previous item ID in chronological order across all days
  String? findPreviousItemId(String currentItemId, List<Day> days) {
    // Sort days by date
    final sortedDays = List<Day>.from(days)..sort((a, b) => a.date.compareTo(b.date));
    
    String? previousItemId;
    
    for (final day in sortedDays) {
      for (final itemId in day.itemIds) {
        if (itemId == currentItemId) {
          return previousItemId; // Return the item we found just before current
        }
        previousItemId = itemId; // Keep track of the previous item
      }
    }
    
    return null; // Current item not found or it's the first item
  }
  
  /// Find the next item ID in chronological order across all days
  String? findNextItemId(String currentItemId, List<Day> days) {
    // Sort days by date
    final sortedDays = List<Day>.from(days)..sort((a, b) => a.date.compareTo(b.date));
    
    bool foundCurrent = false;
    
    for (final day in sortedDays) {
      for (final itemId in day.itemIds) {
        if (foundCurrent) {
          return itemId; // Return the first item after current
        }
        if (itemId == currentItemId) {
          foundCurrent = true;
        }
      }
    }
    
    return null; // Current item not found or it's the last item
  }
}
