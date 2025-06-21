import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/note_type.dart';

enum ItemTypeOption {
  text,
  headline1,
  headline2,
  headline3,
  task,
}

class ItemTypeSelectorModal extends StatelessWidget {
  final Function(ItemTypeOption) onTypeSelected;

  const ItemTypeSelectorModal({
    super.key,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
          const SizedBox(height: AppTheme.spacing12),
          _buildTypeOption(
            context,
            icon: Icons.text_fields,
            title: 'Text',
            description: 'Just start writing with plain text',
            onTap: () => onTypeSelected(ItemTypeOption.text),
          ),
          _buildTypeOption(
            context,
            icon: Icons.title,
            title: 'Heading 1',
            description: 'Big section heading',
            onTap: () => onTypeSelected(ItemTypeOption.headline1),
          ),
          _buildTypeOption(
            context,
            icon: Icons.title,
            title: 'Heading 2',
            description: 'Medium section heading',
            onTap: () => onTypeSelected(ItemTypeOption.headline2),
          ),
          _buildTypeOption(
            context,
            icon: Icons.title,
            title: 'Heading 3',
            description: 'Small section heading',
            onTap: () => onTypeSelected(ItemTypeOption.headline3),
          ),
          _buildTypeOption(
            context,
            icon: Icons.check_box_outlined,
            title: 'Task',
            description: 'Track something with a checkbox',
            onTap: () => onTypeSelected(ItemTypeOption.task),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
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
              icon,
              size: 20,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static NoteType itemTypeOptionToNoteType(ItemTypeOption option) {
    switch (option) {
      case ItemTypeOption.text:
        return NoteType.text;
      case ItemTypeOption.headline1:
        return NoteType.headline1;
      case ItemTypeOption.headline2:
        return NoteType.headline2;
      case ItemTypeOption.headline3:
        return NoteType.headline3;
      case ItemTypeOption.task:
        throw ArgumentError('Task option should not be converted to NoteType');
    }
  }
}
