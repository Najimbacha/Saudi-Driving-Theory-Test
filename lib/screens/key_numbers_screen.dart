import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/theme/modern_theme.dart';
import '../presentation/providers/handbook_provider.dart';
import '../utils/app_fonts.dart';
import '../utils/navigation_utils.dart';

class KeyNumbersScreen extends ConsumerStatefulWidget {
  const KeyNumbersScreen({super.key});

  @override
  ConsumerState<KeyNumbersScreen> createState() => _KeyNumbersScreenState();
}

class _KeyNumbersScreenState extends ConsumerState<KeyNumbersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final keyNumbersAsync = ref.watch(keyNumbersProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'keyNumbers.title'.tr(),
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
          child: keyNumbersAsync.when(
            data: (data) => _buildContent(context, data),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('${'common.error'.tr()}: $err')),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    final groups = _groupData(data);
    
    return CustomScrollView(
      slivers: [
        // Hero
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: _NumbersHeroCard(
              title: 'keyNumbers.hero.title'.tr(),
              subtitle: 'keyNumbers.hero.subtitle'.tr(),
            ),
          ),
        ),

        // Search Bar (Simple visual)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'keyNumbers.searchHint'.tr(),
                prefixIcon: const Icon(PhosphorIconsLight.magnifyingGlass),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),

        // List of groups
        ...groups.entries.map((group) {
          final items = group.value.where((item) {
            if (_searchQuery.isEmpty) return true;
            final label = 'keyNumbers.labels.${item.key}'.tr().toLowerCase();
            return label.contains(_searchQuery);
          }).toList();

          if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

          return SliverMainAxisGroup(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'keyNumbers.groups.${group.key}'.tr(),
                    style: AppFonts.outfit(context,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return _NumberCard(
                        value: item.value.toString(),
                        label: 'keyNumbers.labels.${item.key}'.tr(),
                        icon: _getIconForKey(item.key),
                        color: _getColorForGroup(group.key),
                      );
                    },
                    childCount: items.length,
                  ),
                ),
              ),
            ],
          );
        }),
        
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Map<String, List<MapEntry<String, dynamic>>> _groupData(Map<String, dynamic> data) {
    final groups = <String, List<MapEntry<String, dynamic>>>{
      'license': [],
      'safety': [],
      'parking': [],
      'conduct': [],
      'vehicle': [],
    };

    data.forEach((key, value) {
      if (key.contains('license') || key.contains('age')) {
        groups['license']!.add(MapEntry(key, value));
      } else if (key.contains('distance') || key.contains('second') || key.contains('safety')) {
        groups['safety']!.add(MapEntry(key, value));
      } else if (key.contains('parking') || key.contains('bend') || key.contains('hydrant') || key.contains('tunnel')) {
        groups['parking']!.add(MapEntry(key, value));
      } else if (key.contains('drifting') || key.contains('accident') || key.contains('hold') || key.contains('stop')) {
        groups['conduct']!.add(MapEntry(key, value));
      } else {
        groups['vehicle']!.add(MapEntry(key, value));
      }
    });

    return groups;
  }

  IconData _getIconForKey(String key) {
    if (key.contains('age')) return PhosphorIconsFill.identificationCard;
    if (key.contains('validity')) return PhosphorIconsFill.calendarBlank;
    if (key.contains('distance')) return PhosphorIconsFill.arrowsLeftRight;
    if (key.contains('speed')) return PhosphorIconsFill.speedometer;
    if (key.contains('parking')) return PhosphorIconsFill.handDeposit;
    if (key.contains('accident')) return PhosphorIconsFill.warning;
    if (key.contains('fuel')) return PhosphorIconsFill.gasPump;
    return PhosphorIconsFill.hash;
  }

  Color _getColorForGroup(String group) {
    switch (group) {
      case 'license': return Colors.blue;
      case 'safety': return Colors.green;
      case 'parking': return Colors.orange;
      case 'conduct': return Colors.red;
      case 'vehicle': return Colors.teal;
      default: return Colors.grey;
    }
  }
}

class _NumbersHeroCard extends StatelessWidget {
  const _NumbersHeroCard({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              PhosphorIconsFill.listNumbers,
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
    );
  }
}

class _NumberCard extends StatelessWidget {
  const _NumberCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : scheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Text(
                  value,
                  style: AppFonts.outfit(
                    context,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppFonts.outfit(
              context,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: scheme.onSurface.withValues(alpha: 0.85),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
