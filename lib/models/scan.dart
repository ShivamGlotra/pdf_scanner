enum ScanFormat { pdf, image }

extension ScanFormatInfo on ScanFormat {
  String get label => switch (this) {
    ScanFormat.pdf => "PDF",
    ScanFormat.image => "Images",
  };

  String get fileExtension => switch (this) {
    ScanFormat.pdf => "pdf",
    ScanFormat.image => "jpg",
  };

  String get mimeType => switch (this) {
    ScanFormat.pdf => "application/pdf",
    ScanFormat.image => "image/jpeg",
  };
}

class Scan {
  const Scan({
    required this.id,
    required this.title,
    required this.format,
    required this.files,
    required this.pageCount,
    required this.createdAt,
    required this.sizeBytes,
  });

  final String id;
  final String title;
  final ScanFormat format;

  final List<String> files;
  final int pageCount;
  final DateTime createdAt;
  final int sizeBytes;

  // final String imagePath;

  Scan copyWith({String? title}) {
    return Scan(
      id: id,
      title: title ?? this.title,
      format: format,
      files: files,
      pageCount: pageCount,
      createdAt: createdAt,
      sizeBytes: sizeBytes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'format': format.name,
      'files': files,
      'pageCount': pageCount,
      'createdAt': createdAt.toIso8601String(),
      'sizeBytes': sizeBytes,
    };
  }

  factory Scan.fromJson(Map<String, dynamic> json) {
    return Scan(
      id: json['id'] as String,
      title: json['title'] as String,
      format: ScanFormat.values.byName(json['format'] as String),
      files: (json['files'] as List<dynamic>).cast<String>(),
      pageCount: json['pageCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sizeBytes: json['sizeBytes'] as int,
    );
  }

  // String get subtitle {
  //   const months = [
  //     'Jan',
  //     'Feb',
  //     'Mar',
  //     'Apr',
  //     'May',
  //     'Jun',
  //     'Jul',
  //     'Aug',
  //     'Sep',
  //     'Oct',
  //     'Nov',
  //     'Dec',
  //   ];
  //   final kind = isPdf ? 'PDF' : 'Images';
  //   final pageLabel = pages == 1 ? '1 page' : '$pages pages';
  //   return '$kind · $pageLabel · ${months[createdAt.month - 1]} ${createdAt.day}';
  // }
}
