// Small shared formatting helpers used across member & admin screens.

/// Formats a number as "Rs. 1,500" (comma thousands separator, no decimals).
String formatCurrency(num value) {
  final rounded = value.round();
  final isNegative = rounded < 0;
  final digits = rounded.abs().toString();

  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    final posFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) {
      buffer.write(',');
    }
  }

  return 'Rs. ${isNegative ? '-' : ''}${buffer.toString()}';
}

/// Formats a DateTime as "9:15 AM" (no leading zero on the hour).
String formatTime12h(DateTime dt) {
  int hour = dt.hour % 12;
  if (hour == 0) hour = 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

/// Formats a DateTime as a day header: "Today", "Yesterday", or "Jul 30, 2026".
String formatDateHeader(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(dt.year, dt.month, dt.day);

  if (day == today) return 'Today';
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

/// Parses a SQL/ISO timestamp string coming from the backend safely.
DateTime? parseServerTimestamp(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

String stripPakPhonePrefix(String raw) {
  String digits = raw.trim();
  if (digits.startsWith('+92')) {
    digits = digits.substring(3);
  } else if (digits.startsWith('92') && digits.length > 10) {
    digits = digits.substring(2);
  } else if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  return digits;
}

String normalizePakPhone(String localDigits) {
  return '+92${localDigits.trim()}';
}
