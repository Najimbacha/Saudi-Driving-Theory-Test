import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/modern_theme.dart';
import '../../../widgets/glass_container.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('categories.title'.tr(),
            style: AppFonts.outfit(context,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? ModernTheme.darkGradient
              : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  cacheExtent: 800,
                  itemCount: visible.length + 1,
                  itemBuilder: (context, index) {
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
                      child: _CategoryGlassCard(
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
        return PhosphorIconsRegular.trafficSign;
      case 'rules':
        return PhosphorIconsRegular.gavel;
      case 'safety':
        return PhosphorIconsRegular.shieldCheck;
      case 'signals':
        return PhosphorIconsRegular.trafficSignal;
      case 'markings':
        return PhosphorIconsRegular.roadHorizon;
      case 'parking':
        return PhosphorIconsRegular.carSimple;
      case 'emergency':
        return PhosphorIconsRegular.warning;
      case 'pedestrians':
        return PhosphorIconsRegular.personSimpleWalk;
      case 'highway':
        return PhosphorIconsRegular.roadHorizon;
      case 'weather':
        return PhosphorIconsRegular.sunDim;
      case 'maintenance':
        return PhosphorIconsRegular.wrench;
      case 'responsibilities':
        return PhosphorIconsRegular.identificationBadge;
      default:
        return PhosphorIconsRegular.gridFour;
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

class _CategoryGlassCard extends StatelessWidget {
  const _CategoryGlassCard({
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
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: EdgeInsetsDirectional.zero,
        borderRadius: BorderRadius.circular(22),
        blur: isDark ? 10 : 6,
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.9),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.12 : 0.08),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(22),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      gradient.colors.first.withValues(alpha: 0.9),
                      gradient.colors.last.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -28,
              top: -34,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      gradient.colors.first
                          .withValues(alpha: isDark ? 0.2 : 0.12),
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 26),
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
                                  color: _accuracyColor(accuracy!)
                                      .withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _accuracyColor(accuracy!)
                                        .withValues(alpha: 0.45),
                                  ),
                                ),
                                child: Text(
                                  '$accuracy%',
                                  style: AppFonts.outfit(
                                    context,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: _accuracyColor(accuracy!),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: AppFonts.outfit(
                            context,
                            color: scheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              PhosphorIconsRegular.question,
                              size: 14,
                              color: scheme.onSurface.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'categories.totalQuestions'.tr(
                                namedArgs: {'value': total.toString()},
                              ),
                              style: AppFonts.outfit(
                                context,
                                color:
                                    scheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color:
                                    scheme.onSurface.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                PhosphorIconsRegular.caretRight,
                                size: 14,
                                color:
                                    scheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _accuracyColor(int accuracy) {
    if (accuracy >= 80) return AppColors.success;
    if (accuracy >= 60) return AppColors.warning;
    return AppColors.error;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = ModernTheme.accentGradient;
    return GestureDetector(
      onTap: () {
        AppFeedback.tap(context);
        onTap();
      },
      child: GlassContainer(
        padding: EdgeInsetsDirectional.zero,
        borderRadius: BorderRadius.circular(22),
        blur: isDark ? 10 : 6,
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.9),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: isDark ? 0.12 : 0.08),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(22),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      gradient.colors.first.withValues(alpha: 0.9),
                      gradient.colors.last.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -28,
              top: -34,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      gradient.colors.first
                          .withValues(alpha: isDark ? 0.2 : 0.12),
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      PhosphorIconsRegular.warningDiamond,
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
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: AppFonts.outfit(
                            context,
                            color: scheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIconsRegular.caretRight,
                      size: 14,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
