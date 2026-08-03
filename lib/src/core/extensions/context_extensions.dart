import 'dart:io';
import 'package:flutter/material.dart';

extension BuildContextValue on BuildContext {
  // media query from presentation edges

  // presentation insets from presentation edges
  double get top => MediaQuery.of(this).padding.top;
  double get bottom => MediaQuery.of(this).padding.bottom;

  // orientation
  Orientation get orientation => MediaQuery.orientationOf(this);
  bool get isLandscape => orientation == Orientation.landscape;
  bool get isPortrait => orientation == Orientation.portrait;

  double get width => isLandscape
      ? MediaQuery.sizeOf(this).height
      : MediaQuery.sizeOf(this).width;
  void get unfocused => FocusManager.instance.primaryFocus?.unfocus();
  double get height => isLandscape
      ? MediaQuery.sizeOf(this).width
      : MediaQuery.sizeOf(this).height;

  // platform
  bool get isAndroid => Platform.isAndroid;
  bool get isIOS => Platform.isIOS;
  bool get isFuchsia => Platform.isFuchsia;

  void unFocusOnTapOutSite(final PointerDownEvent event) {
    if (!FocusScope.of(this).hasPrimaryFocus && FocusScope.of(this).hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}
