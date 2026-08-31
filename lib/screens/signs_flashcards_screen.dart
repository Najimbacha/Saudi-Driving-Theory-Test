import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/theme/modern_theme.dart';
import '../state/data_state.dart';
import '../utils/app_feedback.dart';
import '../utils/app_fonts.dart';
import '../models/sign.dart';

class SignsFlashcardsScreen extends ConsumerStatefulWidget {
  const SignsFlashcardsScreen({super.key, required this.initialCategory});

  final String initialCategory;

  @override
  ConsumerState<SignsFlashcardsScreen> createState() => _SignsFlashcardsScreenState();
}

class _SignsFlashcardsScreenState extends ConsumerState<SignsFlashcardsScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signsAsync = ref.watch(signsProvider);
    final locale = context.locale.languageCode;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('signs.flashcards.title'.tr(),
            style: AppFonts.outfit(context,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: signsAsync.when(
            data: (signs) {
              final filtered = signs.where((s) {
                return widget.initialCategory == 'all' || s.category == widget.initialCategory;
              }).toList();

              if (filtered.isEmpty) {
                return Center(child: Text('signs.empty'.tr()));
              }

              return Column(
                children: [
                  const SizedBox(height: 20),
                  // Progress indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'signs.flashcards.progress'.tr(namedArgs: {
                                'current': (_currentIndex + 1).toString(),
                                'total': filtered.length.toString()
                              }),
                              style: AppFonts.outfit(context,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurface.withValues(alpha: 0.6)),
                            ),
                            Text(
                              '${((_currentIndex + 1) / filtered.length * 100).toInt()}%',
                              style: AppFonts.outfit(context,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (_currentIndex + 1) / filtered.length,
                            minHeight: 8,
                            backgroundColor: scheme.onSurface.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Flashcard Deck
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: filtered.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                        AppFeedback.lightHaptic();
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                          child: _Flashcard(
                            sign: filtered[index],
                            locale: locale,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Study Mastery Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: ModernTheme.amber.withValues(alpha: 0.4),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              foregroundColor: ModernTheme.amber,
                            ),
                            onPressed: () {
                              AppFeedback.tap(context);
                              if (_currentIndex < filtered.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            icon: const Icon(
                              PhosphorIconsFill.bookmarkSimple,
                              size: 18,
                            ),
                            label: Text(
                              'Review Later',
                              style: AppFonts.outfit(
                                context,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ModernTheme.emerald,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () {
                              AppFeedback.confirm(context);
                              if (_currentIndex < filtered.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            icon: const Icon(
                              PhosphorIconsFill.checkCircle,
                              size: 18,
                            ),
                            label: Text(
                              'Mastered',
                              style: AppFonts.outfit(
                                context,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Navigation hints
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _NavButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: _currentIndex > 0
                            ? () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut)
                            : null,
                      ),
                      const SizedBox(width: 24),
                      Text(
                        'signs.flashcards.tip'.tr(),
                        style: AppFonts.outfit(context,
                            fontSize: 12.5,
                            color: scheme.onSurface.withValues(alpha: 0.45)),
                      ),
                      const SizedBox(width: 24),
                      _NavButton(
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _currentIndex < filtered.length - 1
                            ? () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text('signs.loadError'.tr())),
          ),
        ),
      ),
    );
  }
}

class _Flashcard extends StatefulWidget {
  const _Flashcard({required this.sign, required this.locale});
  final AppSign sign;
  final String locale;

  @override
  State<_Flashcard> createState() => _FlashcardState();
}

class _FlashcardState extends State<_Flashcard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    AppFeedback.heavyHaptic();
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = widget.sign.titles[widget.locale] ?? widget.sign.titles['en'] ?? '';

    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(angle),
            alignment: Alignment.center,
            child: angle < pi / 2
                ? _buildFront(scheme, isDark)
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildBack(scheme, isDark, title),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront(ColorScheme scheme, bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.7)
            : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : scheme.outline.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: SvgPicture.asset(
            'assets/${widget.sign.svgPath}',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildBack(ColorScheme scheme, bool isDark, String title) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.9)
            : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: ModernTheme.primary.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ModernTheme.primary.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ModernTheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                PhosphorIconsFill.info,
                color: ModernTheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppFonts.outfit(
                context,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: scheme.onSurface,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: ModernTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ModernTheme.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                'signs.categories.${widget.sign.category}'.tr(),
                style: AppFonts.outfit(
                  context,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: ModernTheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Container(
      decoration: BoxDecoration(
        color: isEnabled
            ? ModernTheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isEnabled
              ? ModernTheme.primary.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isEnabled
              ? ModernTheme.primary
              : Colors.white.withValues(alpha: 0.2),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
