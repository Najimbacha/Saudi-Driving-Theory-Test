import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../utils/app_fonts.dart';

/// Renders arbitrary handbook JSON content (strings, lists, maps, numbers)
/// as semantically-colored cards with icons.
class SmartContentRenderer extends StatelessWidget {
  const SmartContentRenderer({super.key, required this.content, this.isNested = false});
  final Map<String, dynamic> content;
  final bool isNested;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content.entries.map((entry) {
        return Padding(
          padding: EdgeInsets.only(bottom: isNested ? 16 : 28),
          child: _buildSmartWidget(context, entry.key, entry.value),
        );
      }).toList(),
    );
  }

  // Standalone section header — sits above content, not inside a card
  Widget _sectionHeader(BuildContext context, String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppFonts.outfit(context,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                  color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartWidget(BuildContext context, String key, dynamic value) {
    final scheme = Theme.of(context).colorScheme;
    final lowerKey = key.toLowerCase();

    // 0. Try to localize the key first
    String translationKey = 'learn.keys.$key';
    String localizedKey = translationKey.tr();

    String formattedKey = (localizedKey == translationKey)
        ? key.replaceAll('_', ' ')
            .split(' ')
            .map((word) => word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1)}'
                : '')
            .join(' ')
        : localizedKey;

    // 1. Semantic Block Matching
    bool isWarningOrPenalty = lowerKey.contains('penalty') ||
        lowerKey.contains('prohibited') ||
        lowerKey.contains('danger') ||
        lowerKey.contains('warning') ||
        lowerKey.contains('offense');

    bool isRuleOrReq = lowerKey.contains('rule') ||
        lowerKey.contains('requirement') ||
        lowerKey.contains('must') ||
        lowerKey.contains('mandatory') ||
        lowerKey.contains('step');

    bool isDefinitionOrInfo = lowerKey.contains('definition') ||
        lowerKey.contains('info') ||
        lowerKey.contains('note') ||
        lowerKey.contains('important') ||
        lowerKey.contains('fact');

    // Semantic colors
    Color accentColor = scheme.primary;
    IconData semanticIcon = PhosphorIconsFill.info;

    if (isWarningOrPenalty) {
      accentColor = Colors.red.shade600;
      semanticIcon = PhosphorIconsFill.warning;
    } else if (isRuleOrReq) {
      accentColor = Colors.green.shade600;
      semanticIcon = PhosphorIconsFill.checkCircle;
    } else if (isDefinitionOrInfo) {
      accentColor = Colors.blue.shade600;
      semanticIcon = PhosphorIconsFill.info;
    }

    // ── String value: left accent bar + body text ──
    if (value is String) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(context, formattedKey, semanticIcon, accentColor),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: BorderDirectional(
                start: BorderSide(color: accentColor, width: 3),
              ),
              color: accentColor.withValues(alpha: 0.04),
              borderRadius: const BorderRadiusDirectional.only(
                topEnd: Radius.circular(12),
                bottomEnd: Radius.circular(12),
              ),
            ),
            child: Text(
              value,
              style: AppFonts.outfit(context,
                  fontSize: 16,
                  height: 1.75,
                  color: scheme.onSurface.withValues(alpha: 0.88)),
            ),
          ),
        ],
      );

    // ── Numeric / bool: inline key-value ──
    } else if (value is int || value is double || value is bool) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Icon(PhosphorIconsFill.caretDoubleRight, color: scheme.primary, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: '$formattedKey: ',
                  style: AppFonts.outfit(context,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface.withValues(alpha: 0.65)),
                  children: [
                    TextSpan(
                      text: value.toString(),
                      style: AppFonts.outfit(context,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: scheme.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

    // ── List: clean bullet list ──
    } else if (value is List) {
      if (value.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(context, formattedKey, semanticIcon, accentColor),
          ...value.asMap().entries.map((entry) {
            final item = entry.value;

            if (item is Map<String, dynamic>) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.onSurface.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.onSurface.withValues(alpha: 0.06)),
                  ),
                  child: SmartContentRenderer(content: item, isNested: true),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 6, end: 12),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isWarningOrPenalty
                            ? accentColor.withValues(alpha: 0.7)
                            : accentColor.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.toString(),
                      style: AppFonts.outfit(context,
                          fontSize: 16,
                          height: 1.7,
                          color: scheme.onSurface.withValues(alpha: 0.88)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );

    // ── Map: indented block with left accent ──
    } else if (value is Map<String, dynamic>) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(context, formattedKey, semanticIcon, accentColor),
          Container(
            padding: const EdgeInsetsDirectional.only(start: 14, top: 4, bottom: 4),
            decoration: BoxDecoration(
              border: BorderDirectional(
                start: BorderSide(
                  color: accentColor.withValues(alpha: 0.25),
                  width: 3,
                ),
              ),
            ),
            child: SmartContentRenderer(content: value, isNested: true),
          ),
        ],
      );
    }

    return Text('$formattedKey: $value');
  }
}
