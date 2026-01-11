import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/modern_theme.dart';
import '../utils/app_fonts.dart';
import '../widgets/glass_container.dart';

class TrafficViolationPointsScreen extends StatelessWidget {
  const TrafficViolationPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'violationPoints.title'.tr(),
            style: AppFonts.outfit(
              context,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: scheme.onSurface),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? ModernTheme.darkGradient
                : ModernTheme.lightGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(6),
                    borderRadius: BorderRadius.circular(18),
                    blur: isDark ? 10 : 6,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.9),
                    border: Border.all(
                      color: scheme.onSurface.withValues(alpha: 0.08),
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.all(4),
                      labelStyle: AppFonts.outfit(
                        context,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: AppFonts.outfit(
                        context,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor:
                          scheme.onSurface.withValues(alpha: 0.7),
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        gradient: ModernTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      tabs: [
                        Tab(text: 'violationPoints.severeTab'.tr()),
                        Tab(text: 'violationPoints.majorTab'.tr()),
                        Tab(text: 'violationPoints.minorTab'.tr()),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _ViolationList(
                        title: 'violationPoints.severeTitle'.tr(),
                        items: _severeViolations,
                        accent: AppColors.error,
                      ),
                      _ViolationList(
                        title: 'violationPoints.majorTitle'.tr(),
                        items: _majorViolations,
                        accent: AppColors.warning,
                      ),
                      _ViolationList(
                        title: 'violationPoints.minorTitle'.tr(),
                        items: _minorViolations,
                        accent: AppColors.success,
                      ),
                    ],
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

class _ViolationList extends StatelessWidget {
  const _ViolationList({
    required this.title,
    required this.items,
    required this.accent,
  });

  final String title;
  final List<_ViolationItem> items;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 24),
      cacheExtent: 800,
      children: [
        Text(
          title,
          style: AppFonts.outfit(
            context,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(20),
          blur: isDark ? 10 : 6,
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.9),
          border: Border.all(
            color: scheme.onSurface.withValues(alpha: 0.08),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.4)),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'violationPoints.summaryTitle'.tr(),
                      style: AppFonts.outfit(
                        context,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'violationPoints.summaryLine1'.tr(),
                      style: AppFonts.outfit(
                        context,
                        color: scheme.onSurface.withValues(alpha: 0.75),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'violationPoints.summaryLine2'.tr(),
                      style: AppFonts.outfit(
                        context,
                        color: scheme.onSurface.withValues(alpha: 0.75),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'violationPoints.summaryLine3'.tr(),
                      style: AppFonts.outfit(
                        context,
                        color: scheme.onSurface.withValues(alpha: 0.75),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassContainer(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
              borderRadius: BorderRadius.circular(18),
              blur: isDark ? 10 : 6,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.92),
              border: Border.all(
                color: scheme.onSurface.withValues(alpha: 0.08),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        item.points.toString(),
                        style: AppFonts.outfit(
                          context,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'violations.${item.id}'.tr(),
                          style: AppFonts.outfit(
                            context,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'violationPoints.pointsLabel'.tr(
                            namedArgs: {'value': item.points.toString()},
                          ),
                          style: AppFonts.outfit(
                            context,
                            fontSize: 12,
                            color: scheme.onSurface.withValues(alpha: 0.65),
                          ),
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
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'violationPoints.tipBody'.tr(),
          style: AppFonts.outfit(
            context,
            fontSize: 12,
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _ViolationItem {
  const _ViolationItem({required this.id, required this.points});

  final String id;
  final int points;
}

const _severeViolations = [
  _ViolationItem(id: 'v01', points: 24),
  _ViolationItem(id: 'v02', points: 24),
  _ViolationItem(id: 'v03', points: 12),
  _ViolationItem(id: 'v04', points: 12),
];

const _majorViolations = [
  _ViolationItem(id: 'v05', points: 8),
  _ViolationItem(id: 'v06', points: 6),
  _ViolationItem(id: 'v07', points: 6),
  _ViolationItem(id: 'v08', points: 6),
];

const _minorViolations = [
  _ViolationItem(id: 'v09', points: 4),
  _ViolationItem(id: 'v10', points: 4),
  _ViolationItem(id: 'v11', points: 4),
  _ViolationItem(id: 'v12', points: 2),
  _ViolationItem(id: 'v13', points: 2),
];
