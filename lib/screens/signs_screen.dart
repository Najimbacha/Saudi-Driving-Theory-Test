import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/theme/modern_theme.dart';
import '../presentation/providers/handbook_provider.dart';
import '../utils/app_feedback.dart';
import '../utils/app_fonts.dart';
import '../utils/navigation_utils.dart';
import '../widgets/glass_container.dart';
import '../models/sign.dart';
import '../state/data_state.dart';

class SignsScreen extends ConsumerStatefulWidget {
  const SignsScreen({super.key});

  @override
  ConsumerState<SignsScreen> createState() => _SignsScreenState();
}

class _SignsScreenState extends ConsumerState<SignsScreen> {
  String category = 'all';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signsAsync = ref.watch(signsProvider);
    final locale = context.locale.languageCode;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceFill = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.95);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : scheme.outline.withValues(alpha: 0.12);
    final mutedText = scheme.onSurface.withValues(alpha: 0.75);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'signs.title'.tr(),
          style: AppFonts.outfit(
            context,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: scheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: scheme.onSurface),
        leading: IconButton(
          onPressed: () => handleAppBack(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          Container(
            margin: const EdgeInsetsDirectional.only(end: 14),
            child: IconButton(
              onPressed: () {
                AppFeedback.tap(context);
                context.push('/signs/flashcards', extra: category);
              },
              icon: const Icon(PhosphorIconsFill.cards, size: 22),
              tooltip: 'signs.flashcards.launch'.tr(),
              style: IconButton.styleFrom(
                backgroundColor: ModernTheme.primary.withValues(alpha: 0.15),
                foregroundColor: ModernTheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : scheme.outline.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) =>
                        setState(() => searchQuery = value.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search traffic signs...',
                      hintStyle: AppFonts.outfit(
                        context,
                        color: scheme.onSurface.withValues(alpha: 0.45),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        PhosphorIconsRegular.magnifyingGlass,
                        size: 20,
                        color: scheme.onSurface.withValues(alpha: 0.5),
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),

              // Category Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
                child: Row(
                  children: [
                    _GlassFilterChip(
                      icon: PhosphorIconsFill.squaresFour,
                      label: 'signs.categories.all'.tr(),
                      selected: category == 'all',
                      onTap: () => setState(() => category = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _GlassFilterChip(
                      icon: PhosphorIconsFill.warning,
                      label: 'signs.categories.warning'.tr(),
                      selected: category == 'warning',
                      onTap: () => setState(() => category = 'warning'),
                    ),
                    const SizedBox(width: 8),
                    _GlassFilterChip(
                      icon: PhosphorIconsFill.prohibit,
                      label: 'signs.categories.regulatory'.tr(),
                      selected: category == 'regulatory',
                      onTap: () => setState(() => category = 'regulatory'),
                    ),
                    const SizedBox(width: 8),
                    _GlassFilterChip(
                      icon: PhosphorIconsFill.arrowCircleRight,
                      label: 'signs.categories.mandatory'.tr(),
                      selected: category == 'mandatory',
                      onTap: () => setState(() => category = 'mandatory'),
                    ),
                    const SizedBox(width: 8),
                    _GlassFilterChip(
                      icon: PhosphorIconsFill.mapPin,
                      label: 'signs.categories.guide'.tr(),
                      selected: category == 'guide',
                      onTap: () => setState(() => category = 'guide'),
                    ),
                  ],
                ),
              ),

              // Signs Grid
              Expanded(
                child: signsAsync.when(
                  data: (signs) {
                    final filtered = signs.where((s) {
                      final matchCategory =
                          category == 'all' || s.category == category;
                      if (!matchCategory) return false;
                      if (searchQuery.isEmpty) return true;
                      final title = (s.titles[locale] ?? s.titles['en'] ?? '')
                          .toLowerCase();
                      return title.contains(searchQuery);
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIconsRegular.trafficSign,
                              size: 64,
                              color: scheme.onSurface.withValues(alpha: 0.25),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'signs.empty'.tr(),
                              style: AppFonts.outfit(
                                context,
                                color: scheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final width = MediaQuery.of(context).size.width;
                    final columns = width >= 900
                        ? 5
                        : width >= 600
                            ? 4
                            : 3;

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      physics: const BouncingScrollPhysics(),
                      cacheExtent: 1000,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.84,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, idx) {
                        final sign = filtered[idx];
                        final title =
                            sign.titles[locale] ?? sign.titles['en'] ?? '';
                        return Semantics(
                          button: true,
                          label: title,
                          child: InkWell(
                            onTap: () {
                              AppFeedback.tap(context);
                              _showSignDetails(context, sign, title);
                            },
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: surfaceFill,
                                border: Border.all(color: borderColor),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: isDark ? 0.15 : 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final iconSize =
                                            (constraints.maxWidth * 0.65)
                                                .clamp(48.0, 90.0);
                                        return Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.04)
                                                : scheme.onSurface
                                                    .withValues(alpha: 0.03),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Hero(
                                            tag: 'sign_${sign.id}',
                                            child: SizedBox(
                                              width: iconSize,
                                              height: iconSize,
                                              child: RepaintBoundary(
                                                child: SvgPicture.asset(
                                                  'assets/${sign.svgPath}',
                                                  fit: BoxFit.contain,
                                                  alignment: Alignment.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: AppFonts.outfit(
                                      context,
                                      color: mutedText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                    child: Text(
                      'signs.loadError'.tr(),
                      style: AppFonts.outfit(context, color: scheme.onSurface),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignDetails(BuildContext context, AppSign sign, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final iconSize =
            (MediaQuery.of(context).size.width * 0.55).clamp(200.0, 300.0);

        // Map sign category to handbook category names
        final categoryMap = {
          'warning': 'Warning Signs',
          'regulatory': 'Regulatory (Directive) Signs',
          'mandatory': 'Regulatory (Directive) Signs',
          'guide': 'Guide Signs',
        };
        final handbookCategoryName = categoryMap[sign.category];

        return Consumer(builder: (context, ref, _) {
          final categoriesAsync = ref.watch(signCategoriesProvider);
          Map<String, dynamic>? catInfo;
          categoriesAsync.whenData((categories) {
            for (final cat in categories) {
              if (cat['category'] == handbookCategoryName) {
                catInfo = cat;
                break;
              }
            }
          });

          String? shapeText;
          String? colorsText;
          String? purposeText;
          if (catInfo != null) {
            shapeText = catInfo!['shape'] as String?;
            final colors = catInfo!['colors'];
            if (colors is String) {
              colorsText = colors;
            } else if (colors is Map) {
              colorsText = colors.entries
                  .map((e) =>
                      '${e.key.toString().replaceAll('_', ' ')}: ${e.value}')
                  .join(' · ');
            }
            purposeText = catInfo!['purpose'] as String?;
          }

          return GlassContainer(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(32)),
            color: isDark
                ? const Color(0xFF0F172A).withValues(alpha: 0.95)
                : scheme.surface.withValues(alpha: 0.95),
            padding: const EdgeInsets.fromLTRB(25, 12, 25, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: scheme.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 30),
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: Hero(
                    tag: 'sign_${sign.id}',
                    child: SvgPicture.asset(
                      'assets/${sign.svgPath}',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: AppFonts.outfit(
                    context,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ModernTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color:
                            ModernTheme.primary.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'signs.categories.${sign.category}'.tr(),
                    style: AppFonts.outfit(
                      context,
                      color: ModernTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Category info from handbook JSON
                if (catInfo != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : scheme.onSurface.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: scheme.onSurface.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (shapeText != null)
                          _SignInfoRow(
                            label: 'signs.labelShape'.tr(),
                            value: shapeText,
                            scheme: scheme,
                          ),
                        if (colorsText != null) ...[
                          const SizedBox(height: 8),
                          _SignInfoRow(
                            label: 'signs.labelColors'.tr(),
                            value: colorsText,
                            scheme: scheme,
                          ),
                        ],
                        if (purposeText != null) ...[
                          const SizedBox(height: 8),
                          _SignInfoRow(
                            label: 'signs.labelPurpose'.tr(),
                            value: purposeText,
                            scheme: scheme,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : ModernTheme.primary.withValues(alpha: 0.12),
                      foregroundColor:
                          isDark ? Colors.white : ModernTheme.primary,
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text('common.close'.tr(),
                        style: AppFonts.outfit(context,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

class _SignInfoRow extends StatelessWidget {
  const _SignInfoRow({
    required this.label,
    required this.value,
    required this.scheme,
  });
  final String label;
  final String value;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: AppFonts.outfit(
              context,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppFonts.outfit(
              context,
              fontSize: 12,
              color: scheme.onSurface.withValues(alpha: 0.75),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassFilterChip extends StatelessWidget {
  const _GlassFilterChip({
    this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData? icon;
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
      label: label,
      child: GestureDetector(
        onTap: () {
          AppFeedback.tap(context);
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  color: ModernTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: selected
                      ? Colors.white
                      : (isDark
                          ? Colors.white70
                          : scheme.onSurface.withValues(alpha: 0.75)),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppFonts.outfit(
                  context,
                  color: selected
                      ? Colors.white
                      : scheme.onSurface.withValues(alpha: 0.85),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
