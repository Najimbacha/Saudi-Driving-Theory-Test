import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/theme/modern_theme.dart';
import '../presentation/providers/handbook_provider.dart';
import '../utils/app_fonts.dart';
import '../widgets/surface_card.dart';

class TrafficFinesScreen extends ConsumerWidget {
  const TrafficFinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(trafficFineTablesProvider);
    final driftingAsync = ref.watch(driftingPenaltiesProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: tablesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${'common.error'.tr()}: $e')),
          data: (tables) {
            final drifting = driftingAsync.valueOrNull ?? [];
            // Separate speed table (table 8) from regular tables (1–7)
            final regularTables = tables
                .where((t) =>
                    t['table_id'] != 8 &&
                    t.containsKey('violations'))
                .toList();
            final speedTable = tables
                .where((t) => t['table_id'] == 8)
                .toList();

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 130,
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
                    'trafficFines.title'.tr(),
                    style: AppFonts.outfit(context,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: SafeArea(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20, 60, 20, 12),
                        child: Text(
                          'trafficFines.subtitle'.tr(),
                          style: AppFonts.outfit(context,
                              fontSize: 13,
                              color:
                                  scheme.onSurface.withValues(alpha: 0.6)),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: _PaymentInfoCard(),
                  ),
                ),
                // Regular violation tables (1–7)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final table = regularTables[index];
                        return _FineTableCard(table: table);
                      },
                      childCount: regularTables.length,
                    ),
                  ),
                ),
                // Speed fines section
                if (speedTable.isNotEmpty)
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: _SpeedFinesCard(table: speedTable.first),
                    ),
                  ),
                // Drifting penalties
                if (drifting.isNotEmpty)
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: _DriftingPenaltiesCard(penalties: drifting),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PaymentInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppSurfaceCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(PhosphorIconsFill.info,
                  color: scheme.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'trafficFines.paymentNote'.tr(),
                    style: AppFonts.outfit(context,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: scheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'trafficFines.paymentDesc'.tr(),
                    style: AppFonts.outfit(context,
                        fontSize: 12,
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

class _FineTableCard extends StatefulWidget {
  const _FineTableCard({required this.table});
  final Map<String, dynamic> table;

  @override
  State<_FineTableCard> createState() => _FineTableCardState();
}

class _FineTableCardState extends State<_FineTableCard> {
  bool _expanded = false;

  Color _tableColor(int tableId, ColorScheme scheme) {
    if (tableId <= 2) return ModernTheme.tertiary;
    if (tableId <= 4) return Colors.orangeAccent;
    return scheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tableId = widget.table['table_id'] as int? ?? 0;
    final fineRange = widget.table['fine_range_sar'] as String? ?? '';
    final violations =
        (widget.table['violations'] as List?)?.cast<String>() ?? [];
    final color = _tableColor(tableId, scheme);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppSurfaceCard(
        padding: EdgeInsets.zero,
        onTap: () => setState(() => _expanded = !_expanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.15),
                          color.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '#$tableId',
                        style: AppFonts.outfit(context,
                            fontWeight: FontWeight.w800,
                            color: color,
                            fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$fineRange SAR',
                          style: AppFonts.outfit(context,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'trafficFines.violationsCount'.tr(namedArgs: {'count': violations.length.toString()}),
                          style: AppFonts.outfit(context,
                              fontSize: 12,
                              color: scheme.onSurface
                                  .withValues(alpha: 0.5)),
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
            if (_expanded)
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                        height: 1,
                        color:
                            scheme.onSurface.withValues(alpha: 0.06)),
                    const SizedBox(height: 12),
                    ...violations.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: AppFonts.outfit(context,
                                    fontSize: 13,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.75),
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SpeedFinesCard extends StatelessWidget {
  const _SpeedFinesCard({required this.table});
  final Map<String, dynamic> table;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final speedUp120 =
        (table['speed_limit_up_to_120_kmh'] as List?)
                ?.cast<Map<String, dynamic>>() ??
            [];
    final speed140 =
        (table['speed_limit_140_kmh'] as List?)
                ?.cast<Map<String, dynamic>>() ??
            [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppSurfaceCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(PhosphorIconsFill.gauge,
                      color: scheme.error, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'trafficFines.speedFinesTitle'.tr(),
                    style: AppFonts.outfit(context,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: scheme.onSurface),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ≤ 120 km/h table
            Text(
              'trafficFines.speedLimit120'.tr(),
              style: AppFonts.outfit(context,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: scheme.onSurface.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 8),
            _SpeedFineTable(data: speedUp120, scheme: scheme),
            const SizedBox(height: 16),
            // 140 km/h table
            Text(
              'trafficFines.speedLimit140'.tr(),
              style: AppFonts.outfit(context,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: scheme.onSurface.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 8),
            _SpeedFineTable(data: speed140, scheme: scheme),
          ],
        ),
      ),
    );
  }
}

class _SpeedFineTable extends StatelessWidget {
  const _SpeedFineTable({required this.data, required this.scheme});
  final List<Map<String, dynamic>> data;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Table(
        border: TableBorder.all(
          color: scheme.onSurface.withValues(alpha: 0.08),
          width: 1,
        ),
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(2),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : scheme.primary.withValues(alpha: 0.05),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'trafficFines.exceedingBy'.tr(),
                  style: AppFonts.outfit(context,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: scheme.onSurface),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'trafficFines.fineSar'.tr(),
                  style: AppFonts.outfit(context,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: scheme.onSurface),
                ),
              ),
            ],
          ),
          ...data.map((row) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    row['exceeding_by'] as String? ?? '',
                    style: AppFonts.outfit(context,
                        fontSize: 11,
                        color:
                            scheme.onSurface.withValues(alpha: 0.75)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    row['fine_range_sar'] as String? ?? '',
                    style: AppFonts.outfit(context,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: scheme.error),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _DriftingPenaltiesCard extends StatelessWidget {
  const _DriftingPenaltiesCard({required this.penalties});
  final List<Map<String, dynamic>> penalties;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppSurfaceCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(PhosphorIconsFill.prohibit,
                      color: scheme.error, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'trafficFines.driftingTitle'.tr(),
                    style: AppFonts.outfit(context,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: scheme.onSurface),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'trafficFines.driftingDesc'.tr(),
              style: AppFonts.outfit(context,
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            ...penalties.asMap().entries.map((entry) {
              final idx = entry.key;
              final penalty = entry.value;
              final offense = penalty['offense'] as String? ?? '';
              final penaltyText = penalty['penalty'] as String? ?? '';
              final isLast = idx == penalties.length - 1;
              final color = isLast ? scheme.error : Colors.orangeAccent;

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${idx + 1}',
                          style: AppFonts.outfit(context,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offense,
                            style: AppFonts.outfit(context,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: scheme.onSurface),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            penaltyText,
                            style: AppFonts.outfit(context,
                                fontSize: 12,
                                color: scheme.onSurface
                                    .withValues(alpha: 0.65),
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
