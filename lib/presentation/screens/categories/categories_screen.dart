import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/modern_theme.dart';
import '../../../state/learning_state.dart';
import '../../../utils/app_feedback.dart';
import '../../../utils/app_fonts.dart';
import '../../../widgets/stagger_in.dart';
import '../../providers/category_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final learning = ref.watch(learningProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final questionCounts = ref.watch(categoryQuestionCountsProvider);
    final hasQuestionData = questionCounts.isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'categories.title'.tr(),
          style: AppFonts.outfit(context,
              fontWeight: FontWeight.w800, fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(PhosphorIconsRegular.caretLeft, color: scheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const StaggerIn(
                order: 0,
                child: _HeaderCard(),
              ),
              const SizedBox(height: 20),

              // Category cards
              ...categories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                final stat = learning.categoryStats[category.id];
                final accuracy = stat?.accuracy;
                final total = hasQuestionData
                    ? (questionCounts[category.id] ?? 0)
                    : category.totalQuestions;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: StaggerIn(
                    order: index + 1,
                    child: _CategoryCard(
                      title: category.titleKey.tr(),
                      subtitle: category.subtitleKey.tr(),
                      gradient: _gradientFor(category.id),
                      icon: _iconFor(category.iconName),
                      total: total,
                      accuracy: accuracy,
                      onTap: () {
                        AppFeedback.tap(context);
                        context.push('/practice?category=${category.id}');
                      },
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),

              // Traffic violations highlight card
              StaggerIn(
                order: categories.length + 1,
                child: _ViolationCard(
                  title: 'home.violationPoints'.tr(),
                  subtitle: 'home.violationPointsDesc'.tr(),
                  onTap: () {
                    AppFeedback.tap(context);
                    context.push('/violation-points');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(String name) {
    switch (name) {
      case 'traffic':
        return PhosphorIconsFill.trafficSign;
      case 'rules':
        return PhosphorIconsFill.gavel;
      case 'safety':
        return PhosphorIconsFill.shieldCheck;
      case 'signals':
        return PhosphorIconsFill.trafficSignal;
      case 'markings':
        return PhosphorIconsFill.roadHorizon;
      case 'parking':
        return PhosphorIconsFill.carSimple;
      case 'emergency':
        return PhosphorIconsFill.warning;
      case 'pedestrians':
        return PhosphorIconsFill.personSimpleWalk;
      case 'highway':
        return PhosphorIconsFill.roadHorizon;
      case 'weather':
        return PhosphorIconsFill.sunDim;
      case 'maintenance':
        return PhosphorIconsFill.wrench;
      case 'responsibilities':
        return PhosphorIconsFill.identificationBadge;
      default:
        return PhosphorIconsFill.gridFour;
    }
  }

  static LinearGradient _gradientFor(String id) {
    switch (id) {
      case 'signs':
        return const LinearGradient(
            colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)]);
      case 'rules':
        return const LinearGradient(
            colors: [Color(0xFFEAB308), Color(0xFFFACC15)]);
      case 'safety':
        return const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFF87171)]);
      case 'signals':
        return const LinearGradient(
            colors: [Color(0xFF22C55E), Color(0xFF4ADE80)]);
      case 'markings':
        return const LinearGradient(
            colors: [Color(0xFFF97316), Color(0xFFFB923C)]);
      default:
        return ModernTheme.primaryGradient;
    }
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              PhosphorIconsFill.books,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'categories.title'.tr(),
                  style: AppFonts.outfit(context,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'practice.byCategoryHelper'.tr(),
                  style: AppFonts.outfit(context,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
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
  final LinearGradient gradient;
  final IconData icon;
  final int total;
  final int? accuracy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E293B).withValues(alpha: 0.85)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : scheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppFonts.outfit(context,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: scheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (accuracy != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color:
                                _accuracyColor(accuracy!, scheme)
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$accuracy%',
                            style: AppFonts.outfit(context,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _accuracyColor(accuracy!, scheme)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppFonts.outfit(context,
                        fontSize: 12.5,
                        color: scheme.onSurface.withValues(alpha: 0.55)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsFill.question,
                        size: 13,
                        color: scheme.primary.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'categories.totalQuestions'.tr(
                          namedArgs: {'value': total.toString()},
                        ),
                        style: AppFonts.outfit(context,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: scheme.primary.withValues(alpha: 0.8)),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: scheme.onSurface.withValues(alpha: 0.25),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _accuracyColor(int accuracy, ColorScheme scheme) {
    if (accuracy >= 80) return ModernTheme.emerald;
    if (accuracy >= 60) return ModernTheme.amber;
    return scheme.error;
  }
}

class _ViolationCard extends StatelessWidget {
  const _ViolationCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const gradient = ModernTheme.accentGradient;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradient.colors.first.withValues(alpha: 0.12),
              gradient.colors.last.withValues(alpha: 0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: gradient.colors.first.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                PhosphorIconsFill.warningDiamond,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.outfit(context,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppFonts.outfit(context,
                        fontSize: 12.5,
                        color: scheme.onSurface.withValues(alpha: 0.55)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: scheme.onSurface.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}
