import 'package:intl/intl.dart';
import 'package:mechanix_messages/l10n/app_localizations.dart';

String getInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}

String formatTime(DateTime dt, AppLocalizations l10n) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final msgDay = DateTime(dt.year, dt.month, dt.day);

  if (msgDay == today) {
    return DateFormat('h:mm a').format(dt);
  } else if (today.difference(msgDay).inDays == 1) {
    return l10n.yesterday;
  } else {
    return DateFormat('d MMM').format(dt);
  }
}

bool isSameDay(DateTime date1, DateTime date2) {
  final d1 = DateTime(date1.year, date1.month, date1.day);
  final d2 = DateTime(date2.year, date2.month, date2.day);
  return d1.difference(d2).inDays == 0;
}

String formatDateHeader(DateTime dt, AppLocalizations l10n) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final msgDay = DateTime(dt.year, dt.month, dt.day);
  final timeStr = DateFormat('h:mm a').format(dt);

  if (msgDay == today) {
    return l10n.todayAt(timeStr);
  } else if (today.difference(msgDay).inDays == 1) {
    return l10n.yesterdayAt(timeStr);
  } else {
    final dateStr = DateFormat('d MMM yyyy').format(dt);
    return l10n.dateAtTime(dateStr, timeStr);
  }
}
