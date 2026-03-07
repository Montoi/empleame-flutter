import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reactive trigger so individual screens can watch locale changes and rebuild.
///
/// This provider does NOT drive MaterialApp.router(locale:) — that role
/// belongs exclusively to easy_localization via its delegates.
///
/// Usage in screens:
///   ref.watch(localeProvider); // causes build() to re-run on language change
///
/// Usage in LanguageScreen to notify all watchers:
///   ref.read(localeProvider.notifier).state = Locale(code);
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));
