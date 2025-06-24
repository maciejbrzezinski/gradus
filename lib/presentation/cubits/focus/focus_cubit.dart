import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

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
}
