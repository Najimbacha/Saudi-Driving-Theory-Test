import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'simple_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleScreen(title: 'stats.title'.tr());
  }
}
