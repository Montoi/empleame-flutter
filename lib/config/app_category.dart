import 'package:flutter/material.dart';

/// A single entry in the official service category catalog.
///
/// [id] is the technical key stored in Firestore — never changes between locales.
/// [localizationKey] is the dot-path used with easy_localization's `tr()`,
/// e.g. `'categories.carpentry'`.
class AppCategory {
  final String id;
  final String localizationKey;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const AppCategory({
    required this.id,
    required this.localizationKey,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}
