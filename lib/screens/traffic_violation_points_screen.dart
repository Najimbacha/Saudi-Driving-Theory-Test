import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'simple_screen.dart';

class TrafficViolationPointsScreen extends StatelessWidget {
  const TrafficViolationPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleScreen(title: 'violationPoints.title'.tr());
  }
}
