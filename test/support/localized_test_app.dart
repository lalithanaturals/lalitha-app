import 'package:flutter/material.dart';
import 'package:lalitha_app/l10n/generated/app_localizations.dart';

/// Wraps [home] in a [MaterialApp] with the app's real localization
/// delegates/supported locales, so widget tests exercise `AppLocalizations`
/// the same way the real app does instead of hitting the "no
/// AppLocalizations found" null-check error MaterialApp throws without them.
MaterialApp localizedTestApp({required Widget home}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}
