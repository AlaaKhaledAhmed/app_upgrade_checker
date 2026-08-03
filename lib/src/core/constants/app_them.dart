import 'package:flutter/material.dart';
import 'package:app_upgrade/src/core/constants/app_color.dart';

class AppThem {
  ///singleton class for app theme
  static final AppThem _instance = AppThem._internal();
  factory AppThem() => _instance;
  AppThem._internal();
  final String _fontFamily = 'IBMP';
  final FontWeight regular = FontWeight.w400; // Cairo-Regular
  final FontWeight bold = FontWeight.bold; // Cairo-Regular
  final FontWeight semeBold = FontWeight.w700; // Cairo-Regular

  String get fontFamily => _fontFamily;

  FontWeight get regularWeight => regular;

  ThemeData getAppThem() {
    return ThemeData(
      dividerTheme:
          const DividerThemeData(color: AppColor.lightGray, thickness: 0.8),
      primaryColor: AppColor.mainColor,
      scaffoldBackgroundColor: AppColor.scaffoldColor,
      useMaterial3: true,
      fontFamily: fontFamily,
    );
  }
}
