import 'package:flutter/material.dart';

/// Represents text formatting options
class TextFormatting {
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikethrough;
  final String? color;
  final String? backgroundColor;
  final String? fontFamily;
  final double? fontSize;
  
  const TextFormatting({
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.color,
    this.backgroundColor,
    this.fontFamily,
    this.fontSize,
  });
  
  /// Default formatting with no special styles
  static const TextFormatting defaultFormatting = TextFormatting();
  
  /// Bold formatting
  static const TextFormatting boldFormatting = TextFormatting(bold: true);
  
  /// Italic formatting
  static const TextFormatting italicFormatting = TextFormatting(italic: true);
  
  /// Underline formatting
  static const TextFormatting underlineFormatting = TextFormatting(underline: true);
  
  /// Strikethrough formatting
  static const TextFormatting strikethroughFormatting = TextFormatting(strikethrough: true);
  
  /// Create formatting from JSON
  factory TextFormatting.fromJson(Map<String, dynamic> json) {
    return TextFormatting(
      bold: json['bold'] as bool? ?? false,
      italic: json['italic'] as bool? ?? false,
      underline: json['underline'] as bool? ?? false,
      strikethrough: json['strikethrough'] as bool? ?? false,
      color: json['color'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      fontFamily: json['fontFamily'] as String?,
      fontSize: json['fontSize'] as double?,
    );
  }
  
  /// Convert formatting to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'bold': bold,
      'italic': italic,
      'underline': underline,
      'strikethrough': strikethrough,
      if (color != null) 'color': color,
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
      if (fontFamily != null) 'fontFamily': fontFamily,
      if (fontSize != null) 'fontSize': fontSize,
    };
  }
  
  /// Create a copy of this formatting with updated properties
  TextFormatting copyWith({
    bool? bold,
    bool? italic,
    bool? underline,
    bool? strikethrough,
    String? color,
    String? backgroundColor,
    String? fontFamily,
    double? fontSize,
  }) {
    return TextFormatting(
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      strikethrough: strikethrough ?? this.strikethrough,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
    );
  }
  
  /// Merge this formatting with another formatting
  TextFormatting merge(TextFormatting other) {
    return TextFormatting(
      bold: other.bold || bold,
      italic: other.italic || italic,
      underline: other.underline || underline,
      strikethrough: other.strikethrough || strikethrough,
      color: other.color ?? color,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      fontFamily: other.fontFamily ?? fontFamily,
      fontSize: other.fontSize ?? fontSize,
    );
  }
  
  /// Toggle a specific formatting attribute
  TextFormatting toggle(String attribute) {
    switch (attribute) {
      case 'bold':
        return copyWith(bold: !bold);
      case 'italic':
        return copyWith(italic: !italic);
      case 'underline':
        return copyWith(underline: !underline);
      case 'strikethrough':
        return copyWith(strikethrough: !strikethrough);
      default:
        return this;
    }
  }
  
  /// Convert to TextStyle for rendering
  TextStyle toTextStyle() {
    return TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      decoration: _getTextDecoration(),
      decorationColor: color != null ? Color(int.parse(color!)) : null,
      color: color != null ? Color(int.parse(color!)) : null,
      backgroundColor: backgroundColor != null ? Color(int.parse(backgroundColor!)) : null,
      fontFamily: fontFamily,
      fontSize: fontSize,
    );
  }
  
  /// Get the text decoration based on formatting
  TextDecoration _getTextDecoration() {
    if (underline && strikethrough) {
      return TextDecoration.combine([
        TextDecoration.underline,
        TextDecoration.lineThrough,
      ]);
    } else if (underline) {
      return TextDecoration.underline;
    } else if (strikethrough) {
      return TextDecoration.lineThrough;
    } else {
      return TextDecoration.none;
    }
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextFormatting &&
        other.bold == bold &&
        other.italic == italic &&
        other.underline == underline &&
        other.strikethrough == strikethrough &&
        other.color == color &&
        other.backgroundColor == backgroundColor &&
        other.fontFamily == fontFamily &&
        other.fontSize == fontSize;
  }
  
  @override
  int get hashCode =>
      bold.hashCode ^
      italic.hashCode ^
      underline.hashCode ^
      strikethrough.hashCode ^
      color.hashCode ^
      backgroundColor.hashCode ^
      fontFamily.hashCode ^
      fontSize.hashCode;
  
  @override
  String toString() {
    return 'TextFormatting(bold: $bold, italic: $italic, underline: $underline, strikethrough: $strikethrough)';
  }
}
