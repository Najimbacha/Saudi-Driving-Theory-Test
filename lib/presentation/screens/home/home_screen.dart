import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/home_shell.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _HeroHeader(),
            const SizedBox(height: 12),
            const SizedBox(height: 16),
            Text('home.practice'.tr(), style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            _QuickActionsRow(
              actions: [
                _QuickActionData(
                  label: 'home.practice'.tr(),
                  icon: Icons.flash_on_outlined,
                  onTap: () {
                    final shell = TabShellScope.maybeOf(context);
                    if (shell != null) {
                      shell.value = 2;
                    } else {
                      context.push('/practice');
                    }
                  },
                ),
                _QuickActionData(
                  label: 'home.mockExam'.tr(),
                  icon: Icons.assignment_outlined,
                  onTap: () {
                    final shell = TabShellScope.maybeOf(context);
                    if (shell != null) {
                      shell.value = 3;
                    } else {
                      context.push('/exam');
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('home.roadKnowledge.title'.tr(),
                style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            _ActionGrid(
              actions: [
                _ActionCardData(
                  title: 'home.practiceByCategory'.tr(),
                  subtitle: '',
                  icon: Icons.category_rounded,
                  gradient: const [AppColors.primary, AppColors.primaryLight],
                  onTap: () => context.push('/categories'),
                ),
                _ActionCardData(
                  title: 'home.learnSigns'.tr(),
                  subtitle: '',
                  icon: Icons.signpost_rounded,
                  gradient: const [AppColors.secondaryDark, AppColors.secondary],
                  onTap: () {
                    final shell = TabShellScope.maybeOf(context);
                    if (shell != null) {
                      shell.value = 1;
                    } else {
                      context.push('/signs');
                    }
                  },
                ),
                _ActionCardData(
                  title: 'home.stats'.tr(),
                  subtitle: '',
                  icon: Icons.insights_rounded,
                  gradient: const [AppColors.success, AppColors.primaryLight],
                  onTap: () => context.push('/stats'),
                ),
                _ActionCardData(
                  title: 'home.history'.tr(),
                  subtitle: '',
                  icon: Icons.history_rounded,
                  gradient: const [AppColors.info, AppColors.accent],
                  onTap: () => context.push('/history'),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'home.greeting'.tr(),
                  style:
                      theme.textTheme.displaySmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'home.subtitle'.tr(),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.white70, height: 1.2),
                ),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _TagChip(labelKey: 'home.badges.offline'),
                    _TagChip(labelKey: 'home.badges.noLogin'),
                    _TagChip(labelKey: 'home.badges.noInternet'),
                  ],
                ),
              ],
            ),
          ),
          PositionedDirectional(
            end: -10,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          PositionedDirectional(
            end: 14,
            top: 14,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.directions_car_rounded,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.actions});

  final List<_ActionCardData> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final width = constraints.maxWidth;
        const crossAxisCount = 2;
        const spacing = 12.0;
        final tileWidth =
            (width - (spacing * (crossAxisCount - 1))) / crossAxisCount;
        final scale = media.textScaler.scale(1.0).clamp(1.0, 1.3);
        final baseHeight = tileWidth * 1.05 + 28;
        final targetHeight = baseHeight + ((scale - 1.0) * 36);
        final aspectRatio = tileWidth / targetHeight;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return _PressableCard(data: actions[index], delay: index * 90);
          },
        );
      },
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.actions});

  final List<_QuickActionData> actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(actions.length, (index) {
        final action = actions[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: index == actions.length - 1 ? 0 : 12,
            ),
            child: Semantics(
              button: true,
              label: action.label,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: action.onTap,
                child: Ink(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 16, 14, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.95),
                        AppColors.secondary.withValues(alpha: 0.9),
                      ],
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: scheme.outline.withValues(alpha: 0.28),
                    ),
                  ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            action.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  height: 1.15,
                                ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_forward,
                              color: Colors.white, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.labelKey});

  final String labelKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        labelKey.tr(),
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.white, fontSize: 11),
      ),
    );
  }
}

class _ActionCardData {
  const _ActionCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
}

class _PressableCard extends StatefulWidget {
  const _PressableCard({required this.data, required this.delay});

  final _ActionCardData data;
  final int delay;

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final textScale = media.textScaler.scale(1.0);
    final isCompact = media.size.height < 760 || textScale > 1.05;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + widget.delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Semantics(
        button: true,
        label: '${widget.data.title}. ${widget.data.subtitle}',
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.data.onTap,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: _pressed ? 0.97 : 1,
            child: Card(
              child: Container(
                padding: EdgeInsets.all(isCompact ? 12 : 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.data.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: isCompact ? 34 : 40,
                      height: isCompact ? 34 : 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        widget.data.icon,
                        color: Colors.white,
                        size: isCompact ? 16 : 20,
                      ),
                    ),
                    SizedBox(height: isCompact ? 6 : 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.data.title,
                            maxLines: isCompact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                          ),
                          SizedBox(height: isCompact ? 2 : 4),
                          Text(
                            widget.data.subtitle,
                            maxLines: isCompact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white70,
                                  height: 1.25,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        isCompact ? 8 : 10,
                        isCompact ? 4 : 5,
                        isCompact ? 8 : 10,
                        isCompact ? 4 : 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'common.next'.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(width: isCompact ? 4 : 6),
                          Icon(Icons.arrow_forward,
                              color: Colors.white,
                              size: isCompact ? 14 : 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
