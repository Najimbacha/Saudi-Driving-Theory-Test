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
      CategoryModel(
        id: 'parking',
        titleKey: 'categories.parking.title',
        subtitleKey: 'categories.parking.subtitle',
        iconName: 'parking',
        colorHex: '#FF7043',
        totalQuestions: 60,
      ),
      CategoryModel(
        id: 'emergency',
        titleKey: 'categories.emergency.title',
        subtitleKey: 'categories.emergency.subtitle',
        iconName: 'emergency',
        colorHex: '#D32F2F',
        totalQuestions: 50,
      ),
      CategoryModel(
        id: 'pedestrians',
        titleKey: 'categories.pedestrians.title',
        subtitleKey: 'categories.pedestrians.subtitle',
        iconName: 'pedestrians',
        colorHex: '#26A69A',
        totalQuestions: 55,
      ),
      CategoryModel(
        id: 'highway',
        titleKey: 'categories.highway.title',
        subtitleKey: 'categories.highway.subtitle',
        iconName: 'highway',
        colorHex: '#546E7A',
        totalQuestions: 65,
      ),
      CategoryModel(
        id: 'weather',
        titleKey: 'categories.weather.title',
        subtitleKey: 'categories.weather.subtitle',
        iconName: 'weather',
        colorHex: '#5C6BC0',
        totalQuestions: 40,
      ),
      CategoryModel(
        id: 'maintenance',
        titleKey: 'categories.maintenance.title',
        subtitleKey: 'categories.maintenance.subtitle',
        iconName: 'maintenance',
        colorHex: '#7CB342',
        totalQuestions: 45,
      ),
      CategoryModel(
        id: 'responsibilities',
        titleKey: 'categories.responsibilities.title',
        subtitleKey: 'categories.responsibilities.subtitle',
        iconName: 'responsibilities',
        colorHex: '#00897B',
        totalQuestions: 55,
      ),
    ];
  }
}
