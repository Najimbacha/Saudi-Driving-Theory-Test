import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_state.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/banner_ad_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text('settings.language'.tr()),
            subtitle: Text(settings.languageCode),
            onTap: () async {
              final code = await showModalBottomSheet<String>(
                context: context,
                builder: (context) => _LanguageSheet(current: settings.languageCode),
              );
              if (!context.mounted) return;
              if (code != null) {
                notifier.setLanguage(code);
                context.setLocale(Locale(code));
              }
            },
          ),
          ListTile(
            title: Text('settings.theme'.tr()),
            subtitle: Text(settings.themeMode.name),
            onTap: () async {
              final mode = await showModalBottomSheet<ThemeMode>(
                context: context,
                builder: (context) => _ThemeSheet(current: settings.themeMode),
              );
              if (!context.mounted) return;
              if (mode != null) {
                notifier.setThemeMode(mode);
              }
            },
          ),
          SwitchListTile(
            value: settings.soundEnabled,
            onChanged: notifier.setSoundEnabled,
            title: Text('settings.sound'.tr()),
          ),
          SwitchListTile(
            value: settings.vibrationEnabled,
            onChanged: notifier.setVibrationEnabled,
            title: Text('settings.vibration'.tr()),
          ),
          const SizedBox(height: 12),
          const Center(child: BannerAdWidget()),
        ],
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    const codes = ['en', 'ar', 'ur', 'hi', 'bn'];
    return SafeArea(
      child: ListView(
        children: codes
            .map(
              (code) => ListTile(
                title: Text(code),
                trailing: current == code ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, code),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ThemeSheet extends StatelessWidget {
  const _ThemeSheet({required this.current});

  final ThemeMode current;

  @override
  Widget build(BuildContext context) {
    const modes = {
      ThemeMode.light: 'Light',
      ThemeMode.dark: 'Dark',
      ThemeMode.system: 'System',
    };
    return SafeArea(
      child: ListView(
        children: modes.entries
            .map(
              (entry) => ListTile(
                title: Text(entry.value),
                trailing: current == entry.key ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, entry.key),
              ),
            )
            .toList(),
      ),
    );
  }
}
