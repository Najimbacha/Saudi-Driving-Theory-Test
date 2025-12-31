import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../state/data_state.dart';
import '../widgets/bottom_nav.dart';

class SignsScreen extends ConsumerStatefulWidget {
  const SignsScreen({super.key});

  @override
  ConsumerState<SignsScreen> createState() => _SignsScreenState();
}

class _SignsScreenState extends ConsumerState<SignsScreen> {
  String query = '';

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
          Expanded(
            child: signsAsync.when(
              data: (signs) {
                final filtered = signs.where((s) {
                  final title = s.titles[locale] ?? s.titles['en'] ?? '';
                  return title.toLowerCase().contains(query);
                }).toList();
                final width = MediaQuery.of(context).size.width;
                final columns = width >= 900 ? 4 : width >= 600 ? 3 : 2;
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
                        onTap: () {},
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
