import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/ad_service.dart';
import '../state/app_state.dart';
import '../widgets/banner_ad_widget.dart';
import '../core/theme/modern_theme.dart';
import '../widgets/glass_container.dart';
import '../core/constants/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static String _getThemeName(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'settings.themes.light'.tr();
      case ThemeMode.dark: return 'settings.themes.dark'.tr();
      case ThemeMode.system: return 'settings.themes.system'.tr();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('settings.title'.tr(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              _SectionHeader(title: 'General'),
              _SettingsGlassTile(
                title: 'settings.language'.tr(),
                subtitle: 'settings.languages.${context.locale.languageCode}'.tr(),
                icon: Icons.language_rounded,
                iconColor: Colors.blueAccent,
                onTap: () {
                   showModalBottomSheet<String>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => _LanguageGlassSheet(current: context.locale.languageCode),
                  );
                },
              ),
              const SizedBox(height: 12),
              _SettingsGlassTile(
                title: 'settings.theme'.tr(),
                subtitle: _getThemeName(context, settings.themeMode),
                icon: Icons.brightness_6_rounded,
                iconColor: Colors.purpleAccent,
                onTap: () async {
                  final mode = await showModalBottomSheet<ThemeMode>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => _ThemeGlassSheet(current: settings.themeMode),
                  );
                  if (!context.mounted) return;
                  if (mode != null) {
                    notifier.setThemeMode(mode);
                  }
                },
              ),
              
              const SizedBox(height: 24),
              _SectionHeader(title: 'Preferences'),
              
              _SettingsSwitchTile(
                title: 'settings.sound'.tr(),
                icon: Icons.volume_up_rounded,
                iconColor: Colors.tealAccent,
                value: settings.soundEnabled,
                onChanged: notifier.setSoundEnabled,
              ),
              const SizedBox(height: 12),
              _SettingsSwitchTile(
                title: 'settings.vibration'.tr(),
                icon: Icons.vibration_rounded,
                iconColor: Colors.orangeAccent,
                value: settings.vibrationEnabled,
                onChanged: notifier.setVibrationEnabled,
              ),
              const SizedBox(height: 12),
              _SettingsSwitchTile(
                title: 'settings.ads'.tr(),
                subtitle: 'settings.adsDesc'.tr(),
                icon: Icons.ad_units_rounded,
                iconColor: Colors.greenAccent,
                value: settings.adsEnabled,
                onChanged: (value) async {
                  if (value) {
                    await AdService.instance.init();
                  }
                  notifier.setAdsEnabled(value);
                },
              ),

              const SizedBox(height: 24),
              if (settings.adsEnabled) 
                const Center(child: BannerAdWidget()),
                
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: GoogleFonts.outfit(color: Colors.white24, fontSize: 12),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          color: Colors.white54,
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
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
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
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
                   style: GoogleFonts.outfit(
                     color: Colors.white,
                     fontSize: 16,
                     fontWeight: FontWeight.w500,
                   ),
                 ),
                 if (subtitle != null)
                   Padding(
                     padding: const EdgeInsets.only(top: 4),
                     child: Text(
                       subtitle!,
                       style: GoogleFonts.outfit(
                         color: Colors.white54,
                         fontSize: 12,
                       ),
                     ),
                   ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              onChanged(v);
            },
            activeColor: ModernTheme.secondary,
            activeTrackColor: ModernTheme.secondary.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white10,
          ),
        ],
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('settings.language'.tr(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ...codes.map((code) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  await context.setLocale(Locale(code));
                  if (context.mounted) Navigator.pop(context, code);
                },
                child: GlassContainer(
                  color: current == code ? ModernTheme.secondary.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                  border: Border.all(color: current == code ? ModernTheme.secondary : Colors.white10),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                       Text(
                         'settings.languages.$code'.tr(),
                         style: GoogleFonts.outfit(
                           color: Colors.white, 
                           fontWeight: current == code ? FontWeight.bold : FontWeight.normal
                         ),
                       ),
                       const Spacer(),
                       if (current == code) Icon(Icons.check_circle_rounded, color: ModernTheme.secondary),
                    ],
                  ),
                ),
              ),
            )),
          ],
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('settings.theme'.tr(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ...modes.map((mode) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context, mode);
                },
                child: GlassContainer(
                  color: current == mode ? ModernTheme.primary.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                  border: Border.all(color: current == mode ? ModernTheme.primary : Colors.white10),
                   padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                       Text(
                         _getThemeName(context, mode),
                         style: GoogleFonts.outfit(
                           color: Colors.white, 
                           fontWeight: current == mode ? FontWeight.bold : FontWeight.normal
                         ),
                       ),
                       const Spacer(),
                       if (current == mode) Icon(Icons.check_circle_rounded, color: ModernTheme.primary),
                    ],
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  String _getThemeName(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'settings.themes.light'.tr();
      case ThemeMode.dark: return 'settings.themes.dark'.tr();
      case ThemeMode.system: return 'settings.themes.system'.tr();
    }
  }
}
