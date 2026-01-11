import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/providers/exam_provider.dart';
import '../presentation/screens/exam/exam_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/quiz/practice_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/signs_screen.dart';
import '../utils/back_guard.dart';
import '../utils/navigation_utils.dart';
import 'bottom_nav.dart';

class TabShellScope extends InheritedNotifier<ValueNotifier<int>> {
  const TabShellScope({
    super.key,
    required ValueNotifier<int> notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ValueNotifier<int>? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TabShellScope>()
        ?.notifier;
  }
}

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  late final ValueNotifier<int> _index;
  late final List<GlobalKey<NavigatorState>> _navKeys;

  @override
  void initState() {
    super.initState();
    _index = ValueNotifier<int>(widget.initialIndex);
    _navKeys = List.generate(5, (_) => GlobalKey<NavigatorState>());
  }

  @override
  void dispose() {
    _index.dispose();
    super.dispose();
  }

  Future<void> _handleBack() async {
    final currentIndex = _index.value;
    final currentNav = _navKeys[currentIndex].currentState;
    final exam = ref.read(examProvider);
    final examController = ref.read(examProvider.notifier);
    final examInProgress = exam.questions.isNotEmpty &&
        !exam.isCompleted &&
        (exam.answers.isNotEmpty ||
            exam.currentIndex > 0 ||
            (exam.originalDurationSeconds > 0 && exam.timeLeftSeconds > 0));

    if (currentIndex == 3 && examInProgress) {
      final shouldExit = await confirmExitExam(context);
      if (!mounted) return;
      if (!shouldExit) return;
      examController.reset();
      if (!mounted) return;
      await handleAppBack(context, fromPopScope: true);
      return;
    }
    if (!mounted) return;
    await handleAppBack(
      context,
      nestedNavigator: currentNav,
      fromPopScope: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final exam = ref.watch(examProvider);
    final examInProgress = exam.questions.isNotEmpty &&
        !exam.isCompleted &&
        (exam.answers.isNotEmpty ||
            exam.currentIndex > 0 ||
            (exam.originalDurationSeconds > 0 && exam.timeLeftSeconds > 0));

    return TabShellScope(
      notifier: _index,
      child: ValueListenableBuilder<int>(
        valueListenable: _index,
        builder: (context, index, _) {
          final currentNav = _navKeys[index].currentState;
          final canPopNested = currentNav?.canPop() ?? false;
          final canPopRoot =
              Navigator.of(context, rootNavigator: true).canPop();
          final canPopRoute =
              canPopRoot && !examInProgress && !canPopNested;

          return PopScope(
            canPop: canPopRoute,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop) return;
              await _handleBack();
            },
            child: Scaffold(
              extendBody: true,
              body: IndexedStack(
                index: index,
                children: [
                  _TabNavigator(
                    navigatorKey: _navKeys[0],
                    child: const HomeDashboardScreen(),
                  ),
                  _TabNavigator(
                    navigatorKey: _navKeys[1],
                    child: const SignsScreen(),
                  ),
                  _TabNavigator(
                    navigatorKey: _navKeys[2],
                    child: const PracticeFlowScreen(),
                  ),
                  _TabNavigator(
                    navigatorKey: _navKeys[3],
                    child: const ExamFlowScreen(),
                  ),
                  _TabNavigator(
                    navigatorKey: _navKeys[4],
                    child: const SettingsScreen(),
                  ),
                ],
              ),
              bottomNavigationBar: (index == 2 || index == 3)
                  ? null
                  : BottomNav(
                      currentIndex: _navIndexForShell(index),
                      onTap: (next) => _index.value = _shellIndexForNav(next),
                    ),
            ),
          );
        },
      ),
    );
  }

  int _navIndexForShell(int shellIndex) {
    switch (shellIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 4:
        return 2;
      default:
        return 0;
    }
  }

  int _shellIndexForNav(int navIndex) {
    switch (navIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 4;
      default:
        return 0;
    }
  }
}

class _TabNavigator extends StatelessWidget {
  const _TabNavigator({
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) {
        return MaterialPageRoute(builder: (_) => child);
      },
    );
  }
}
