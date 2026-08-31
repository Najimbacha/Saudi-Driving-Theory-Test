import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/theme/modern_theme.dart';
import '../presentation/providers/handbook_provider.dart';
import '../utils/app_feedback.dart';
import '../utils/app_fonts.dart';
import '../utils/navigation_utils.dart';

class PriorityGuideScreen extends ConsumerStatefulWidget {
  const PriorityGuideScreen({super.key});

  @override
  ConsumerState<PriorityGuideScreen> createState() => _PriorityGuideScreenState();
}

class _PriorityGuideScreenState extends ConsumerState<PriorityGuideScreen> {
  String _selectedCategory = 'hierarchy';

  final List<Map<String, String>> _categories = [
    {'id': 'hierarchy', 'label': 'priority.cat.hierarchy'},
    {'id': 'intersections', 'label': 'priority.cat.intersections'},
    {'id': 'roads', 'label': 'priority.cat.roads'},
    {'id': 'conduct', 'label': 'priority.cat.conduct'},
  ];

  @override
  Widget build(BuildContext context) {
    final priorityDataAsync = ref.watch(priorityRulesProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'priority.title'.tr(),
          style: AppFonts.outfit(context,
              fontWeight: FontWeight.bold, color: scheme.onSurface),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => handleAppBack(context),
          icon: const Icon(PhosphorIconsLight.arrowLeft),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: priorityDataAsync.when(
            data: (data) => _buildContent(context, data),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('${'common.error'.tr()}: $err')),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    return CustomScrollView(
      slivers: [
        // Hero Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: _RuleHeroCard(
              title: 'priority.hero.title'.tr(),
              subtitle: 'priority.hero.subtitle'.tr(),
              philosophy: data['importance'] ?? '',
            ),
          ),
        ),

        // Category Filters
        SliverToBoxAdapter(
          child: _CategoryFilters(
            categories: _categories,
            selectedId: _selectedCategory,
            onSelect: (id) => setState(() => _selectedCategory = id),
          ),
        ),

        // Content Based on Category
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
          sliver: _buildCategoryContent(context, data),
        ),
      ],
    );
  }

  Widget _buildCategoryContent(BuildContext context, Map<String, dynamic> data) {
    switch (_selectedCategory) {
      case 'hierarchy':
        final list = data['priority_order'] as List? ?? [];
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = list[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _PriorityStepCard(
                  priority: item['priority']?.toString() ?? '',
                  title: item['rule'] ?? '',
                  detail: item['detail'] ?? '',
                  icon: _getHierarchyIcon(index),
                  color: _getPriorityColor(index),
                ),
              );
            },
            childCount: list.length,
          ),
        );
      case 'intersections':
        return SliverList(
          delegate: SliverChildListDelegate([
            _SectionHeader(title: 'priority.sec.intersections'.tr()),
            _ScenarioCard(
              title: 'priority.rule.roundabout'.tr(),
              description: data['roundabout']?['rule'] ?? '',
              icon: PhosphorIconsFill.arrowsClockwise,
              accent: Colors.blue,
            ),
            const SizedBox(height: 16),
            _ScenarioCard(
              title: 'priority.rule.uturn'.tr(),
              description: data['u_turn_at_intersection']?['rule'] ?? '',
              icon: PhosphorIconsFill.arrowUDownLeft,
              accent: Colors.orange,
            ),
            const SizedBox(height: 16),
            _StraightPriorityCard(rules: data['driving_straight_priority'] ?? {}),
          ]),
        );
      case 'roads':
        return SliverList(
          delegate: SliverChildListDelegate([
            _SectionHeader(title: 'priority.sec.roads'.tr()),
            _ScenarioCard(
              title: 'priority.rule.highway_enter'.tr(),
              description: data['highway_entering']?['rule'] ?? '',
              icon: PhosphorIconsFill.signpost,
              accent: Colors.green,
            ),
            const SizedBox(height: 16),
            _ScenarioCard(
              title: 'priority.rule.highway_exit'.tr(),
              description: data['highway_exiting']?['rule'] ?? '',
              icon: PhosphorIconsFill.navigationArrow,
              accent: Colors.teal,
            ),
            const SizedBox(height: 16),
            _ScenarioCard(
              title: 'priority.rule.mountain'.tr(),
              description: data['mountain_road']?['rule'] ?? '',
              icon: PhosphorIconsFill.mountains,
              accent: Colors.brown,
            ),
            const SizedBox(height: 16),
            _ScenarioCard(
              title: 'priority.rule.closed_road'.tr(),
              description: data['closed_road_priority']?['rule'] ?? '',
              icon: PhosphorIconsFill.trafficCone,
              accent: Colors.red,
            ),
          ]),
        );
      case 'conduct':
        final conduct = data['general_conduct_at_intersections'] as List? ?? [];
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ConductCard(text: conduct[index]),
            ),
            childCount: conduct.length,
          ),
        );
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  IconData _getHierarchyIcon(int index) {
    switch (index) {
      case 0: return PhosphorIconsFill.ambulance;
      case 1: return PhosphorIconsFill.car;
      case 2: return PhosphorIconsFill.arrowsLeftRight;
      default: return PhosphorIconsFill.warningCircle;
    }
  }

  Color _getPriorityColor(int index) {
    switch (index) {
      case 0: return Colors.redAccent;
      case 1: return Colors.blueAccent;
      case 2: return Colors.orangeAccent;
      default: return Colors.grey;
    }
  }
}

