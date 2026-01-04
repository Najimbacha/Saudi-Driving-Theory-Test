import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/modern_theme.dart';
import '../../../widgets/glass_container.dart';
import '../../../state/data_state.dart';
import '../../../state/learning_state.dart';
import '../../providers/category_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final TextEditingController _controller = TextEditingController();
  int _selectedFilter = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final questionsAsync = ref.watch(questionsProvider);
    final learning = ref.watch(learningProvider);
    final query = _controller.text.trim().toLowerCase();
    
    // Optimize: Read pre-calculated counts instead of looping in build
    final questionCounts = ref.watch(categoryQuestionCountsProvider);
    final hasQuestionData = questionCounts.isNotEmpty;

    final visible = categories.where((cat) {
      final title = cat.titleKey.tr().toLowerCase();
      if (query.isNotEmpty && !title.contains(query)) return false;
      if (!hasQuestionData) return true;
      if (_selectedFilter == 0) return true;
      
      final stat = learning.categoryStats[cat.id];
      final total = questionCounts[cat.id] ?? 0;
      final answered = stat?.total ?? 0;
      
      if (_selectedFilter == 1) return answered > 0 && answered < total; // In Progress
      if (_selectedFilter == 2) return answered == total && total > 0; // Completed
      
      return (questionCounts[cat.id] ?? 0) > 0;
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('categories.title'.tr(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? ModernTheme.darkGradient
              : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
               // Search Bar
               Padding(
                 padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                 child: GlassContainer(
                   padding: const EdgeInsets.symmetric(horizontal: 16),
                   child: TextField(
                     controller: _controller,
                     style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface),
                     decoration: InputDecoration(
                       hintText: 'categories.search'.tr(),
                       hintStyle: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                       prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                       border: InputBorder.none,
                     ),
                     onChanged: (_) => setState(() {}),
                   ),
                 ),
               ),
               
               // Filters
               SingleChildScrollView(
                 scrollDirection: Axis.horizontal,
                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                 child: Row(
                   children: [
                     _GlassFilterChip(
                       label: 'categories.filterAll'.tr(),
                       selected: _selectedFilter == 0,
                       onTap: () => setState(() => _selectedFilter = 0),
                     ),
                     const SizedBox(width: 12),
                     _GlassFilterChip(
                       label: 'categories.filterInProgress'.tr(),
                       selected: _selectedFilter == 1,
                       onTap: () => setState(() => _selectedFilter = 1),
                     ),
                     const SizedBox(width: 12),
                     _GlassFilterChip(
                       label: 'categories.filterCompleted'.tr(),
                       selected: _selectedFilter == 2,
                       onTap: () => setState(() => _selectedFilter = 2),
                     ),
                   ],
                 ),
               ),

               // List
               Expanded(
                 child: ListView.builder(
                   padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                   itemCount: visible.length,
                   itemBuilder: (context, index) {
                      final category = visible[index];
                      final stat = learning.categoryStats[category.id];
                      final accuracy = stat?.accuracy;
                      final total = hasQuestionData
                          ? (questionCounts[category.id] ?? 0)
                          : category.totalQuestions;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _CategoryGlassCard(
                          title: category.titleKey.tr(),
                          subtitle: category.subtitleKey.tr(),
                          gradient: _gradientFor(category.id),
                          icon: _iconFor(category.iconName),
                          total: total,
                          accuracy: accuracy,
                          onTap: () {
                             HapticFeedback.lightImpact();
                             context.push('/practice?category=${category.id}');
                          },
                        ),
                      );
                   },
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(String name) {
    switch (name) {
      case 'traffic': return Icons.traffic_rounded;
      case 'rules': return Icons.gavel_rounded;
      case 'safety': return Icons.health_and_safety_rounded;
      case 'signals': return Icons.traffic_rounded;
      case 'markings': return Icons.add_road_rounded;
      case 'parking': return Icons.local_parking_rounded;
      case 'emergency': return Icons.warning_amber_rounded;
      case 'pedestrians': return Icons.directions_walk_rounded;
      case 'highway': return Icons.speed_rounded; // changed for visual variety
      case 'weather': return Icons.wb_sunny_rounded;
      case 'maintenance': return Icons.handyman_rounded;
      case 'responsibilities': return Icons.badge_rounded;
      default: return Icons.category_rounded;
    }
  }

  static LinearGradient _gradientFor(String id) {
    switch (id) {
      case 'signs': return const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)]);
      case 'rules': return const LinearGradient(colors: [Color(0xFFEAB308), Color(0xFFFACC15)]);
      case 'safety': return const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFF87171)]);
      case 'signals': return const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF4ADE80)]);
      case 'markings': return const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFFB923C)]);
      default: return ModernTheme.primaryGradient;
    }
  }
}

class _GlassFilterChip extends StatelessWidget {
  const _GlassFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? ModernTheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? ModernTheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CategoryGlassCard extends StatelessWidget {
  const _CategoryGlassCard({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.total,
    required this.accuracy,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final IconData icon;
  final int total;
  final int? accuracy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white10),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (accuracy != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _accuracyColor(accuracy!).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _accuracyColor(accuracy!).withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            '$accuracy%',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: _accuracyColor(accuracy!),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.quiz_rounded,
                          size: 14, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        '$total Questions',
                        style: GoogleFonts.outfit(
                            color: Colors.white54, fontSize: 12),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_rounded, size: 16, color: ModernTheme.secondary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _accuracyColor(int accuracy) {
    if (accuracy >= 80) return AppColors.success;
    if (accuracy >= 60) return AppColors.warning;
    return AppColors.error;
  }
}
