import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'simple_screen.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleScreen(title: 'credits.title'.tr());
  }
}
