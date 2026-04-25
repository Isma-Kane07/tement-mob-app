// lib/utils/responsive_helper.dart
import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    double width = MediaQuery.of(context).size.width;
    if (width < 360) return baseSize * 0.9; // Petits écrans
    if (width > 1200) return baseSize * 1.2; // Grands écrans
    return baseSize; // Écrans normaux
  }

  static double getResponsivePadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 360) return 12.0;
    if (width > 1200) return 32.0;
    return 16.0;
  }
}
