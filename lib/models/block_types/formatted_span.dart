import 'package:flutter/foundation.dart';
import '../text_formatting.dart';

/// Represents a span of text with specific formatting
class FormattedSpan {
  /// Starting index in the text (inclusive)
  final int start;
  
  /// Ending index in the text (exclusive)
  final int end;
  
  /// Formatting to apply to this span
  final TextFormatting formatting;
  
  FormattedSpan({
    required this.start,
    required this.end,
    required this.formatting,
  }) : assert(start >= 0 && end >= start, 'Invalid span range');
  
  /// Create a span from JSON
  factory FormattedSpan.fromJson(Map<String, dynamic> json) {
    return FormattedSpan(
      start: json['start'] as int,
      end: json['end'] as int,
      formatting: TextFormatting.fromJson(json['formatting'] as Map<String, dynamic>),
    );
  }
  
  /// Convert span to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'formatting': formatting.toJson(),
    };
  }
  
  /// Create a copy of this span with updated properties
  FormattedSpan copyWith({
    int? start,
    int? end,
    TextFormatting? formatting,
  }) {
    return FormattedSpan(
      start: start ?? this.start,
      end: end ?? this.end,
      formatting: formatting ?? this.formatting,
    );
  }
  
  /// Check if this span overlaps with another span
  bool overlaps(FormattedSpan other) {
    return (start < other.end && end > other.start);
  }
  
  /// Check if this span contains a position
  bool containsPosition(int position) {
    return position >= start && position < end;
  }
  
  /// Check if this span contains a range
  bool containsRange(int rangeStart, int rangeEnd) {
    return start <= rangeStart && end >= rangeEnd;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FormattedSpan &&
        other.start == start &&
        other.end == end &&
        other.formatting == formatting;
  }
  
  @override
  int get hashCode => start.hashCode ^ end.hashCode ^ formatting.hashCode;
  
  @override
  String toString() => 'FormattedSpan(start: $start, end: $end, formatting: $formatting)';
}
