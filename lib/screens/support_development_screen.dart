import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/modern_theme.dart';
import '../utils/app_fonts.dart';
import '../widgets/glass_container.dart';

class SupportDevelopmentScreen extends StatelessWidget {
  const SupportDevelopmentScreen({super.key});

  static const String _bankName = 'Al Rajhi Bank';
  static const String _accountNumber = '640000010006083141383';
  static const String _iban = 'SA23 8000 0640 6080 1314 1383';
  static const String _beneficiaryFallback = 'Beneficiary: (add later)';

  void _copyToClipboard(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('support.copied'.tr())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'support.title'.tr(),
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              GlassContainer(
                padding: const EdgeInsets.all(16),
                blur: isDark ? 10 : 6,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.9),
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: 0.08),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: scheme.secondary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: scheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'support.disclaimer'.tr(),
                        style: AppFonts.outfit(
                          context,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'support.sectionTitle'.tr(),
                style: AppFonts.outfit(
                  context,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              GlassContainer(
                padding: const EdgeInsets.all(18),
                blur: isDark ? 10 : 6,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white.withValues(alpha: 0.9),
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: 0.08),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      label: 'support.bankLabel'.tr(),
                      value: _bankName,
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(
                      label: 'support.accountNumberLabel'.tr(),
                      value: _accountNumber,
                      useMono: true,
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(
                      label: 'support.ibanLabel'.tr(),
                      value: _iban,
                      useMono: true,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _beneficiaryFallback,
                      style: AppFonts.outfit(
                        context,
                        fontSize: 12,
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(context, _iban),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(
                    '${'support.copy'.tr()} ${'support.ibanLabel'.tr()}',
                    style: AppFonts.outfit(
                      context,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ModernTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _copyToClipboard(context, _accountNumber),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(
                    '${'support.copy'.tr()} ${'support.accountNumberLabel'.tr()}',
                    style: AppFonts.outfit(
                      context,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.onSurface,
                    side: BorderSide(
                      color: scheme.onSurface.withValues(alpha: 0.2),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.useMono = false,
  });

  final String label;
  final String value;
  final bool useMono;

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
            letterSpacing: useMono ? 0.3 : 0,
          ),
        ),
      ],
    );
  }
}
