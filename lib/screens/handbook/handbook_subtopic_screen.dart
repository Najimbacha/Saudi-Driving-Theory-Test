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
import '../../widgets/smart_content_renderer.dart';

class HandbookSubtopicScreen extends ConsumerWidget {
  const HandbookSubtopicScreen({super.key, required this.topic});

  final HandbookTopic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final isRead = ref.watch(handbookProgressProvider).contains(topic.topicId);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'learn.title'.tr(),
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
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'learn.topicLabel'.tr(namedArgs: {'id': topic.topicId.toString()}),
                        style: AppFonts.outfit(context,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: scheme.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      topic.title,
                      style: AppFonts.outfit(context,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                          color: scheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              if (topic.extraData.isNotEmpty) ...[
                SmartContentRenderer(content: topic.extraData),
                const SizedBox(height: 32),
              ],

              // Iterate subtopics
              ...topic.subtopics.asMap().entries.map((entry) {
                final idx = entry.key;
                final subtopic = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Divider between subtopics (not before first)
                      if (idx > 0 || topic.extraData.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: Row(
                            children: [
                              Expanded(child: Divider(color: scheme.onSurface.withValues(alpha: 0.08), thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Icon(PhosphorIcons.dotsThree(), size: 20, color: scheme.onSurface.withValues(alpha: 0.2)),
                              ),
                              Expanded(child: Divider(color: scheme.onSurface.withValues(alpha: 0.08), thickness: 1)),
                            ],
                          ),
                        ),
                      // Subtopic header with accent badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: scheme.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${idx + 1}',
                                style: AppFonts.outfit(context,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: scheme.secondary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                subtopic.title,
                                style: AppFonts.outfit(context,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    height: 1.3,
                                    color: scheme.onSurface),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SmartContentRenderer(content: subtopic.contentData),
                    ],
                  ),
                );
              }),

              // Deep links to interactive features
              if (topic.topicId == '1.5' ||
                  topic.topicId == '1.6' ||
                  topic.topicId == '4.4') ...[
                const SizedBox(height: 8),
                Text(
                  'learn.interactiveTools'.tr(),
                  style: AppFonts.outfit(context,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface),
                ),
                const SizedBox(height: 16),
                _InteractiveFeatureLink(topicId: topic.topicId),
                const SizedBox(height: 32),
              ],

              // Mark as Read / Done button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppFeedback.tap(context);
                    ref.read(handbookProgressProvider.notifier).toggleTopicRead(topic.topicId);
                    // Optionally pop if newly marked read, but users might want to stay
                    // context.pop();
                  },
                  icon: Icon(isRead ? PhosphorIconsFill.checkCircle : PhosphorIcons.circle()),
                  label: Text(
                      isRead ? 'learn.markedAsRead'.tr() : 'learn.markAsRead'.tr(), // we'll use a fallback translation if 'markedAsRead' doesn't exist
                      style: AppFonts.outfit(context,
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRead ? scheme.surface : scheme.primary,
                    foregroundColor: isRead ? scheme.primary : scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: isRead ? 0 : null,
                    side: isRead ? BorderSide(color: scheme.primary.withValues(alpha: 0.3), width: 2) : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractiveFeatureLink extends StatelessWidget {
  const _InteractiveFeatureLink({required this.topicId});
  final String topicId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isFines = topicId == '1.5';
    final isPriority = topicId == '4.4';

    String route = '/violation-points';
    if (isFines) route = '/traffic-fines';
    if (isPriority) route = '/priority-guide';

    Color baseColor = scheme.secondary;
    if (isFines) baseColor = scheme.primary;
    if (isPriority) baseColor = Colors.orange.shade800;

    IconData icon = PhosphorIcons.warningCircle();
    if (isFines) icon = PhosphorIcons.money();
    if (isPriority) icon = PhosphorIcons.shieldCheck();

    String title = 'violationPoints.title'.tr();
    if (isFines) title = 'trafficFines.title'.tr();
    if (isPriority) title = 'priority.title'.tr();

    String description = 'settings.links.violationPointsDesc'.tr();
    if (isFines) description = 'settings.links.trafficFinesDesc'.tr();
    if (isPriority) description = 'priority.hero.subtitle'.tr();

    return InkWell(
      onTap: () {
        AppFeedback.tap(context);
        context.push(route);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [baseColor, baseColor.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.outfit(context,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppFonts.outfit(context,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

