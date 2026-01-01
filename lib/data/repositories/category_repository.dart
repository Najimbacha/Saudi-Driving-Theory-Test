import '../models/category_model.dart';

class CategoryRepository {
  const CategoryRepository();

  List<CategoryModel> loadCategories() {
    return const [
      CategoryModel(
        id: 'signs',
        titleKey: 'categories.signs.title',
        subtitleKey: 'categories.signs.subtitle',
        iconName: 'traffic',
        colorHex: '#006C35',
        totalQuestions: 120,
      ),
      CategoryModel(
        id: 'rules',
        titleKey: 'categories.rules.title',
        subtitleKey: 'categories.rules.subtitle',
        iconName: 'rules',
        colorHex: '#2196F3',
        totalQuestions: 140,
      ),
      CategoryModel(
        id: 'safety',
        titleKey: 'categories.safety.title',
        subtitleKey: 'categories.safety.subtitle',
        iconName: 'safety',
        colorHex: '#4CAF50',
        totalQuestions: 90,
      ),
      CategoryModel(
        id: 'signals',
        titleKey: 'categories.signals.title',
        subtitleKey: 'categories.signals.subtitle',
        iconName: 'signals',
        colorHex: '#FDB913',
        totalQuestions: 80,
      ),
      CategoryModel(
        id: 'markings',
        titleKey: 'categories.markings.title',
        subtitleKey: 'categories.markings.subtitle',
        iconName: 'markings',
        colorHex: '#EF6C00',
        totalQuestions: 70,
      ),
    ];
  }
}
