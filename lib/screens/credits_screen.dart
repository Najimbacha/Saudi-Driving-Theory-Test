import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../data/sign_attributions.dart';
import '../core/theme/modern_theme.dart';
import '../utils/app_fonts.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  String _wikiUrlForFile(String fileName) {
    final encodedName = Uri.encodeComponent(fileName);
    return '$kWikimediaFileBaseUrl$encodedName';
  }

  @override
  Widget build(BuildContext context) {
    const sourceUrl =
        'https://commons.wikimedia.org/w/index.php?search=File%3ASaudi+Arabia+-+Road+Sign&title=Special%3AMediaSearch&type=image';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('credits.title'.tr(),
            style: AppFonts.outfit(context,
                fontWeight: FontWeight.bold, color: scheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              Text(
                'credits.signsTitle'.tr(),
                style: AppFonts.outfit(context,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: scheme.primary),
              ),
              const SizedBox(height: 12),
              Text('credits.signsLine1'.tr(),
                  style: AppFonts.outfit(context, fontSize: 14)),
              const SizedBox(height: 8),
              Text('credits.signsLine2'.tr(),
                  style: AppFonts.outfit(context, fontSize: 14)),
              const SizedBox(height: 8),
              Text('credits.signsLine3'.tr(),
                  style: AppFonts.outfit(context, fontSize: 14)),
              const SizedBox(height: 24),
              Text(
                'credits.sourceLabel'.tr(),
                style: AppFonts.outfit(context,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface),
              ),
              const SizedBox(height: 6),
              Text('credits.sourceName'.tr(),
                  style: AppFonts.outfit(context, fontSize: 14)),
              const SizedBox(height: 6),
              SelectableText(
                sourceUrl,
                style: AppFonts.outfit(context,
                    fontSize: 12, color: scheme.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'credits.filesTitle'.tr(),
                style: AppFonts.outfit(context,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text('credits.filesLine1'.tr(),
                  style: AppFonts.outfit(context, fontSize: 14)),
              const SizedBox(height: 12),
              ...kKsaSignFileNames.map(
                (fileName) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fileName,
                          style: AppFonts.outfit(context,
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      SelectableText(
                        _wikiUrlForFile(fileName),
                        style: AppFonts.outfit(context,
                            fontSize: 11,
                            color: scheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.primary.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'credits.disclaimerLabel'.tr(),
                      style: AppFonts.outfit(context,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: scheme.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'credits.disclaimerBody'.tr(),
                      style: AppFonts.outfit(context,
                          fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
