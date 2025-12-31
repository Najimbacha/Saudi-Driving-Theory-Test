import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'simple_screen.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleScreen(title: 'achievements.title'.tr());
  }
}
