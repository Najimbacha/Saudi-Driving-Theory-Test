import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../state/app_state.dart';
import '../widgets/banner_ad_widget.dart';
import '../core/theme/modern_theme.dart';
import '../utils/app_feedback.dart';
import '../utils/app_fonts.dart';
import '../widgets/glass_container.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static String _getThemeName(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'settings.themes.light'.tr();
      case ThemeMode.dark:
        return 'settings.themes.dark'.tr();
      case ThemeMode.system:
        return 'settings.themes.system'.tr();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('settings.title'.tr(),
            style: AppFonts.outfit(context,
                fontWeight: FontWeight.bold, color: scheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            cacheExtent: 600,
            children: [
              _SectionHeader(title: 'settings.sections.general'.tr()),
              _SettingsGlassTile(
                title: 'settings.language'.tr(),
                subtitle:
                    'settings.languages.${context.locale.languageCode}'.tr(),
                icon: PhosphorIconsRegular.translate,
                iconColor: Colors.blueAccent,
                onTap: () {
                  showModalBottomSheet<String>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => _LanguageGlassSheet(
                        current: context.locale.languageCode),
                  );
                },
              ),
              const SizedBox(height: 12),
              _SettingsGlassTile(
                title: 'settings.theme'.tr(),
                subtitle: _getThemeName(context, settings.themeMode),
                icon: PhosphorIconsRegular.palette,
                iconColor: Colors.purpleAccent,
                onTap: () async {
                  final mode = await showModalBottomSheet<ThemeMode>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        _ThemeGlassSheet(current: settings.themeMode),
                  );
                  if (!context.mounted) return;
                  if (mode != null) {
                    notifier.setThemeMode(mode);
                  }
                },
              ),
              const SizedBox(height: 24),
              GlassContainer(
                padding: const EdgeInsets.symmetric(vertical: 10),
                blur: isDark ? 10 : 6,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white.withValues(alpha: 0.9),
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: 0.08),
                ),
                child: const Center(child: BannerAdWidget(forceVisible: true)),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/support-development'),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.onSurface.withValues(alpha: 0.45),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    textStyle: AppFonts.outfit(
                      context,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: Text('support.title'.tr()),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/about'),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.onSurface.withValues(alpha: 0.45),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    textStyle: AppFonts.outfit(
                      context,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: Text('about.title'.tr()),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/credits'),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.onSurface.withValues(alpha: 0.45),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    textStyle: AppFonts.outfit(
                      context,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: Text('settings.links.creditsTitle'.tr()),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'settings.versionLabel'.tr(namedArgs: {'version': '1.0.0'}),
                  style: AppFonts.outfit(
                    context,
                    color: scheme.onSurface.withValues(alpha: 0.25),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppFonts.outfit(
          context,
          color: scheme.onSurface.withValues(alpha: 0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsGlassTile extends StatelessWidget {
  const _SettingsGlassTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
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
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        blur: isDark ? 10 : 6,
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.92),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: 0.08),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.18 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
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
                      color: scheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppFonts.outfit(
                      context,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              PhosphorIconsRegular.caretRight,
              color: scheme.onSurface.withValues(alpha: 0.35),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageGlassSheet extends StatelessWidget {
  const _LanguageGlassSheet({required this.current});
  final String current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const codes = ['en', 'ar', 'ur', 'hi', 'bn'];

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : scheme.outline.withValues(alpha: 0.12),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'settings.language'.tr(),
                style: AppFonts.outfit(
                  context,
                  color: scheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              ...codes.map((code) {
                final isSelected = current == code;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () async {
                      AppFeedback.confirm(context);
                      await context.setLocale(Locale(code));
                      if (context.mounted) Navigator.pop(context, code);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ModernTheme.primary.withValues(alpha: 0.12)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : scheme.surface),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? ModernTheme.primary
                              : scheme.outline.withValues(alpha: 0.1),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'settings.languages.$code'.tr(),
                            style: AppFonts.outfit(
                              context,
                              color: isSelected
                                  ? ModernTheme.primary
                                  : scheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(
                              PhosphorIconsFill.checkCircle,
                              color: ModernTheme.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeGlassSheet extends StatelessWidget {
  const _ThemeGlassSheet({required this.current});
  final ThemeMode current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const modes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : scheme.outline.withValues(alpha: 0.12),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'settings.theme'.tr(),
                style: AppFonts.outfit(
                  context,
                  color: scheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              ...modes.map((mode) {
                final isSelected = current == mode;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      AppFeedback.tap(context);
                      Navigator.pop(context, mode);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ModernTheme.primary.withValues(alpha: 0.12)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : scheme.surface),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? ModernTheme.primary
                              : scheme.outline.withValues(alpha: 0.1),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _getThemeName(context, mode),
                            style: AppFonts.outfit(
                              context,
                              color: isSelected
                                  ? ModernTheme.primary
                                  : scheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(
                              PhosphorIconsFill.checkCircle,
                              color: ModernTheme.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeName(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'settings.themes.light'.tr();
      case ThemeMode.dark:
        return 'settings.themes.dark'.tr();
      case ThemeMode.system:
        return 'settings.themes.system'.tr();
    }
  }
}
