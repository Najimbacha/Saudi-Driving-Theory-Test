import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/theme/modern_theme.dart';
import '../state/app_state.dart';
import '../state/data_state.dart';
import '../utils/app_feedback.dart';
import '../utils/app_fonts.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(appSettingsProvider).favorites;
    final questionsAsync = ref.watch(questionsProvider);
    final signsAsync = ref.watch(signsProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'favorites.title'.tr(),
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
          bottom: TabBar(
            indicatorColor: ModernTheme.primary,
            indicatorWeight: 3,
            labelColor: ModernTheme.primary,
            unselectedLabelColor: scheme.onSurface.withValues(alpha: 0.5),
            labelStyle: AppFonts.outfit(
              context,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            tabs: [
              Tab(text: 'practice.byCategory'.tr()),
              Tab(text: 'signs.title'.tr()),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient:
                isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
          ),
          child: SafeArea(
            child: TabBarView(
              children: [
                questionsAsync.when(
                  data: (questions) {
                    final list = questions
                        .where((q) => favorites.questions.contains(q.id))
                        .toList();
                    if (list.isEmpty) {
                      return _EmptyFavoritesState(
                        icon: PhosphorIconsRegular.bookmarkSimple,
                        message: 'common.empty'.tr(),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final q = list[index];
                        final lang = context.locale.languageCode;
                        final text = (lang == 'ar' && q.questionTextAr != null)
                            ? q.questionTextAr!
                            : (q.questionText ?? q.questionKey.tr());
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : scheme.outline.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      q.categoryKey.tr(),
                                      style: AppFonts.outfit(
                                        context,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: ModernTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      text,
                                      style: AppFonts.outfit(
                                        context,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  PhosphorIconsFill.bookmarkSimple,
                                  color: ModernTheme.primary,
                                ),
                                onPressed: () {
                                  AppFeedback.tap(context);
                                  ref
                                      .read(appSettingsProvider.notifier)
                                      .toggleFavorite(
                                        type: 'questions',
                                        id: q.id,
                                      );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(child: Text('common.error'.tr())),
                ),
                signsAsync.when(
                  data: (signs) {
                    final list = signs
                        .where((s) => favorites.signs.contains(s.id))
                        .toList();
                    if (list.isEmpty) {
                      return _EmptyFavoritesState(
                        icon: PhosphorIconsRegular.trafficSign,
                        message: 'common.empty'.tr(),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final sign = list[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : scheme.outline.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.04)
                                      : scheme.onSurface.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: SvgPicture.asset(
                                  'assets/${sign.svgPath}',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sign.titles[context.locale.languageCode] ??
                                          sign.titles['en'] ??
                                          '',
                                      style: AppFonts.outfit(
                                        context,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'signs.categories.${sign.category}'.tr(),
                                      style: AppFonts.outfit(
                                        context,
                                        fontSize: 12,
                                        color: scheme.onSurface
                                            .withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  PhosphorIconsFill.bookmarkSimple,
                                  color: ModernTheme.primary,
                                ),
                                onPressed: () {
                                  AppFeedback.tap(context);
                                  ref
                                      .read(appSettingsProvider.notifier)
                                      .toggleFavorite(
                                        type: 'signs',
                                        id: sign.id,
                                      );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(child: Text('common.error'.tr())),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyFavoritesState extends StatelessWidget {
  const _EmptyFavoritesState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E293B).withValues(alpha: 0.6)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : scheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: scheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppFonts.outfit(
                context,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
