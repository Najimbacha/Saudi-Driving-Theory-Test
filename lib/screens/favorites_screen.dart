import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_state.dart';
import '../state/data_state.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(appSettingsProvider).favorites;
    final questionsAsync = ref.watch(questionsProvider);
    final signsAsync = ref.watch(signsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('favorites.title'.tr()),
          bottom: TabBar(
            tabs: [
              Tab(text: 'practice.byCategory'.tr()),
              Tab(text: 'signs.title'.tr()),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            questionsAsync.when(
              data: (questions) {
                final list = questions
                    .where((q) => favorites.questions.contains(q.id))
                    .toList();
                if (list.isEmpty) {
                  return Center(child: Text('common.empty'.tr()));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final q = list[index];
                    return Card(
                      child: ListTile(
                        title: Text(q.questionKey.tr()),
                        subtitle: Text(q.categoryKey.tr()),
                        trailing: IconButton(
                          icon: const Icon(Icons.bookmark),
                          onPressed: () {
                            ref
                                .read(appSettingsProvider.notifier)
                                .toggleFavorite(
                                  type: 'questions',
                                  id: q.id,
                                );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(child: Text('common.error'.tr())),
            ),
            signsAsync.when(
              data: (signs) {
                final list =
                    signs.where((s) => favorites.signs.contains(s.id)).toList();
                if (list.isEmpty) {
                  return Center(child: Text('common.empty'.tr()));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final sign = list[index];
                    return Card(
                      child: ListTile(
                        title: Text(sign.titles[context.locale.languageCode] ??
                            sign.titles['en'] ??
                            ''),
                        subtitle: Text(sign.category),
                        trailing: IconButton(
                          icon: const Icon(Icons.bookmark),
                          onPressed: () {
                            ref
                                .read(appSettingsProvider.notifier)
                                .toggleFavorite(
                                  type: 'signs',
                                  id: sign.id,
                                );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(child: Text('common.error'.tr())),
            ),
          ],
        ),
      ),
    );
  }
}
