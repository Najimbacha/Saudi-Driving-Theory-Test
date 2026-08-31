import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../presentation/providers/handbook_provider.dart';
import '../data/models/handbook_model.dart';
import '../core/theme/modern_theme.dart';
import '../utils/app_feedback.dart';
import '../utils/app_fonts.dart';
import '../presentation/providers/handbook_progress_provider.dart'; // Added import

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handbookAsync = ref.watch(handbookInfoProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'learn.title'.tr(),
          style: AppFonts.outfit(context,
              fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (handbookAsync.valueOrNull != null)
            IconButton(
              icon: Icon(PhosphorIcons.info(), color: Theme.of(context).colorScheme.primary),
              onPressed: () {
                _showIntroDialog(context, handbookAsync.value!.introduction);
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: handbookAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('${'learn.errorLoading'.tr()}: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red)),
              ),
            ),
            data: (info) {
              return ListView(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 40),
                children: [
                  _HeroHeader(info: info),
                  const SizedBox(height: 32),
                  const _QuickActionsGrid(),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Icon(PhosphorIconsFill.student, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'learn.syllabus'.tr(),
                        style: AppFonts.outfit(context,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    info.units.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _UnitCard(unit: info.units[index]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showIntroDialog(BuildContext context, String introduction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('learn.aboutTitle'.tr(),
            style: AppFonts.outfit(context, fontWeight: FontWeight.bold)),
        content: Text(introduction,
            style: AppFonts.outfit(context, height: 1.5, fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('learn.gotIt'.tr(), style: AppFonts.outfit(context, fontWeight: FontWeight.bold)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.info});
  final HandbookInfo info;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    info.issuedBy,
                    style: AppFonts.outfit(context,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  info.title,
                  style: AppFonts.outfit(context,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'learn.unitsCount'.tr(namedArgs: {'count': info.units.length.toString()}),
                  style: AppFonts.outfit(context,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            PhosphorIconsFill.steeringWheel,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends ConsumerWidget {
  const _UnitCard({required this.unit});
  final HandbookUnit unit;

  IconData _getIconForUnit(int unitId) {
    switch (unitId) {
      case 1:
        return PhosphorIconsFill.identificationCard; // License/Intro
      case 2:
        return PhosphorIconsFill.carProfile; // Behavior
      case 3:
        return PhosphorIconsFill.trafficSign; // Traffic Rules
      case 4:
        return PhosphorIconsFill.gitMerge; // Intersections
      case 5:
        return PhosphorIconsFill.gauge; // Speed
      case 6:
        return PhosphorIconsFill.warningCircle; // Overtaking/General
      default:
        return PhosphorIconsFill.bookOpen;
    }
  }

  Color _getColorForUnit(int unitId) {
    switch (unitId) {
      case 1:
        return Colors.blue.shade600;
      case 2:
        return Colors.green.shade600;
      case 3:
        return Colors.orange.shade700;
      case 4:
        return Colors.purple.shade500;
      case 5:
        return Colors.red.shade600;
      case 6:
        return Colors.teal.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unitColor = _getColorForUnit(unit.unitId);
    
    final readTopicIds = ref.watch(handbookProgressProvider);
    final readCount = unit.topics.where((t) => readTopicIds.contains(t.topicId)).length;
    final double rawProgress = unit.topics.isEmpty ? 0 : readCount / unit.topics.length;
    // ensure progress is mathematically sound and visual progress doesn't exceed 1.0
    final double progress = rawProgress.clamp(0.0, 1.0);

    return InkWell(
      onTap: () {
        AppFeedback.tap(context);
        context.push('/learn/unit', extra: unit);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.onSurface.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: unitColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getIconForUnit(unit.unitId),
                color: unitColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'learn.unitLabel'.tr(namedArgs: {'id': unit.unitId.toString()}),
                    style: AppFonts.outfit(context,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: unitColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    unit.title,
                    style: AppFonts.outfit(context,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: scheme.onSurface),
                  ),
                  const SizedBox(height: 6),
                  if (readCount == 0) ...[
                    Row(
                      children: [
                        Icon(PhosphorIcons.books(), size: 14, color: scheme.onSurface.withValues(alpha: 0.5)),
                        const SizedBox(width: 4),
                        Text(
                          'learn.sectionsCount'.tr(namedArgs: {'count': unit.topics.length.toString()}),
                          style: AppFonts.outfit(context,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(readCount == unit.topics.length ? PhosphorIconsFill.checkCircle : PhosphorIcons.books(),
                            size: 14,
                            color: readCount == unit.topics.length ? scheme.primary : scheme.onSurface.withValues(alpha: 0.5)),
                        const SizedBox(width: 4),
                        Text(
                          '$readCount/${unit.topics.length}',
                          style: AppFonts.outfit(context,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: readCount == unit.topics.length ? scheme.primary : scheme.onSurface.withValues(alpha: 0.6)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                              backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
                              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary.withValues(alpha: 0.7)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: scheme.onSurface.withValues(alpha: 0.2)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final guides = [
      {
        'title': 'keyNumbers.title'.tr(),
        'route': '/key-numbers',
        'icon': PhosphorIconsFill.listNumbers,
        'color': Colors.blue,
      },
      {
        'title': 'priority.title'.tr(),
        'route': '/priority-guide',
        'icon': PhosphorIconsFill.shieldCheck,
        'color': Colors.orange.shade800,
      },
      {
        'title': 'violationPoints.title'.tr(),
        'route': '/violation-points',
        'icon': PhosphorIconsFill.warningCircle,
        'color': Colors.red.shade700,
      },
      {
        'title': 'trafficFines.title'.tr(),
        'route': '/traffic-fines',
        'icon': PhosphorIconsFill.money,
        'color': Colors.green.shade600,
      },
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: guides.map((guide) {
        final color = guide['color'] as Color;
        // Make cards take exactly half width minus half the spacing
        final width = (MediaQuery.sizeOf(context).width - 48 - 16) / 2;
        
        return InkWell(
          onTap: () {
            AppFeedback.tap(context);
            context.push(guide['route'] as String);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: width,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(guide['icon'] as IconData, color: color, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  guide['title'] as String,
                  style: AppFonts.outfit(context,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: Theme.of(context).colorScheme.onSurface),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
