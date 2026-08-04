import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_upgrade_checker/src/core/constants/app_color.dart';
import 'package:app_upgrade_checker/src/core/extensions/color_extensions.dart';
import 'package:app_upgrade_checker/src/core/constants/files_path.dart';

enum InputType {
  weight,
  materialType,
  height,
  length,
  width,
  balletNumber,
}

enum ImageType { network, memory, assets }

class AppDecoration {
  /// Returns a customizable [BoxDecoration] for styling a widget===============================================================================================
  static BoxDecoration decoration({
    bool shadow = false,
    Color? color,
    double radius = 10,
    double shadowOpacity = 0.5,
    bool showBorder = false,
    Color? borderColor,
    double borderWidth = 0.5,
    String? imagePath,
    bool cover = false,
    ColorFilter? colorFilter,
    bool isGradient = false,
    AlignmentGeometry alignment = Alignment.center,
    Gradient? gradient,
    double? blurRadius,
    BorderRadiusGeometry? borderRadius,
    bool isCircle = false,
    double imageOpacity = 1,

    // Radius flags
    bool radiusOnlyTop = false,
    bool radiusOnlyBottom = false,
    bool radiusOnlyTopLeftBottomLeft = false,
    bool radiusOnlyTopRightBottomRight = false,
    bool radiusOnlyTopLeft = false,
    bool radiusOnlyTopRight = false,
    bool radiusOnlyBottomLeft = false,
    bool radiusOnlyBottomRight = false,

    // New border sides
    bool showLeftBorder = false,
    bool showRightBorder = false,
    bool showTopBorder = false,
    ImageType? imageType,
  }) {
    final Radius resolvedRadius = Radius.circular(radius);

    BorderRadiusGeometry resolveRadius() {
      if (borderRadius != null) return borderRadius;

      if (radiusOnlyTop) {
        return BorderRadius.only(
          topLeft: resolvedRadius,
          topRight: resolvedRadius,
        );
      } else if (radiusOnlyBottom) {
        return BorderRadius.only(
          bottomLeft: resolvedRadius,
          bottomRight: resolvedRadius,
        );
      } else if (radiusOnlyTopLeftBottomLeft) {
        return BorderRadius.only(
          topLeft: resolvedRadius,
          bottomLeft: resolvedRadius,
        );
      } else if (radiusOnlyTopRightBottomRight) {
        return BorderRadius.only(
          topRight: resolvedRadius,
          bottomRight: resolvedRadius,
        );
      } else if (radiusOnlyTopLeft) {
        return BorderRadius.only(topLeft: resolvedRadius);
      } else if (radiusOnlyTopRight) {
        return BorderRadius.only(topRight: resolvedRadius);
      } else if (radiusOnlyBottomLeft) {
        return BorderRadius.only(bottomLeft: resolvedRadius);
      } else if (radiusOnlyBottomRight) {
        return BorderRadius.only(bottomRight: resolvedRadius);
      }

      return BorderRadius.all(resolvedRadius);
    }

    Border? buildBorder() {
      if (showBorder) {
        return Border.all(
          color: borderColor ?? AppColor.lightGray,
          width: borderWidth,
        );
      }

      if (showLeftBorder || showRightBorder || showTopBorder) {
        return Border(
          top: showTopBorder
              ? BorderSide(
                  color: borderColor ?? AppColor.lightGray,
                  width: borderWidth,
                )
              : BorderSide.none,
          left: showLeftBorder
              ? BorderSide(
                  color: borderColor ?? AppColor.lightGray,
                  width: borderWidth,
                )
              : BorderSide.none,
          right: showRightBorder
              ? BorderSide(
                  color: borderColor ?? AppColor.lightGray,
                  width: borderWidth,
                )
              : BorderSide.none,
        );
      }

      return null;
    }

    return BoxDecoration(
      shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      color: isGradient ? null : (color ?? AppColor.white),
      gradient: isGradient
          ? gradient ??
              LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.subtextColor,
                  AppColor.subtextColor.resolveOpacity(0.99),
                  AppColor.subtextColor.resolveOpacity(0.85),
                  AppColor.subtextColor.resolveOpacity(0.62),
                ],
              )
          : null,
      image: imagePath != null
          ? DecorationImage(
              onError: (exception, stackTrace) {
                debugPrint('can not load image');
              },
              image: (imageType == ImageType.network
                  ? NetworkImage(imagePath)
                  : imageType == ImageType.memory
                      ? MemoryImage(File(imagePath).readAsBytesSync())
                      : AssetImage(imagePath,
                          package: FilesPath.packageName)) as ImageProvider,
              fit: cover ? BoxFit.cover : BoxFit.contain,
              colorFilter: colorFilter,
              alignment: alignment,
              opacity: imageOpacity,
            )
          : null,
      border: buildBorder(),
      borderRadius: isCircle ? null : resolveRadius(),
      boxShadow: shadow
          ? [
              BoxShadow(
                color: Colors.grey.resolveOpacity(shadowOpacity),
                offset: const Offset(0, 1),
                blurRadius: blurRadius ?? 6.0,
              ),
            ]
          : null,
    );
  }
}
