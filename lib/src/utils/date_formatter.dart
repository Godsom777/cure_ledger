import 'package:intl/intl.dart';

/// Date formatting utilities
class DateFormatter {
  DateFormatter._();

  static final _fullDateFormat = DateFormat('MMMM d, yyyy');
  static final _shortDateFormat = DateFormat('MMM d, yyyy');
  static final _numericDateFormat = DateFormat('dd/MM/yyyy');
  static final _timeFormat = DateFormat('h:mm a');
  static final _dateTimeFormat = DateFormat('MMM d, yyyy • h:mm a');
  static final _isoFormat = DateFormat('yyyy-MM-dd');

  /// Format as full date (e.g., December 31, 2025)
  static String formatFull(DateTime date) {
    return _fullDateFormat.format(date);
  }

  /// Format as short date (e.g., Dec 31, 2025)
  static String formatShort(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// Format as numeric date (e.g., 31/12/2025)
  static String formatNumeric(DateTime date) {
    return _numericDateFormat.format(date);
  }

  /// Format as time (e.g., 2:30 PM)
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format as date and time (e.g., Dec 31, 2025 • 2:30 PM)
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Format as ISO date (e.g., 2025-12-31)
  static String formatIso(DateTime date) {
    return _isoFormat.format(date);
  }

  /// Format relative time (e.g., "2 hours ago", "Yesterday")
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return formatShort(date);
    }
  }
}
