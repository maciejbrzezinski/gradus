import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';

enum ItemTypeOption {
  text,
  headline1,
  headline2,
  headline3,
  task,
}

class _OptionData {
  final IconData icon;
  final String title;
  final String description;
  final String shortcut;

  const _OptionData({
    required this.icon,
    required this.title,
    required this.description,
    required this.shortcut,
  });
}

class ItemTypeSelectorModal extends StatefulWidget {
  final Function(ItemTypeOption) onTypeSelected;
  final VoidCallback? onDismiss;

  const ItemTypeSelectorModal({
    super.key,
    required this.onTypeSelected,
    this.onDismiss,
  });

  @override
  State<ItemTypeSelectorModal> createState() => _ItemTypeSelectorModalState();
}

class _ItemTypeSelectorModalState extends State<ItemTypeSelectorModal> {
  int _selectedIndex = 0;
  final FocusNode _focusNode = FocusNode();
  
  static const List<ItemTypeOption> _options = [
    ItemTypeOption.text,
    ItemTypeOption.headline1,
    ItemTypeOption.headline2,
    ItemTypeOption.headline3,
    ItemTypeOption.task,
  ];

  static const List<_OptionData> _optionData = [
    _OptionData(
      icon: Icons.text_fields,
      title: 'Text',
      description: 'Just start writing with plain text',
      shortcut: '1',
    ),
    _OptionData(
      icon: Icons.title,
      title: 'Heading 1',
      description: 'Big section heading',
      shortcut: '2',
    ),
    _OptionData(
      icon: Icons.title,
      title: 'Heading 2',
      description: 'Medium section heading',
      shortcut: '3',
    ),
    _OptionData(
      icon: Icons.title,
      title: 'Heading 3',
      description: 'Small section heading',
      shortcut: '4',
    ),
    _OptionData(
      icon: Icons.check_box_outlined,
      title: 'Task',
      description: 'Track something with a checkbox',
      shortcut: '5',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          setState(() {
            _selectedIndex = (_selectedIndex - 1) % _options.length;
            if (_selectedIndex < 0) _selectedIndex = _options.length - 1;
          });
          break;
        case LogicalKeyboardKey.arrowDown:
          setState(() {
            _selectedIndex = (_selectedIndex + 1) % _options.length;
          });
          break;
        case LogicalKeyboardKey.enter:
          _selectOption(_selectedIndex);
          break;
        case LogicalKeyboardKey.escape:
          widget.onDismiss?.call();
          break;
        case LogicalKeyboardKey.digit1:
          _selectOption(0);
          break;
        case LogicalKeyboardKey.digit2:
          _selectOption(1);
          break;
        case LogicalKeyboardKey.digit3:
          _selectOption(2);
          break;
        case LogicalKeyboardKey.digit4:
          _selectOption(3);
          break;
        case LogicalKeyboardKey.digit5:
          _selectOption(4);
          break;
      }
    }
  }

  void _selectOption(int index) {
    if (index >= 0 && index < _options.length) {
      widget.onTypeSelected(_options[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 320,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: _handleKeyEvent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: AppTheme.mediumShadow,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Choose block type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    'Use ↑↓ arrows or number keys',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  ...List.generate(_options.length, (index) {
                    return _buildTypeOption(
                      context,
                      index: index,
                      data: _optionData[index],
                      isSelected: index == _selectedIndex,
                      onTap: () => _selectOption(index),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(
    BuildContext context, {
    required int index,
    required _OptionData data,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: AppTheme.fastAnimation,
      curve: AppTheme.fastCurve,
      margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
      decoration: BoxDecoration(
        color: isSelected 
          ? AppTheme.primaryColor.withValues(alpha: 0.1)
          : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: isSelected
          ? Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              width: 1,
            )
          : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacing8,
            horizontal: AppTheme.spacing12,
          ),
          child: Row(
            children: [
              Icon(
                data.icon,
                size: 20,
                color: isSelected 
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondary,
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isSelected 
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      data.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                    ? AppTheme.primaryColor.withValues(alpha: 0.2)
                    : AppTheme.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data.shortcut,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
