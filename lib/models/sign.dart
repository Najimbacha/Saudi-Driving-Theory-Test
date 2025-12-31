class AppSign {
  const AppSign({
    required this.id,
    required this.category,
    required this.svgPath,
    required this.titles,
  });

  final String id;
  final String category;
  final String svgPath;
  final Map<String, String> titles;

  factory AppSign.fromJson(Map<String, dynamic> json) {
    return AppSign(
      id: json['id'] as String,
      category: json['category'] as String? ?? 'warning',
      svgPath: (json['svg'] as String).replaceFirst('/', ''),
      titles: {
        'en': json['name_en'] as String? ?? '',
        'ar': json['name_ar'] as String? ?? '',
        'ur': json['name_ur'] as String? ?? '',
        'hi': json['name_hi'] as String? ?? '',
        'bn': json['name_bn'] as String? ?? '',
      },
    );
  }
}
