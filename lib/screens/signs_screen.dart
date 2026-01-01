import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/sign.dart';
import '../state/data_state.dart';
import '../state/app_state.dart';
import '../widgets/bottom_nav.dart';

class SignsScreen extends ConsumerStatefulWidget {
  const SignsScreen({super.key});

  @override
  ConsumerState<SignsScreen> createState() => _SignsScreenState();
}

class _SignsScreenState extends ConsumerState<SignsScreen> {
  String query = '';
  String category = 'all';

  @override
  Widget build(BuildContext context) {
    final signsAsync = ref.watch(signsProvider);
    final locale = context.locale.languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('signs.title'.tr())),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'signs.search'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => query = value.toLowerCase()),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _CategoryChip(
                  label: 'signs.categories.all'.tr(),
                  selected: category == 'all',
                  onTap: () => setState(() => category = 'all'),
                ),
                _CategoryChip(
                  label: 'signs.categories.warning'.tr(),
                  selected: category == 'warning',
                  onTap: () => setState(() => category = 'warning'),
                ),
                _CategoryChip(
                  label: 'signs.categories.regulatory'.tr(),
                  selected: category == 'regulatory',
                  onTap: () => setState(() => category = 'regulatory'),
                ),
                _CategoryChip(
                  label: 'signs.categories.mandatory'.tr(),
                  selected: category == 'mandatory',
                  onTap: () => setState(() => category = 'mandatory'),
                ),
                _CategoryChip(
                  label: 'signs.categories.guide'.tr(),
                  selected: category == 'guide',
                  onTap: () => setState(() => category = 'guide'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: signsAsync.when(
              data: (signs) {
                final filtered = signs.where((s) {
                  final title = s.titles[locale] ?? s.titles['en'] ?? '';
                  final matchQuery = title.toLowerCase().contains(query);
                  final matchCategory = category == 'all' || s.category == category;
                  return matchQuery && matchCategory;
                }).toList();
                final width = MediaQuery.of(context).size.width;
                final columns = width >= 900 ? 4 : width >= 600 ? 3 : 2;
                final favorites = ref.watch(appSettingsProvider).favorites.signs;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final sign = filtered[idx];
                    final title = sign.titles[locale] ?? sign.titles['en'] ?? '';
                    return Card(
                      child: InkWell(
                        onTap: () => _showSignDetails(context, sign, title),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: SvgPicture.asset('assets/${sign.svgPath}', fit: BoxFit.contain),
                              ),
                              const SizedBox(height: 8),
                              Text(title, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                              IconButton(
                                onPressed: () {
                                  ref.read(appSettingsProvider.notifier).toggleFavorite(
                                        type: 'signs',
                                        id: sign.id,
                                      );
                                },
                                icon: Icon(
                                  favorites.contains(sign.id) ? Icons.bookmark : Icons.bookmark_border,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Failed to load')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}

void _showSignDetails(BuildContext context, AppSign sign, String title) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 140,
              child: SvgPicture.asset('assets/${sign.svgPath}', fit: BoxFit.contain),
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              'signs.categories.${sign.category}'.tr(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('common.close'.tr()),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
