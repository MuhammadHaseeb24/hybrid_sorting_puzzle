import 'package:flutter/services.dart';

/// Central place for all vibration feedback so the Settings toggle works everywhere.
class Haptics {
  static bool enabled = true;

  static void tap() {
    if (enabled) HapticFeedback.selectionClick();
  }

  static void light() {
    if (enabled) HapticFeedback.lightImpact();
  }

  static void medium() {
    if (enabled) HapticFeedback.mediumImpact();
  }

  static void heavy() {
    if (enabled) HapticFeedback.heavyImpact();
  }

  /// Soft ticks while liquid is flowing.
  static void flow() {
    if (enabled) HapticFeedback.selectionClick();
  }

  /// Celebration pattern for level complete.
  static Future<void> win() async {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 130));
    if (!enabled) return;
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 130));
    if (!enabled) return;
    HapticFeedback.lightImpact();
  }

  /// Double thud for fail.
  static Future<void> lose() async {
    if (!enabled) return;
    HapticFeedback.vibrate();
    await Future.delayed(const Duration(milliseconds: 160));
    if (!enabled) return;
    HapticFeedback.heavyImpact();
  }
}
