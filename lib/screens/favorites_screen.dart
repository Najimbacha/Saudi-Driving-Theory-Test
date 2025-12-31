import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'simple_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleScreen(title: 'favorites.title'.tr());
  }
}
