import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/recurrence_rule.dart';

class RecurrenceSettingsModal extends StatefulWidget {
  final RecurrenceRule? initialRecurrence;
  final Function(RecurrenceRule?) onRecurrenceChanged;
  final VoidCallback? onDismiss;

  const RecurrenceSettingsModal({
    super.key,
    this.initialRecurrence,
    required this.onRecurrenceChanged,
    this.onDismiss,
  });

  @override
  State<RecurrenceSettingsModal> createState() => _RecurrenceSettingsModalState();
}

class _RecurrenceSettingsModalState extends State<RecurrenceSettingsModal> {
  late TextEditingController _intervalController;
  late FocusNode _intervalFocusNode;
  late FocusNode _dropdownFocusNode;
  late FocusNode _okButtonFocusNode;
  
  RecurrenceType _selectedType = RecurrenceType.daily;
  int _interval = 1;
  bool _hasRecurrence = false;

  static const List<RecurrenceType> _recurrenceTypes = [
    RecurrenceType.daily,
    RecurrenceType.weekly,
    RecurrenceType.monthly,
    RecurrenceType.yearly,
  ];

  static const Map<RecurrenceType, (String, String)> _typeLabels = {
    RecurrenceType.daily: ('day', 'days'),
    RecurrenceType.weekly: ('week', 'weeks'),
    RecurrenceType.monthly: ('month', 'months'),
    RecurrenceType.yearly: ('year', 'years'),
  };

  @override
  void initState() {
    super.initState();
    _initializeFromExisting();
    _intervalController = TextEditingController(text: _interval.toString());
    _intervalFocusNode = FocusNode();
    _dropdownFocusNode = FocusNode();
    _okButtonFocusNode = FocusNode();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Always focus on interval since we default to having recurrence
      _intervalFocusNode.requestFocus();
    });
  }

  void _initializeFromExisting() {
    if (widget.initialRecurrence != null) {
      _selectedType = widget.initialRecurrence!.type;
      _interval = widget.initialRecurrence!.interval;
      _hasRecurrence = true;
    } else {
      // Default to "Every 1 day" instead of "None"
      _selectedType = RecurrenceType.daily;
      _interval = 1;
      _hasRecurrence = true;
    }
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _intervalFocusNode.dispose();
    _dropdownFocusNode.dispose();
    _okButtonFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.enter:
          _confirmSelection();
          break;
        case LogicalKeyboardKey.escape:
          widget.onDismiss?.call();
          break;
        case LogicalKeyboardKey.tab:
          if (HardwareKeyboard.instance.isShiftPressed) {
            _focusPrevious();
          } else {
            _focusNext();
          }
          break;
      }
    }
  }

  void _focusNext() {
    if (_intervalFocusNode.hasFocus) {
      _dropdownFocusNode.requestFocus();
    } else if (_dropdownFocusNode.hasFocus) {
      _okButtonFocusNode.requestFocus();
    } else {
      _intervalFocusNode.requestFocus();
    }
  }

  void _focusPrevious() {
    if (_okButtonFocusNode.hasFocus) {
      _dropdownFocusNode.requestFocus();
    } else if (_dropdownFocusNode.hasFocus) {
      _intervalFocusNode.requestFocus();
    } else {
      _okButtonFocusNode.requestFocus();
    }
  }

  void _confirmSelection() {
    if (_hasRecurrence) {
      final rule = RecurrenceRule(
        type: _selectedType,
        interval: _interval,
      );
      widget.onRecurrenceChanged(rule);
    } else {
      widget.onRecurrenceChanged(null);
    }
  }

  void _toggleRecurrence() {
    setState(() {
      _hasRecurrence = !_hasRecurrence;
    });
  }

  String _getTypeDisplayName(RecurrenceType type) {
    final labels = _typeLabels[type]!;
    return _interval == 1 ? labels.$1 : labels.$2;
  }

  void _updateInterval(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed > 0 && parsed <= 99) {
      setState(() {
        _interval = parsed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyEvent,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing12,
          vertical: AppTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardBackgroundDark : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.subtleShadow,
          border: Border.all(
            color: isDark 
              ? Colors.grey.shade700 
              : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // None/Every toggle
            InkWell(
              onTap: _toggleRecurrence,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing8,
                  vertical: AppTheme.spacing4,
                ),
                decoration: BoxDecoration(
                  color: _hasRecurrence 
                    ? AppTheme.primaryColor.withValues(alpha: 0.15)
                    : (isDark 
                        ? Colors.grey.shade700.withValues(alpha: 0.3)
                        : AppTheme.textSecondary.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: _hasRecurrence 
                    ? Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        width: 1,
                      )
                    : null,
                ),
                child: Text(
                  _hasRecurrence ? 'Every' : 'None',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _hasRecurrence 
                      ? AppTheme.primaryColor
                      : (isDark ? Colors.grey.shade300 : AppTheme.textSecondary),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            if (_hasRecurrence) ...[
              const SizedBox(width: AppTheme.spacing8),
              
              // Interval input
              SizedBox(
                width: 40,
                height: 32,
                child: TextFormField(
                  controller: _intervalController,
                  focusNode: _intervalFocusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                    fillColor: isDark 
                      ? Colors.grey.shade800 
                      : Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      borderSide: BorderSide(
                        color: isDark 
                          ? Colors.grey.shade600 
                          : AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      borderSide: BorderSide(
                        color: isDark 
                          ? Colors.grey.shade600 
                          : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      borderSide: BorderSide(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: _updateInterval,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                ),
              ),
              
              const SizedBox(width: AppTheme.spacing8),
              
              // Type dropdown
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: isDark ? AppTheme.cardBackgroundDark : AppTheme.cardBackground,
                ),
                child: DropdownButton<RecurrenceType>(
                  value: _selectedType,
                  focusNode: _dropdownFocusNode,
                  underline: const SizedBox(),
                  dropdownColor: isDark ? AppTheme.cardBackgroundDark : AppTheme.cardBackground,
                  iconEnabledColor: isDark ? Colors.grey.shade400 : AppTheme.textSecondary,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  items: _recurrenceTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        _getTypeDisplayName(type),
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (RecurrenceType? newType) {
                    if (newType != null) {
                      setState(() {
                        _selectedType = newType;
                      });
                    }
                  },
                ),
              ),
            ],
            
            const SizedBox(width: AppTheme.spacing8),
            
            // OK button
            InkWell(
              onTap: _confirmSelection,
              focusNode: _okButtonFocusNode,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing8,
                  vertical: AppTheme.spacing4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'OK',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
