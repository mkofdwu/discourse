String formatTime(DateTime dateTime) {
  return '${dateTime.hour % 12}.${dateTime.minute.toString().padLeft(2, "0")} ${dateTime.hour >= 12 ? "pm" : "am"}';
}

String formatDate(DateTime dateTime) {
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool isToday(DateTime dateTime) {
  return isSameDay(dateTime, DateTime.now());
}

bool isYesterday(DateTime dateTime) {
  return isSameDay(dateTime, DateTime.now().subtract(Duration(days: 1)));
}

String formatTimeAgo(DateTime dateTime) {
  if (isToday(dateTime)) {
    return formatTime(dateTime);
  }
  if (isYesterday(dateTime)) {
    return 'yesterday';
  }
  return formatDate(dateTime);
}

String timeOfDay() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'morning';
  if (hour < 18) return 'afternoon';
  if (hour < 21) return 'evening';
  return 'night';
}

String timeTodayOrYesterday(DateTime dateTime) {
  String time = formatTime(dateTime);
  if (isToday(dateTime)) {
    return 'Today, $time';
  }
  if (isYesterday(dateTime)) {
    return 'Yesterday, $time';
  }
  throw 'Time must be today or yesterday: $dateTime';
}
