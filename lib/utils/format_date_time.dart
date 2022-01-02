String formatTime(DateTime dateTime) {
  return '${dateTime.hour % 12}.${dateTime.minute.toString().padLeft(2, "0")} ${dateTime.hour >= 12 ? "pm" : "am"}';
}

String formatDate(DateTime dateTime) {
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
