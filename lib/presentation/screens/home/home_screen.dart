import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _HeroHeader(),
            const SizedBox(height: 20),
            Text('home.roadKnowledge.title'.tr(),
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ActionCard(
                  title: 'home.practiceByCategory'.tr(),
                  subtitle: 'home.practiceByCategoryDesc'.tr(),
                  icon: Icons.grid_view_outlined,
                  color: AppColors.primary,
                  onTap: () => context.go('/categories'),
                ),
                _ActionCard(
                  title: 'home.practice'.tr(),
                  subtitle: 'home.practiceDesc'.tr(),
                  icon: Icons.flash_on_outlined,
                  color: AppColors.accent,
                  onTap: () => context.go('/practice'),
                ),
                _ActionCard(
                  title: 'home.mockExam'.tr(),
                  subtitle: 'home.mockExamDesc'.tr(),
                  icon: Icons.assignment_outlined,
                  color: AppColors.primary,
                  onTap: () => context.go('/exam'),
                ),
                _ActionCard(
                  title: 'home.learnSigns'.tr(),
                  subtitle: 'home.learnSignsDesc'.tr(),
                  icon: Icons.traffic_outlined,
                  color: AppColors.secondary,
                  onTap: () => context.go('/signs'),
                ),
                _ActionCard(
                  title: 'home.stats'.tr(),
                  subtitle: 'home.statsDesc'.tr(),
                  icon: Icons.bar_chart_outlined,
                  color: AppColors.success,
                  onTap: () => context.go('/stats'),
                ),
                _ActionCard(
                  title: 'home.history'.tr(),
                  subtitle: 'home.historyDesc'.tr(),
                  icon: Icons.history_outlined,
                  color: AppColors.primary,
                  onTap: () => context.go('/history'),
                ),
                _ActionCard(
                  title: 'home.violationPoints'.tr(),
                  subtitle: 'home.violationPointsDesc'.tr(),
                  icon: Icons.warning_amber_outlined,
                  color: AppColors.error,
                  onTap: () => context.go('/violation-points'),
                ),
                _ActionCard(
                  title: 'home.trafficFines'.tr(),
                  subtitle: 'home.trafficFinesDesc'.tr(),
                  icon: Icons.receipt_long_outlined,
                  color: AppColors.accent,
                  onTap: () => context.go('/traffic-fines'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home.greeting'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'home.subtitle'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TagChip(labelKey: 'home.badges.offline'),
              _TagChip(labelKey: 'home.badges.noLogin'),
              _TagChip(labelKey: 'home.badges.noInternet'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.labelKey});

  final String labelKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        labelKey.tr(),
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.white),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const Spacer(),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
