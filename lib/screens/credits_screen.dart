import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../data/sign_attributions.dart';
import 'simple_screen.dart';

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
    return SimpleScreen(
      title: 'credits.title'.tr(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'credits.signsTitle'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text('credits.signsLine1'.tr()),
          const SizedBox(height: 8),
          Text('credits.signsLine2'.tr()),
          const SizedBox(height: 8),
          Text('credits.signsLine3'.tr()),
          const SizedBox(height: 12),
          Text(
            'credits.sourceLabel'.tr(),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Text('credits.sourceName'.tr()),
          const SizedBox(height: 6),
          SelectableText(
            sourceUrl,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Text(
            'credits.filesTitle'.tr(),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Text('credits.filesLine1'.tr()),
          const SizedBox(height: 12),
          ...kKsaSignFileNames.map(
            (fileName) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SelectableText(
                '$fileName\n${_wikiUrlForFile(fileName)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'credits.disclaimerLabel'.tr(),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Text('credits.disclaimerBody'.tr()),
        ],
      ),
    );
  }
}
