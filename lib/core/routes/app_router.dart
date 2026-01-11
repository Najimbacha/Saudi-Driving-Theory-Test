import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/categories/categories_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../data/models/exam_result_model.dart';
import '../../screens/achievements_screen.dart';
import '../../screens/about_screen.dart';
import '../../screens/credits_screen.dart';
import '../../screens/favorites_screen.dart';
import '../../screens/flashcards_screen.dart';
import '../../screens/learn_screen.dart';
import '../../screens/license_guide_screen.dart';
import '../../screens/not_found_screen.dart';
import '../../presentation/screens/results/results_screen.dart';
import '../../presentation/screens/results/review_screen.dart';
import '../../presentation/screens/progress/exam_history_screen.dart';
import '../../screens/privacy_screen.dart';
import '../../screens/stats_screen.dart';
import '../../screens/support_development_screen.dart';
import '../../screens/traffic_fines_screen.dart';
import '../../screens/traffic_violation_points_screen.dart';
import '../../widgets/home_shell.dart';

CustomTransitionPage<void> _fadeSlidePage({
  required GoRouterState state,
  required Widget child,
}) {
  const duration = Duration(milliseconds: 260);
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0.04, 0.02),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: animation.drive(slide),
          child: child,
        ),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state: state, child: const SplashScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state: state, child: const OnboardingIntroScreen()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state: state, child: const HomeShell()),
      ),
      GoRoute(
        path: '/categories',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state: state, child: const CategoriesScreen()),
      ),
      GoRoute(
        path: '/signs',
        pageBuilder: (context, state) => _fadeSlidePage(
            state: state, child: const HomeShell(initialIndex: 1)),
      ),
      GoRoute(
        path: '/flashcards',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state: state, child: const FlashcardsScreen()),
      ),
      GoRoute(
        path: '/practice',
        pageBuilder: (context, state) => _fadeSlidePage(
            state: state, child: const HomeShell(initialIndex: 2)),
      ),
      GoRoute(
        path: '/exam',
        pageBuilder: (context, state) => _fadeSlidePage(
            state: state, child: const HomeShell(initialIndex: 3)),
      ),
      GoRoute(
        path: '/results',
        pageBuilder: (context, state) {
          final result = state.extra as ExamResult?;
          if (result == null) {
            return _fadeSlidePage(
                state: state, child: const NotFoundScreen());
          }
          assert(result.examType == 'exam');
          if (result.examType != 'exam') {
            return _fadeSlidePage(state: state, child: const HomeShell());
          }
          return _fadeSlidePage(
              state: state, child: ResultsScreen(result: result));
        },
      ),
      GoRoute(
        path: '/review',
        pageBuilder: (context, state) {
          final result = state.extra as ExamResult?;
          if (result == null) {
            return _fadeSlidePage(
                state: state, child: const NotFoundScreen());
          }
          return _fadeSlidePage(
              state: state, child: ReviewScreen(result: result));
        },
      ),
      GoRoute(
        path: '/favorites',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state: state, child: const FavoritesScreen()),
      ),
      GoRoute(
        path: '/stats',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state: state, child: const StatsScreen()),
      ),
      GoRoute(
        path: '/history',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state: state, child: const ExamHistoryScreen()),
      ),
      GoRoute(
        path: '/learn',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state: state, child: const LearnScreen()),
      ),
      GoRoute(
        path: '/achievements',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state: state, child: const AchievementsScreen()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _fadeSlidePage(
            state: state, child: const HomeShell(initialIndex: 4)),
      ),
      GoRoute(
        path: '/credits',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state: state, child: const CreditsScreen()),
      ),
      GoRoute(
        path: '/about',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state: state, child: const AboutScreen()),
      ),
      GoRoute(
        path: '/support-development',
        pageBuilder: (context, state) => _fadeSlidePage(
            state: state, child: const SupportDevelopmentScreen()),
      ),
      GoRoute(
        path: '/violation-points',
        pageBuilder: (context, state) => _fadeSlidePage(
            state: state, child: const TrafficViolationPointsScreen()),
      ),
      GoRoute(
        path: '/traffic-fines',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state: state, child: const TrafficFinesScreen()),
      ),
      GoRoute(
        path: '/license-guide',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state: state, child: const LicenseGuideScreen()),
      ),
      GoRoute(
        path: '/privacy',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state: state, child: const PrivacyScreen()),
      ),
    ],
    errorPageBuilder: (context, state) =>
        _fadeSlidePage(state: state, child: const NotFoundScreen()),
  );
});
