const List<String> _months = [
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

// convert int to a String
String _two(int n) => n.toString().padLeft(2, '0');

// Date format like Feb 5
String formatShortDate(DateTime date) =>
    '${_months[date.month - 1]} ${date.day}';

// Date format like Feb 5, 2023
String formatLongDate(DateTime date) =>
    '${_months[date.month - 1]} ${date.day}, ${date.year}';

// 14:30
String formatTime(DateTime date) => '${_two(date.hour)}:${_two(date.minute)}';

// Name for a brand new scan
String formatNewScanName(DateTime date) =>
    'Scan ${formatShortDate(date)} at ${formatTime(date)}';

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}

String pagesLabel(int pages) => pages == 1 ? '1 page' : '$pages pages';

String scansLabel(int scans) => scans == 1 ? '1 scan' : '$scans scans';
