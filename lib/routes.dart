import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/achievements_screen.dart';
import 'screens/credits_screen.dart';
import 'screens/exam_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/flashcards_screen.dart';
import 'screens/home_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/license_guide_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signs_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/traffic_fines_screen.dart';
import 'screens/traffic_violation_points_screen.dart';
import 'state/app_state.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return GoRouter(
    initialLocation: settings.hasSeenOnboarding ? '/' : '/onboarding',
    routes: [
      GoRoute(path: '/', builder: (context, _) => const HomeScreen()),
      GoRoute(path: '/onboarding', builder: (context, _) => const OnboardingScreen()),
      GoRoute(path: '/signs', builder: (context, _) => const SignsScreen()),
      GoRoute(path: '/flashcards', builder: (context, _) => const FlashcardsScreen()),
      GoRoute(path: '/practice', builder: (context, _) => const PracticeScreen()),
      GoRoute(path: '/exam', builder: (context, _) => const ExamScreen()),
      GoRoute(path: '/favorites', builder: (context, _) => const FavoritesScreen()),
      GoRoute(path: '/stats', builder: (context, _) => const StatsScreen()),
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
