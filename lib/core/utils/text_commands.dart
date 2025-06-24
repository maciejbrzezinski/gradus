import '../../../domain/entities/note_type.dart';

enum ItemType {
  textNote,
  headline1,
  headline2,
  headline3,
  task,
  bulletPoint,
  // Future types can be added here:
  // numberedList,
  // codeBlock,
  // image,
}

extension ItemTypeExtensions on ItemType {
  bool get isHeadline => this == ItemType.headline1 || 
                        this == ItemType.headline2 || 
                        this == ItemType.headline3;
  
  NoteType toNoteType() {
    switch (this) {
      case ItemType.textNote:
        return NoteType.text;
      case ItemType.headline1:
        return NoteType.headline1;
      case ItemType.headline2:
        return NoteType.headline2;
      case ItemType.headline3:
        return NoteType.headline3;
      default:
        throw ArgumentError('ItemType $this cannot be converted to NoteType');
    }
  }
}

class TextCommand {
  final String trigger;
  final ItemType targetType;
  final String description;
  final bool requiresSpace;
  
  const TextCommand({
    required this.trigger,
    required this.targetType,
    required this.description,
    this.requiresSpace = true,
  });
}

class TextCommandRegistry {
  static const List<TextCommand> commands = [
    TextCommand(
      trigger: "[]",
      targetType: ItemType.task,
      description: "Create a task",
    ),
    TextCommand(
      trigger: "-",
      targetType: ItemType.bulletPoint,
      description: "Create a bullet point",
    ),
    TextCommand(
      trigger: "#",
      targetType: ItemType.headline1,
      description: "Create heading 1",
    ),
    TextCommand(
      trigger: "##",
      targetType: ItemType.headline2,
      description: "Create heading 2",
    ),
    TextCommand(
      trigger: "###",
      targetType: ItemType.headline3,
      description: "Create heading 3",
    ),
  ];
  
  static TextCommand? findCommand(String text) {
    // Sort by trigger length descending to match longer triggers first (e.g., "###" before "#")
    final sortedCommands = List<TextCommand>.from(commands)
      ..sort((a, b) => b.trigger.length.compareTo(a.trigger.length));
    
    for (final command in sortedCommands) {
      if (text.startsWith(command.trigger)) {
        return command;
      }
    }
    return null;
  }
  
  static List<TextCommand> getAllCommands() => commands;
}

class CommandMatch {
  final TextCommand command;
  final String matchedText;
  final String remainingText;
  
  CommandMatch({
    required this.command,
    required this.matchedText,
    required this.remainingText,
  });
}

class CommandDetector {
  static CommandMatch? detectCommand(String text, int cursorPosition) {
    // Check if cursor is after a space following a command
    if (cursorPosition > 0 && cursorPosition <= text.length && text[cursorPosition - 1] == ' ') {
      final beforeSpace = text.substring(0, cursorPosition - 1);
      final command = TextCommandRegistry.findCommand(beforeSpace);
      
      if (command != null && beforeSpace == command.trigger) {
        return CommandMatch(
          command: command,
          matchedText: beforeSpace,
          remainingText: text.substring(cursorPosition),
        );
      }
    }
    return null;
  }
  
  static bool isSlashCommand(String text) {
    return text.trim() == '/';
  }
}
