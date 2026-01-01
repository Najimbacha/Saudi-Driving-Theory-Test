import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/app_state.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('onboarding.title'.tr(), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text('onboarding.subtitle'.tr(), style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(appSettingsProvider.notifier).setHasSeenOnboarding(true);
                    context.go('/home');
                  },
                  child: Text('common.continue'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
