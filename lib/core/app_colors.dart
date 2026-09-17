import 'package:flutter/material.dart';

/// Brand colors carried over from the four original single-page apps so the
/// Flutter suite keeps the same at-a-glance module identity: Print was sky
/// blue, Stock-transfer's header was emerald green, scrap-calc's header was
/// a red/rose gradient with amber accents, and Denomination's accent was
/// indigo. [suite] is the overall app's brand color (not tied to any one
/// module), matching the "Feel the earth" natural/organic positioning from
/// [BusinessInfo].
class AppColors {
  const AppColors._();

  static const suite = Color(0xFF047857); // emerald-700
  static const print = Color(0xFF0EA5E9); // sky-500
  static const stock = Color(0xFF047857); // emerald-700
  static const scrap = Color(0xFFDC2626); // red-600
  static const denomination = Color(0xFF4F46E5); // indigo-600
}
