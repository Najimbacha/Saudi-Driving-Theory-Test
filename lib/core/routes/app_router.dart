import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/categories/categories_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../data/models/exam_result_model.dart';
import '../../screens/achievements_screen.dart';
import '../../screens/credits_screen.dart';
import '../../presentation/screens/exam/exam_screen.dart';
import '../../screens/favorites_screen.dart';
import '../../screens/flashcards_screen.dart';
import '../../screens/learn_screen.dart';
import '../../screens/license_guide_screen.dart';
import '../../screens/not_found_screen.dart';
import '../../presentation/screens/quiz/practice_screen.dart';
import '../../presentation/screens/results/results_screen.dart';
import '../../presentation/screens/progress/exam_history_screen.dart';
import '../../screens/privacy_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/signs_screen.dart';
import '../../screens/stats_screen.dart';
import '../../screens/traffic_fines_screen.dart';
import '../../screens/traffic_violation_points_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, _) => const OnboardingIntroScreen()),
      GoRoute(path: '/home', builder: (context, _) => const HomeDashboardScreen()),
      GoRoute(path: '/categories', builder: (context, _) => const CategoriesScreen()),
      GoRoute(path: '/signs', builder: (context, _) => const SignsScreen()),
      GoRoute(path: '/flashcards', builder: (context, _) => const FlashcardsScreen()),
      GoRoute(path: '/practice', builder: (context, _) => const PracticeFlowScreen()),
      GoRoute(path: '/exam', builder: (context, _) => const ExamFlowScreen()),
      GoRoute(
        path: '/results',
        builder: (context, state) {
          final result = state.extra as ExamResult?;
          if (result == null) return const NotFoundScreen();
          return ResultsScreen(result: result);
        },
      ),
      GoRoute(path: '/favorites', builder: (context, _) => const FavoritesScreen()),
      GoRoute(path: '/stats', builder: (context, _) => const StatsScreen()),
      GoRoute(path: '/history', builder: (context, _) => const ExamHistoryScreen()),
      GoRoute(path: '/learn', builder: (context, _) => const LearnScreen()),
      GoRoute(path: '/achievements', builder: (context, _) => const AchievementsScreen()),
      GoRoute(path: '/settings', builder: (context, _) => const SettingsScreen()),
      GoRoute(path: '/credits', builder: (context, _) => const CreditsScreen()),
      GoRoute(path: '/violation-points', builder: (context, _) => const TrafficViolationPointsScreen()),
      GoRoute(path: '/traffic-fines', builder: (context, _) => const TrafficFinesScreen()),
      GoRoute(path: '/license-guide', builder: (context, _) => const LicenseGuideScreen()),
      GoRoute(path: '/privacy', builder: (context, _) => const PrivacyScreen()),
    ],
    errorBuilder: (context, _) => const NotFoundScreen(),
  );
});
