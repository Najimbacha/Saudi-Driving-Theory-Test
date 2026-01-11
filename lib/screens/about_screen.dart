import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../core/theme/modern_theme.dart';
import '../utils/app_fonts.dart';
import '../widgets/glass_container.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _developerName = 'Engr. Najim Bacha';
  static const String _email = 'najimbacha1@gmail.com';
  static const String _contact = '0537798312';
  static const String _instagram = '@najimbacha';
  static const String _linkedin =
      'https://www.linkedin.com/in/najimbacha/?locale=ar_AE';
  static const String _xHandle = '@najimbacha';

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
                    const SizedBox(height: 10),
                    Text(
                      'about.goal'.tr(),
                      style: AppFonts.outfit(
                        context,
                        color: scheme.onSurface.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'about.support'.tr(),
                      style: AppFonts.outfit(
                        context,
                        color: scheme.onSurface.withValues(alpha: 0.85),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: 'about.developerTitle'.tr()),
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
                    _InfoRow(
                      label: 'about.developerLabel'.tr(),
                      value: _developerName,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'about.emailLabel'.tr(),
                      value: _email,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'about.contactLabel'.tr(),
                      value: _contact,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: 'about.socialTitle'.tr()),
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
                    _InfoRow(
                      label: 'about.instagramLabel'.tr(),
                      value: _instagram,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'about.linkedinLabel'.tr(),
                      value: _linkedin,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'about.xLabel'.tr(),
                      value: _xHandle,
                    ),
                  ],
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.outfit(
            context,
            fontSize: 12,
            color: scheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        SelectableText(
          value,
          style: AppFonts.outfit(
            context,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
