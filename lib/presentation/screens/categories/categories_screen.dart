import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/modern_theme.dart';
import '../../../widgets/surface_card.dart';
import '../../../state/learning_state.dart';
import '../../../utils/app_feedback.dart';
import '../../../utils/app_fonts.dart';
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

    // Optimize: Read pre-calculated counts instead of looping in build
    final questionCounts = ref.watch(categoryQuestionCountsProvider);
    final hasQuestionData = questionCounts.isNotEmpty;

    final visible = categories;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor:
                isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon:
                  Icon(PhosphorIconsRegular.caretLeft, color: scheme.onSurface),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'categories.title'.tr(),
                style: AppFonts.outfit(
                  context,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: scheme.onSurface,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF1E293B).withValues(alpha: 0.5),
                            Colors.transparent
                          ]
                        : [
                            const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                            Colors.transparent
                          ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final trafficIndex = visible.isEmpty ? 0 : 1;
                  if (index == trafficIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _TrafficViolationCard(
                        title: 'home.violationPoints'.tr(),
                        subtitle: 'home.violationPointsDesc'.tr(),
                        onTap: () => context.push('/violation-points'),
                      ),
                    );
                  }

                  final categoryIndex =
                      index < trafficIndex ? index : index - 1;
                  final category = visible[categoryIndex];
                  final stat = learning.categoryStats[category.id];
                  final accuracy = stat?.accuracy;
                  final total = hasQuestionData
                      ? (questionCounts[category.id] ?? 0)
                      : category.totalQuestions;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _CategoryPremiumCard(
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
                  );
                },
                childCount: visible.length + 1,
              ),
            ),
          ),
        ],
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

class _CategoryPremiumCard extends StatelessWidget {
  const _CategoryPremiumCard({
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

    return AppSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppFonts.outfit(
                          context,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (accuracy != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _accuracyColor(accuracy!, scheme)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _accuracyColor(accuracy!, scheme)
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          '$accuracy%',
                          style: AppFonts.outfit(
                            context,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: _accuracyColor(accuracy!, scheme),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppFonts.outfit(
                    context,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.question,
                      size: 14,
                      color: scheme.onSurface.withValues(alpha: 0.45),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'categories.totalQuestions'.tr(
                        namedArgs: {'value': total.toString()},
                      ),
                      style: AppFonts.outfit(
                        context,
                        color: scheme.onSurface.withValues(alpha: 0.45),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      PhosphorIconsRegular.caretRight,
                      size: 14,
                      color: scheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _accuracyColor(int accuracy, ColorScheme scheme) {
    if (accuracy >= 80) return ModernTheme.tertiary;
    if (accuracy >= 60) return Colors.orangeAccent;
    return scheme.error;
  }
}

class _TrafficViolationCard extends StatelessWidget {
  const _TrafficViolationCard({
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

    return AppSurfaceCard(
      onTap: () {
        AppFeedback.tap(context);
        onTap();
      },
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              PhosphorIconsFill.warningDiamond,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.outfit(
                    context,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppFonts.outfit(
                    context,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            PhosphorIconsRegular.caretRight,
            size: 14,
            color: scheme.onSurface.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
