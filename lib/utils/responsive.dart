import 'package:flutter/material.dart';

class R {
  final BuildContext context;
  late final Size size;
  late final double width;
  late final double height;
  late final bool isSmall;
  late final bool isMedium;
  late final bool isLarge;
  late final bool isTablet;
  late final double scale;

  R(this.context) {
    size = MediaQuery.sizeOf(context);
    width = size.width;
    height = size.height;
    isSmall = height < 680 || width < 360;
    isMedium = height >= 680 && height < 850;
    isLarge = height >= 850;
    isTablet = width >= 600;
    scale = (width / 390).clamp(0.82, 1.25);
  }

  double sp(double value) => value * scale;

  double hp(double percent) => height * percent;
  double wp(double percent) => width * percent;

  EdgeInsets get screenPadding => EdgeInsets.symmetric(
    horizontal: isTablet ? 32 : (isSmall ? 12 : 16),
    vertical: isSmall ? 8 : 12,
  );

  int get levelGridCount {
    if (width >= 900) return 5;
    if (width >= 600) return 4;
    if (width >= 400) return 3;
    return 3;
  }

  double get tubeMaxWidth {
    if (isTablet) return 72;
    if (isSmall) return 48;
    return 60;
  }

  double get tubeMinWidth {
    if (isSmall) return 36;
    return 42;
  }
}