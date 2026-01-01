class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.iconName,
    required this.colorHex,
    required this.totalQuestions,
  });

  final String id;
  final String titleKey;
  final String subtitleKey;
  final String iconName;
  final String colorHex;
  final int totalQuestions;
}
