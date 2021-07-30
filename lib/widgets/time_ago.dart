import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class TimeAgo {
  static String timeAgoSinceDate(String date) {
    initializeDateFormatting('en_GB');
    final DateTime now = DateTime.now().toUtc();
    final DateTime when = DateTime.parse(date);
    final Duration difference = now.difference(when);
    if (when.year != now.year) {
      return DateFormat.yMMMd('en_GB').format(when);
    }
    if (difference.inDays >= 7) {
      return DateFormat.MMMd('en_GB').format(when);
    }
    if (difference.inHours >= 24) {
      return DateFormat(DateFormat.ABBR_WEEKDAY).format(when);
    }
    if (difference.inMinutes >= 60) {
      return '${difference.inHours}h';
    }
    if (difference.inSeconds >= 60) {
      return '${difference.inMinutes}m';
    }
    return 'now';
  }
}
