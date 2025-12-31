import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/banner_ad_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
            Text('home.title'.tr(), style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('home.hero.title'.tr(), style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _pill(context, 'home.hero.offline'),
                        _pill(context, 'home.hero.noLogin'),
                        _pill(context, 'home.hero.noInternet'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.go('/practice'),
                            child: Text('home.hero.startPractice'.tr()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.go('/exam'),
                            child: Text('home.hero.startExam'.tr()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('home.roadKnowledge'.tr(), style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _roadCard(context, 'home.cards.signs', () => context.go('/signs'))),
                const SizedBox(width: 12),
                Expanded(child: _roadCard(context, 'home.cards.violationPoints', () => context.go('/violation-points'))),
              ],
            ),
            const SizedBox(height: 12),
            _roadCard(context, 'home.cards.generalRules', () => context.go('/learn')),
            const SizedBox(height: 16),
            const Center(child: BannerAdWidget()),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNav(),
      ),
    );
  }

  Widget _pill(BuildContext context, String key) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(key.tr(), style: Theme.of(context).textTheme.bodySmall),
    );
  }

  Widget _roadCard(BuildContext context, String key, VoidCallback onTap) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(key.tr(), textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
