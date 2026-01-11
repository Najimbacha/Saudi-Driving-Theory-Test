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
                    textStyle: AppFonts.outfit(context,
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
                    textStyle: AppFonts.outfit(context,
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
                    textStyle: AppFonts.outfit(context,
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
                  style: AppFonts.outfit(context,
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
        style: AppFonts.outfit(context,
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
                    style: AppFonts.outfit(context,
                      color: scheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppFonts.outfit(context,
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
    const codes = ['en', 'ar', 'ur', 'hi', 'bn'];
    return GlassContainer(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      color: const Color(0xFF0F172A).withValues(alpha: 0.95),
      padding: const EdgeInsets.all(24),
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
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text('settings.language'.tr(),
                  style: AppFonts.outfit(context,
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ...codes.map((code) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () async {
                        AppFeedback.confirm(context);
                        await context.setLocale(Locale(code));
                        if (context.mounted) Navigator.pop(context, code);
                      },
                      child: GlassContainer(
                        color: current == code
                            ? ModernTheme.secondary.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        border: Border.all(
                            color: current == code
                                ? ModernTheme.secondary
                                : Colors.white10),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              'settings.languages.$code'.tr(),
                              style: AppFonts.outfit(context,
                                  color: Colors.white,
                                  fontWeight: current == code
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                            const Spacer(),
                            if (current == code)
                              const Icon(PhosphorIconsRegular.checkCircle,
                                  color: ModernTheme.secondary),
                          ],
                        ),
                      ),
                    ),
                  )),
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
    const modes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
    return GlassContainer(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      color: const Color(0xFF0F172A).withValues(alpha: 0.95),
      padding: const EdgeInsets.all(24),
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
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text('settings.theme'.tr(),
                  style: AppFonts.outfit(context,
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ...modes.map((mode) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        AppFeedback.tap(context);
                        Navigator.pop(context, mode);
                      },
                      child: GlassContainer(
                        color: current == mode
                            ? ModernTheme.primary.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        border: Border.all(
                            color: current == mode
                                ? ModernTheme.primary
                                : Colors.white10),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              _getThemeName(context, mode),
                              style: AppFonts.outfit(context,
                                  color: Colors.white,
                                  fontWeight: current == mode
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                            const Spacer(),
                            if (current == mode)
                              const Icon(PhosphorIconsRegular.checkCircle,
                                  color: ModernTheme.primary),
                          ],
                        ),
                      ),
                    ),
                  )),
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


