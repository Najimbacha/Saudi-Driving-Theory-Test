import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'simple_screen.dart';

class LicenseGuideScreen extends StatelessWidget {
  const LicenseGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleScreen(title: 'licenseGuide.title'.tr());
  }
}
