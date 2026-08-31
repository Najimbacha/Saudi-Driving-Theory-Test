import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/modern_theme.dart';
import '../../data/models/handbook_model.dart';
import '../../presentation/providers/handbook_progress_provider.dart';
import '../../utils/app_feedback.dart';
import '../../utils/app_fonts.dart';

class HandbookTopicScreen extends StatelessWidget {
  const HandbookTopicScreen({super.key, required this.unit});

  final HandbookUnit unit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'learn.unitLabel'.tr(namedArgs: {'id': unit.unitId.toString()}),
          style: AppFonts.outfit(context,
              fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              // Hero Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.primary, scheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'learn.topicsCount'.tr(namedArgs: {'count': unit.topics.length.toString()}),
                        style: AppFonts.outfit(context,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      unit.title,
                      style: AppFonts.outfit(context,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                'learn.topicsHeader'.tr(),
                style: AppFonts.outfit(context,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface),
              ),
              const SizedBox(height: 16),

              ...List.generate(unit.topics.length, (index) {
                final topic = unit.topics[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _TopicCard(topic: topic, index: index, totalTopics: unit.topics.length),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends ConsumerWidget {
  const _TopicCard({required this.topic, required this.index, required this.totalTopics});

  final HandbookTopic topic;
  final int index;
  final int totalTopics;

  // Rough estimation: 1 min per subtopic or extraData section
  int get _estimatedReadingTimeMinutes {
    int sections = topic.subtopics.length + (topic.extraData.isNotEmpty ? 1 : 0);
    return sections < 1 ? 1 : sections * 2;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final isRead = ref.watch(handbookProgressProvider).contains(topic.topicId);

    return InkWell(
      onTap: () {
        AppFeedback.tap(context);
        // Navigate to Subtopics
        context.push('/learn/subtopic', extra: topic);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.onSurface.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isRead 
                    ? scheme.primary 
                    : scheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: isRead 
                  ? Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), size: 16, color: scheme.onPrimary)
                  : Text(
                      '${index + 1}',
                      style: AppFonts.outfit(context,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: scheme.primary),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: AppFonts.outfit(context,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        color: scheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(PhosphorIcons.clock(), size: 14, color: scheme.primary.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Text(
                        'learn.readTime'.tr(namedArgs: {'min': _estimatedReadingTimeMinutes.toString()}),
                        style: AppFonts.outfit(context,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: scheme.primary.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(width: 12),
                      Icon(PhosphorIcons.books(), size: 14, color: scheme.secondary.withValues(alpha: 0.8)),
                      const SizedBox(width: 4),
                      Text(
                        'learn.sectionsCount'.tr(namedArgs: {'count': topic.subtopics.length.toString()}),
                        style: AppFonts.outfit(context,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: scheme.secondary.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (index + 1) / totalTopics,
                      minHeight: 3,
                      backgroundColor: scheme.onSurface.withValues(alpha: 0.06),
                      valueColor: AlwaysStoppedAnimation<Color>(scheme.primary.withValues(alpha: 0.4)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: scheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}