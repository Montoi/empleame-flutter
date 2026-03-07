import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Drives the app locale from Riverpod state.
///
/// Use [localeProvider.notifier] to switch languages:
/// ```dart
/// ref.read(localeProvider.notifier).state = const Locale('es');
/// ```
/// `MyApp` watches this provider and passes it to `MaterialApp.router(locale:)`.
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));
