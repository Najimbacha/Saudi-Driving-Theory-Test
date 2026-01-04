import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/modern_theme.dart';
import '../widgets/glass_container.dart';
import '../models/sign.dart';
import '../state/data_state.dart';

class SignsScreen extends ConsumerStatefulWidget {
  const SignsScreen({super.key});

  @override
  ConsumerState<SignsScreen> createState() => _SignsScreenState();
}

class _SignsScreenState extends ConsumerState<SignsScreen> {
  String query = '';
  String category = 'all';

  @override
  Widget build(BuildContext context) {
    final signsAsync = ref.watch(signsProvider);
    final locale = context.locale.languageCode;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('signs.title'.tr(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
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
                     style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface),
                     decoration: InputDecoration(
                       hintText: 'signs.search'.tr(),
                       hintStyle: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                       prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                       border: InputBorder.none,
                     ),
                     onChanged: (value) => setState(() => query = value.toLowerCase()),
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
                       label: 'signs.categories.all'.tr(),
                       selected: category == 'all',
                       onTap: () => setState(() => category = 'all'),
                     ),
                     const SizedBox(width: 12),
                     _GlassFilterChip(
                       label: 'signs.categories.warning'.tr(),
                       selected: category == 'warning',
                       onTap: () => setState(() => category = 'warning'),
                     ),
                     const SizedBox(width: 12),
                     _GlassFilterChip(
                       label: 'signs.categories.regulatory'.tr(),
                       selected: category == 'regulatory',
                       onTap: () => setState(() => category = 'regulatory'),
                     ),
                      const SizedBox(width: 12),
                     _GlassFilterChip(
                       label: 'signs.categories.mandatory'.tr(),
                       selected: category == 'mandatory',
                       onTap: () => setState(() => category = 'mandatory'),
                     ),
                      const SizedBox(width: 12),
                     _GlassFilterChip(
                       label: 'signs.categories.guide'.tr(),
                       selected: category == 'guide',
                       onTap: () => setState(() => category = 'guide'),
                     ),
                   ],
                 ),
               ),
               
               // Grid
               Expanded(
                 child: signsAsync.when(
                    data: (signs) {
                      final filtered = signs.where((s) {
                        final title = s.titles[locale] ?? s.titles['en'] ?? '';
                        final matchQuery = title.toLowerCase().contains(query);
                        final matchCategory = category == 'all' || s.category == category;
                        return matchQuery && matchCategory;
                      }).toList();
                      
                      if (filtered.isEmpty) {
                         return Center(
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(Icons.search_off_rounded, size: 64, color: Colors.white24),
                               const SizedBox(height: 16),
                               Text(
                                 'No signs found', 
                                 style: GoogleFonts.outfit(color: Colors.white54, fontSize: 16),
                               ),
                             ],
                           ),
                         );
                      }

                      final width = MediaQuery.of(context).size.width;
                      final columns = width >= 900 ? 5 : width >= 600 ? 4 : 3; // Dense grid
                      
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final sign = filtered[idx];
                          final title = sign.titles[locale] ?? sign.titles['en'] ?? '';
                          return GestureDetector(
                            onTap: () {
                               HapticFeedback.lightImpact();
                               _showSignDetails(context, sign, title);
                            },
                            child: GlassContainer(
                              padding: const EdgeInsets.all(12),
                              color: Colors.white.withValues(alpha: 0.05),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Hero(
                                      tag: 'sign_${sign.id}',
                                      child: SvgPicture.asset('assets/${sign.svgPath}', fit: BoxFit.contain),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                      title, 
                                    textAlign: TextAlign.center, 
                                    style: GoogleFonts.outfit(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => Center(
                      child: Text('Failed to load signs', style: GoogleFonts.outfit(color: Colors.white)),
                    ),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignDetails(BuildContext context, AppSign sign, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return GlassContainer(
           borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
           color: const Color(0xFF0F172A).withValues(alpha: 0.95),
           padding: const EdgeInsets.fromLTRB(25, 12, 25, 40),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
               const SizedBox(height: 30),
               SizedBox(
                  height: 180,
                  child: Hero(
                    tag: 'sign_${sign.id}',
                    child: SvgPicture.asset('assets/${sign.svgPath}', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                   decoration: BoxDecoration(
                     color: ModernTheme.primary.withValues(alpha: 0.2),
                     borderRadius: BorderRadius.circular(20),
                     border: Border.all(color: ModernTheme.primary.withValues(alpha: 0.5)),
                   ),
                   child: Text(
                     'signs.categories.${sign.category}'.tr(),
                     style: GoogleFonts.outfit(
                       color: ModernTheme.primary,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 ),
                 const SizedBox(height: 32),
                 SizedBox(
                   width: double.infinity,
                   child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.white.withValues(alpha: 0.1),
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(vertical: 16),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     ),
                     onPressed: () => Navigator.pop(context),
                     child: Text('common.close'.tr(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                   ),
                 ),
             ],
           ),
        );
      },
    );
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
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
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
