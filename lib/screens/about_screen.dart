import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/modern_theme.dart';
import '../utils/app_fonts.dart';
import '../widgets/glass_container.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static final Uri _moiUrl = Uri.parse('https://www.moi.gov.sa');
  static final Uri _absherUrl = Uri.parse('https://www.absher.sa');

  static Future<void> _openLink(BuildContext context, Uri url) async {
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('common.error'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'about.title'.tr(),
          style: AppFonts.outfit(
            context,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              GlassContainer(
                padding: const EdgeInsets.all(18),
                blur: isDark ? 10 : 6,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.9),
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: 0.08),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'about.description1'.tr(),
                      style: AppFonts.outfit(
                        context,
                        color: scheme.onSurface,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'about.description2'.tr(),
                      style: AppFonts.outfit(
                        context,
                        color: scheme.onSurface,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: 'about.referencesTitle'.tr()),
              const SizedBox(height: 10),
              GlassContainer(
                padding: const EdgeInsets.all(18),
                blur: isDark ? 10 : 6,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white.withValues(alpha: 0.92),
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: 0.08),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LinkRow(
                      text: 'about.source1'.tr(),
                      url: _moiUrl,
                    ),
                    const SizedBox(height: 10),
                    _LinkRow(
                      text: 'about.source2'.tr(),
                      url: _absherUrl,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: 'about.featuresTitle'.tr()),
              const SizedBox(height: 10),
              GlassContainer(
                padding: const EdgeInsets.all(18),
                blur: isDark ? 10 : 6,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white.withValues(alpha: 0.92),
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: 0.08),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BulletRow(text: 'about.feature1'.tr()),
                    const SizedBox(height: 10),
                    _BulletRow(text: 'about.feature2'.tr()),
                    const SizedBox(height: 10),
                    _BulletRow(text: 'about.feature3'.tr()),
                    const SizedBox(height: 10),
                    _BulletRow(text: 'about.feature4'.tr()),
                    const SizedBox(height: 10),
                    _BulletRow(text: 'about.feature5'.tr()),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: 'about.disclaimerTitle'.tr()),
              const SizedBox(height: 10),
              GlassContainer(
                padding: const EdgeInsets.all(18),
                blur: isDark ? 10 : 6,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.9),
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: 0.08),
                ),
                child: Text(
                  'about.disclaimerBody'.tr(),
                  style: AppFonts.outfit(
                    context,
                    color: scheme.onSurface.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.5,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: AppFonts.outfit(
        context,
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: scheme.onSurface,
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyle = AppFonts.outfit(
      context,
      color: scheme.onSurface.withValues(alpha: 0.9),
      fontSize: 13,
      height: 1.5,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('•', style: textStyle),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: textStyle)),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.text, required this.url});

  final String text;
  final Uri url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => AboutScreen._openLink(context, url),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.onSurface.withValues(alpha: 0.08)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.public,
              size: 16,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: AppFonts.outfit(
                  context,
                  color: scheme.onSurface.withValues(alpha: 0.9),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.open_in_new_rounded,
              size: 14,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
