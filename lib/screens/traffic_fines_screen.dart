import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'simple_screen.dart';

class TrafficFinesScreen extends StatelessWidget {
  const TrafficFinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleScreen(title: 'trafficFines.title'.tr());
  }
}
