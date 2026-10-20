class Scan {
  const Scan({
    required this.title,
    required this.isPdf,
    required this.pages,
    required this.date,
    required this.bytes,
    required this.imagePath,
  });

  final String title;
  final bool isPdf;
  final int pages;
  final DateTime date;
  final int bytes;
  final String imagePath;
  String get subtitle {
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
    final kind = isPdf ? 'PDF' : 'Images';
    final pageLabel = pages == 1 ? '1 page' : '$pages pages';
    return '$kind · $pageLabel · ${months[date.month - 1]} ${date.day}';
  }
}

final sampleScans = <Scan>[
  Scan(
    title: 'Electric bill, October',
    isPdf: true,
    pages: 3,
    date: DateTime(2026, 10, 8),
    bytes: 420000,
    imagePath: 'assets/images/electric_bill.png',
  ),
  Scan(
    title: 'Receipt, hardware store',
    isPdf: false,
    pages: 1,
    date: DateTime(2026, 10, 6),
    bytes: 1800000,
    imagePath: 'assets/images/Receipt.png',
  ),
  Scan(
    title: 'Lease agreement',
    isPdf: true,
    pages: 5,
    date: DateTime(2026, 9, 29),
    bytes: 2300000,
    imagePath: 'assets/images/Lease.png',
  ),
  Scan(
    title: 'Passport photo page',
    isPdf: false,
    pages: 1,
    date: DateTime(2026, 9, 21),
    bytes: 3100000,
    imagePath: 'assets/images/Passport.png',
  ),
  Scan(
    title: 'Class notes, week 3',
    isPdf: true,
    pages: 4,
    date: DateTime(2026, 9, 18),
    bytes: 1500000,
    imagePath: 'assets/images/Class.png',
  ),
  Scan(
    title: 'Insurance card',
    isPdf: false,
    pages: 2,
    date: DateTime(2026, 9, 2),
    bytes: 2700000,
    imagePath: 'assets/images/Insurance.png',
  ),
  Scan(
    title: 'Warranty, dishwasher',
    isPdf: true,
    pages: 2,
    date: DateTime(2026, 8, 27),
    bytes: 640000,
    imagePath: 'assets/images/Warranty.png',
  ),
];