class _RuleHeroCard extends StatelessWidget {
  const _RuleHeroCard({
    required this.title,
    required this.subtitle,
    required this.philosophy,
  });

  final String title;
  final String subtitle;
  final String philosophy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: ModernTheme.royalEmeraldGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ModernTheme.emerald.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  PhosphorIconsFill.shieldCheck,
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
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppFonts.outfit(
                        context,
                        fontSize: 13.5,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              philosophy,
              style: AppFonts.outfit(
                context,
                fontSize: 13,
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.95),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Map<String, String>> categories;
  final String selectedId;
  final Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedId == cat['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterChip(
              label: cat['label']!.tr(),
              selected: isSelected,
              onTap: () {
                AppFeedback.tap(context);
                onSelect(cat['id']!);
              },
            ),
          );
        }).toList(),
      ),
    );
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
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? ModernTheme.primary
                : (isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                    : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? ModernTheme.primary
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : scheme.outline.withValues(alpha: 0.12)),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: ModernTheme.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Text(
            label,
            style: AppFonts.outfit(
              context,
              color: selected
                  ? Colors.white
                  : scheme.onSurface.withValues(alpha: 0.8),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _PriorityStepCard extends StatelessWidget {
  const _PriorityStepCard({
    required this.priority,
    required this.title,
    required this.detail,
    required this.icon,
    required this.color,
  });

  final String priority;
  final String title;
  final String detail;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.12 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  priority,
                  style: AppFonts.outfit(
                    context,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.outfit(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            detail,
            style: AppFonts.outfit(
              context,
              fontSize: 13.5,
              height: 1.5,
              color: scheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppFonts.outfit(context,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface)),
                const SizedBox(height: 8),
                Text(description,
                    style: AppFonts.outfit(context,
                        fontSize: 13,
                        height: 1.5,
                        color: scheme.onSurface.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StraightPriorityCard extends StatelessWidget {
  const _StraightPriorityCard({required this.rules});
  final Map<String, dynamic> rules;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(PhosphorIconsFill.arrowArcRight, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'priority.rule.straight'.tr(),
                style: AppFonts.outfit(context,
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...rules.values.map((rule) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(PhosphorIconsFill.checkCircle, color: Colors.amber, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        rule.toString(),
                        style: AppFonts.outfit(context,
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _ConductCard extends StatelessWidget {
  const _ConductCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIconsFill.lightbulb, color: Colors.amber.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppFonts.outfit(context,
                  fontSize: 13,
                  color: scheme.onSurface.withValues(alpha: 0.8),
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: AppFonts.outfit(context,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}
