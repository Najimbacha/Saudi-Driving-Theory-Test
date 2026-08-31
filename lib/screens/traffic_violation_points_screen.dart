import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/theme/modern_theme.dart';
import '../presentation/providers/handbook_provider.dart';
import '../utils/app_fonts.dart';
import '../widgets/surface_card.dart';

class TrafficViolationPointsScreen extends ConsumerStatefulWidget {
  const TrafficViolationPointsScreen({super.key});

  @override
  ConsumerState<TrafficViolationPointsScreen> createState() =>
      _TrafficViolationPointsScreenState();
}

class _TrafficViolationPointsScreenState
    extends ConsumerState<TrafficViolationPointsScreen> {
  String _selectedCategory = 'severe'; // severe, major, minor

  @override
  Widget build(BuildContext context) {
    final violationsAsync = ref.watch(violationPointsProvider);
    final withdrawalAsync = ref.watch(licenseWithdrawalProvider);
    final maxPointsAsync = ref.watch(maxViolationPointsProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: violationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${'common.error'.tr()}: $e')),
          data: (violations) {
            final severe =
                violations.where((v) => (v['points'] as int) >= 12).toList();
            final major = violations
                .where((v) =>
                    (v['points'] as int) >= 6 && (v['points'] as int) < 12)
                .toList();
            final minor =
                violations.where((v) => (v['points'] as int) < 6).toList();

            final maxPoints = maxPointsAsync.valueOrNull ?? 24;
            final withdrawal = withdrawalAsync.valueOrNull ?? [];

            List<Map<String, dynamic>> displayedItems;
            Color accentColor;
            if (_selectedCategory == 'severe') {
              displayedItems = severe;
              accentColor = scheme.error;
            } else if (_selectedCategory == 'major') {
              displayedItems = major;
              accentColor = Colors.orangeAccent;
            } else {
              displayedItems = minor;
              accentColor = ModernTheme.tertiary;
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 140,
                  pinned: true,
                  stretch: true,
                  backgroundColor:
                      isDark ? const Color(0xFF0F172A) : Colors.white,
                  elevation: 0,
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  title: Text(
                    'violationPoints.title'.tr(),
                    style: AppFonts.outfit(context,
                        fontWeight: FontWeight.bold, color: scheme.onSurface),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: SafeArea(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20, 60, 20, 0),
                        child: Text(
                          'violationPoints.summaryTitle'.tr(),
                          style: AppFonts.outfit(context,
                              fontSize: 14,
                              color: scheme.onSurface.withValues(alpha: 0.6)),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _RuleHeroCard(maxPoints: maxPoints),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _CategoryFilters(
                    selected: _selectedCategory,
                    onSelect: (cat) => setState(() => _selectedCategory = cat),
                    counts: {
                      'severe': severe.length,
                      'major': major.length,
                      'minor': minor.length,
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _ViolationCard(
                          item: displayedItems[index],
                          accent: accentColor,
                        );
                      },
                      childCount: displayedItems.length,
                    ),
                  ),
                ),
                if (_selectedCategory == 'severe' && withdrawal.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'violationPoints.withdrawalScheduleTitle'.tr(),
                        style: AppFonts.outfit(context,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: scheme.onSurface),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _WithdrawalTimeline(schedule: withdrawal),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RuleHeroCard extends StatelessWidget {
  const _RuleHeroCard({required this.maxPoints});
  final int maxPoints;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary.withValues(alpha: 0.08),
              scheme.primary.withValues(alpha: 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: ModernTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      maxPoints.toString(),
                      style: AppFonts.outfit(context,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                    Text(
                      'violationPoints.pointsSmall'.tr(),
                      style: AppFonts.outfit(context,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'violationPoints.impactTitle'.tr(),
                    style: AppFonts.outfit(context,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: scheme.onSurface),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'violationPoints.resetNote'.tr(),
                    style: AppFonts.outfit(context,
                        fontSize: 13,
                        color: scheme.onSurface.withValues(alpha: 0.6),
                        height: 1.4),
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

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.selected,
    required this.onSelect,
    required this.counts,
  });
  final String selected;
  final Function(String) onSelect;
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          _FilterChip(
            label: 'violationPoints.severeTab'.tr(),
            count: counts['severe'] ?? 0,
            isSelected: selected == 'severe',
            onTap: () => onSelect('severe'),
            color: scheme.error,
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: 'violationPoints.majorTab'.tr(),
            count: counts['major'] ?? 0,
            isSelected: selected == 'major',
            onTap: () => onSelect('major'),
            color: Colors.orangeAccent,
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: 'violationPoints.minorTab'.tr(),
            count: counts['minor'] ?? 0,
            isSelected: selected == 'minor',
            onTap: () => onSelect('minor'),
            color: ModernTheme.tertiary,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : scheme.onSurface.withValues(alpha: 0.12),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppFonts.outfit(context,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : scheme.onSurface),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                count.toString(),
                style: AppFonts.outfit(context,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViolationCard extends StatefulWidget {
  const _ViolationCard({required this.item, required this.accent});
  final Map<String, dynamic> item;
  final Color accent;

  @override
  State<_ViolationCard> createState() => _ViolationCardState();
}

class _ViolationCardState extends State<_ViolationCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final points = widget.item['points'] as int? ?? 0;
    final violation = widget.item['violation'] as String? ?? '';
    final no = widget.item['no'] as int? ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppSurfaceCard(
        padding: EdgeInsets.zero,
        onTap: () => setState(() => _expanded = !_expanded),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _PointBadge(points: points, color: widget.accent),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          violation,
                          style: AppFonts.outfit(context,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: scheme.onSurface,
                              height: 1.2),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#$no · $points ${'violationPoints.pointsLabel'.tr(namedArgs: {'value': points.toString()})}',
                          style: AppFonts.outfit(context,
                              fontSize: 12,
                              color: scheme.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _expanded ? 0.5 : 0,
                    child: Icon(
                      PhosphorIconsFill.caretDown,
                      size: 16,
                      color: scheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            if (_expanded) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    Divider(
                        height: 1,
                        color: scheme.onSurface.withValues(alpha: 0.05)),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: PhosphorIconsFill.info,
                      text: _getSeverityText(points),
                      color: widget.accent,
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: PhosphorIconsFill.lightbulb,
                      text:
                          '${'violationPoints.tipHeader'.tr()}: ${'violationPoints.tipBody'.tr()}',
                      color: scheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getSeverityText(int points) {
    if (points >= 24) return 'violationPoints.severity_critical'.tr();
    if (points >= 12) return 'violationPoints.severity_very_serious'.tr();
    if (points >= 8) return 'violationPoints.severity_high_impact'.tr();
    if (points >= 6) return 'violationPoints.severity_serious'.tr();
    return 'violationPoints.severity_care'.tr();
  }
}

class _PointBadge extends StatelessWidget {
  const _PointBadge({required this.points, required this.color});
  final int points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Center(
        child: Text(
          points.toString(),
          style: AppFonts.outfit(context,
              fontWeight: FontWeight.w900, fontSize: 20, color: color),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppFonts.outfit(context,
                fontSize: 12,
                color: scheme.onSurface.withValues(alpha: 0.7),
                height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _WithdrawalTimeline extends StatelessWidget {
  const _WithdrawalTimeline({required this.schedule});
  final List<Map<String, dynamic>> schedule;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppSurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: schedule.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final offense = item['offense_in_one_hijri_year'] as String? ?? '';
          final period = item['withdrawal_period'] as String? ?? '';
          final isLast = idx == schedule.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isLast ? scheme.error : scheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: (isLast ? scheme.error : scheme.primary)
                                .withValues(alpha: 0.3),
                            blurRadius: 6,
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${idx + 1}',
                          style: AppFonts.outfit(context,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: scheme.onSurface.withValues(alpha: 0.1),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$offense ${'violationPoints.offenseSuffix'.tr()}',
                          style: AppFonts.outfit(context,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: scheme.onSurface),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isLast ? scheme.error : scheme.primary)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            period,
                            style: AppFonts.outfit(context,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: isLast ? scheme.error : scheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

