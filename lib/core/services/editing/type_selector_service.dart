import 'package:flutter/material.dart';
import 'package:gradus/domain/entities/item_type.dart';
import 'package:injectable/injectable.dart';
import '../../../presentation/widgets/timeline/item_type_selector_modal.dart';

/// Service responsible for managing the type selector overlay
@injectable
class TypeSelectorService {
  OverlayEntry? _overlayEntry;
  bool _isInteractingWithOverlay = false;

  bool get isInteractingWithOverlay => _isInteractingWithOverlay;

  /// Show the type selector overlay
  void showTypeSelector({
    required BuildContext context,
    required Function(ItemTypeOption) onTypeSelected,
    VoidCallback? onDismiss,
  }) {
    hideTypeSelector();
    _isInteractingWithOverlay = true;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: GestureDetector(
          onTap: () {
            _isInteractingWithOverlay = false;
            hideTypeSelector();
            onDismiss?.call();
          },
          child: Material(
            color: Colors.black.withValues(alpha: 0.3),
            child: GestureDetector(
              onTap: () {}, // Prevent tap from bubbling up
              child: ItemTypeSelectorModal(
                onTypeSelected: (option) {
                  _isInteractingWithOverlay = false;
                  hideTypeSelector();
                  onTypeSelected(option);
                },
                onDismiss: () {
                  _isInteractingWithOverlay = false;
                  hideTypeSelector();
                  onDismiss?.call();
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Hide the type selector overlay
  void hideTypeSelector() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isInteractingWithOverlay = false;
  }

  /// Transform ItemTypeOption to ItemType
  ItemType itemTypeOptionToItemType(ItemTypeOption option) {
    switch (option) {
      case ItemTypeOption.text:
        return ItemType.text;
      case ItemTypeOption.headline1:
        return ItemType.headline1;
      case ItemTypeOption.headline2:
        return ItemType.headline2;
      case ItemTypeOption.headline3:
        return ItemType.headline3;
      case ItemTypeOption.task:
        return ItemType.task;
    }
  }

  /// Check if overlay is currently visible
  bool get isVisible => _overlayEntry != null;

  /// Dispose of resources
  void dispose() {
    hideTypeSelector();
  }
}
