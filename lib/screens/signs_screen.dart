import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/theme/modern_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    final signsAsync = ref.watch(signsProvider);
    final locale = context.locale.languageCode;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceFill = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.9);
    final borderColor = scheme.onSurface.withValues(alpha: 0.08);
    final mutedText = scheme.onSurface.withValues(alpha: 0.6);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('signs.title'.tr(),
            style: AppFonts.outfit(context,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        leading: IconButton(
          onPressed: () => handleAppBack(context),
          icon: const Icon(Icons.arrow_back),
        ),
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
              // Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                child: Row(
                  children: [
                    _GlassFilterChip(
                      label: 'signs.categories.all'.tr(),
                      selected: category == 'all',
                      onTap: () => setState(() => category = 'all'),
                    ),
                    const SizedBox(width: 12),
                    _GlassFilterChip(
                      label: 'signs.categories.warning'.tr(),
                      selected: category == 'warning',
                      onTap: () => setState(() => category = 'warning'),
                    ),
                    const SizedBox(width: 12),
                    _GlassFilterChip(
                      label: 'signs.categories.regulatory'.tr(),
                      selected: category == 'regulatory',
                      onTap: () => setState(() => category = 'regulatory'),
                    ),
                    const SizedBox(width: 12),
                    _GlassFilterChip(
                      label: 'signs.categories.mandatory'.tr(),
                      selected: category == 'mandatory',
                      onTap: () => setState(() => category = 'mandatory'),
                    ),
                    const SizedBox(width: 12),
                    _GlassFilterChip(
                      label: 'signs.categories.guide'.tr(),
                      selected: category == 'guide',
                      onTap: () => setState(() => category = 'guide'),
                    ),
                  ],
                ),
              ),

              // Grid
              Expanded(
                child: signsAsync.when(
                  data: (signs) {
                    final filtered = signs.where((s) {
                      final matchCategory =
                          category == 'all' || s.category == category;
                      return matchCategory;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 64,
                                color: scheme.onSurface.withValues(alpha: 0.2)),
                            const SizedBox(height: 16),
                            Text(
                              'signs.empty'.tr(),
                              style: AppFonts.outfit(context,
                                  color:
                                      scheme.onSurface.withValues(alpha: 0.6),
                                  fontSize: 16),
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
                            : 3; // Dense grid

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                      cacheExtent: 900,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.88,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, idx) {
                        final sign = filtered[idx];
                        final title =
                            sign.titles[locale] ?? sign.titles['en'] ?? '';
                        return GestureDetector(
                          onTap: () {
                            AppFeedback.tap(context);
                            _showSignDetails(context, sign, title);
                          },
                          child: GlassContainer(
                            padding: const EdgeInsets.all(12),
                            blur: isDark ? 10 : 6,
                            color: surfaceFill,
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final iconSize = (constraints.maxWidth *
                                              0.6)
                                          .clamp(46.0, 86.0);
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
                                const SizedBox(height: 10),
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: AppFonts.outfit(context,
                                    color: mutedText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                    child: Text('signs.loadError'.tr(),
                        style: AppFonts.outfit(context,color: scheme.onSurface)),
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
        return GlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                style: AppFonts.outfit(context,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ModernTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: ModernTheme.primary.withValues(alpha: 0.5)),
                ),
                child: Text(
                  'signs.categories.${sign.category}'.tr(),
                  style: AppFonts.outfit(context,
                    color: ModernTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : ModernTheme.primary.withValues(alpha: 0.12),
                    foregroundColor:
                        isDark ? Colors.white : ModernTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('common.close'.tr(),
                      style: AppFonts.outfit(context,fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlassFilterChip extends StatelessWidget {
  const _GlassFilterChip({
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
    return GestureDetector(
      onTap: () {
        AppFeedback.tap(context);
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? null
              : scheme.onSurface.withValues(alpha: isDark ? 0.06 : 0.05),
          gradient: selected ? ModernTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : scheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: AppFonts.outfit(context,
            color: selected
                ? Colors.white
                : scheme.onSurface.withValues(alpha: 0.8),
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

