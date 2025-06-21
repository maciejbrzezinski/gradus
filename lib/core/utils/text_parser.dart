enum ItemCreationType {
  note,
  task,
  showTypeSelector,
}

class TextParser {
  static ItemCreationType parseInput(String text) {
    final trimmedText = text.trim();
    
    if (trimmedText.startsWith('[]')) {
      return ItemCreationType.task;
    }
    
    if (trimmedText.startsWith('/')) {
      return ItemCreationType.showTypeSelector;
    }
    
    return ItemCreationType.note;
  }
  
  static String cleanTaskText(String text) {
    final trimmedText = text.trim();
    if (trimmedText.startsWith('[]')) {
      return trimmedText.substring(2).trim();
    }
    return trimmedText;
  }
  
  static String cleanNoteText(String text) {
    return text.trim();
  }
}
