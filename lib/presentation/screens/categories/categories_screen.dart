import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/question.dart';
import '../../../state/data_state.dart';
import '../../../state/learning_state.dart';
import '../../providers/category_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final TextEditingController _controller = TextEditingController();
  int _selectedFilter = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final questionsAsync = ref.watch(questionsProvider);
    final learning = ref.watch(learningProvider);
    final query = _controller.text.trim().toLowerCase();
    final questions = questionsAsync.valueOrNull ?? const <Question>[];
    final hasQuestionData = questionsAsync.hasValue;
    final questionCounts = <String, int>{};
    for (final question in questions) {
      questionCounts.update(
        question.categoryId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    final visible = categories.where((cat) {
      final title = cat.titleKey.tr().toLowerCase();
      if (query.isNotEmpty && !title.contains(query)) return false;
      if (!hasQuestionData) return true;
      return (questionCounts[cat.id] ?? 0) > 0;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('categories.title'.tr()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'categories.search'.tr(),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'categories.filterAll'.tr(),
                selected: _selectedFilter == 0,
                onTap: () => setState(() => _selectedFilter = 0),
              ),
              _FilterChip(
                label: 'categories.filterInProgress'.tr(),
                selected: _selectedFilter == 1,
                onTap: () => setState(() => _selectedFilter = 1),
              ),
              _FilterChip(
                label: 'categories.filterCompleted'.tr(),
                selected: _selectedFilter == 2,
                onTap: () => setState(() => _selectedFilter = 2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...visible.map((category) {
            final stat = learning.categoryStats[category.id];
            final accuracy = stat?.accuracy;
            final total = hasQuestionData
                ? (questionCounts[category.id] ?? 0)
                : category.totalQuestions;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CategoryCard(
                title: category.titleKey.tr(),
                subtitle: category.subtitleKey.tr(),
                gradient: _gradientFor(category.id),
                icon: _iconFor(category.iconName),
                total: total,
                accuracy: accuracy,
                onTap: () =>
                    context.push('/practice?category=${category.id}'),
              ),
            );
          }),
        ],
      ),
    );
  }

  static IconData _iconFor(String name) {
    switch (name) {
      case 'traffic':
        return Icons.traffic_outlined;
      case 'rules':
        return Icons.rule_outlined;
      case 'safety':
        return Icons.health_and_safety_outlined;
      case 'signals':
        return Icons.traffic_outlined;
      case 'markings':
        return Icons.linear_scale_outlined;
      case 'parking':
        return Icons.local_parking_outlined;
      case 'emergency':
        return Icons.warning_amber_outlined;
      case 'pedestrians':
        return Icons.directions_walk_outlined;
      case 'highway':
        return Icons.route_outlined;
      case 'weather':
        return Icons.cloud_outlined;
      case 'maintenance':
        return Icons.build_outlined;
      case 'responsibilities':
        return Icons.assignment_ind_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  static List<Color> _gradientFor(String id) {
    switch (id) {
      case 'signs':
        return const [AppColors.info, AppColors.accent];
      case 'rules':
        return const [AppColors.warning, AppColors.secondaryLight];
      case 'safety':
        return const [AppColors.error, Color(0xFFE57373)];
      case 'signals':
        return const [AppColors.primary, AppColors.primaryLight];
      case 'markings':
        return const [Color(0xFFEF6C00), Color(0xFFFFB74D)];
      default:
        return const [AppColors.primary, AppColors.primaryLight];
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.total,
    required this.accuracy,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;
  final int total;
  final int? accuracy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: Colors.white),
                    ),
                    const Spacer(),
                    if (accuracy != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$accuracy%',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Text(
                  'categories.totalQuestions'.tr(namedArgs: {
                    'value': total.toString(),
                  }),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    'quiz.start'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
