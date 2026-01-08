import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'simple_screen.dart';

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
    final textTheme = Theme.of(context).textTheme;
    return SimpleScreen(
      title: 'support.title'.tr(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: scheme.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'support.disclaimer'.tr(),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'support.sectionTitle'.tr(),
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'support.bankLabel'.tr(),
            value: _bankName,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'support.accountNumberLabel'.tr(),
            value: _accountNumber,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'support.ibanLabel'.tr(),
            value: _iban,
          ),
          const SizedBox(height: 12),
          Text(
            _beneficiaryFallback,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _copyToClipboard(context, _iban),
                  child: Text(
                    '${'support.copy'.tr()} ${'support.ibanLabel'.tr()}',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _copyToClipboard(context, _accountNumber),
                  child: Text(
                    '${'support.copy'.tr()} ${'support.accountNumberLabel'.tr()}',
                  ),
                ),
              ),
            ],
          ),
        ],
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
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        SelectableText(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
