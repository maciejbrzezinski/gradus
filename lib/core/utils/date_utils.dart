extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime date) {
    return year == date.year && month == date.month && day == date.day;
  }

  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
