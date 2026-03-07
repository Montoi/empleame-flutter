import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app_category.dart';

/// Single Source of Truth for all service categories in the app.
///
/// Rules:
/// - [AppCategory.id] is always what gets stored in Firestore.
/// - UI displays are obtained via `tr(category.localizationKey)`.
/// - Never add free-text categories — always add them here first.
abstract final class AppCategories {
  /// Complete ordered list of all service categories (no "More" entry).
  static const List<AppCategory> all = [
    AppCategory(
      id: 'cleaning',
      localizationKey: 'categories.cleaning',
      icon: Icons.cleaning_services_outlined,
      color: Color(0xFF7C3AED),
      bgColor: Color(0xFFEDE9FE),
    ),
    AppCategory(
      id: 'repairing',
      localizationKey: 'categories.repairing',
      icon: Icons.handyman_outlined,
      color: Color(0xFFEA580C),
      bgColor: Color(0xFFFFEDD5),
    ),
    AppCategory(
      id: 'painting',
      localizationKey: 'categories.painting',
      icon: Icons.format_paint_outlined,
      color: Color(0xFF2563EB),
      bgColor: Color(0xFFDBEAFE),
    ),
    AppCategory(
      id: 'laundry',
      localizationKey: 'categories.laundry',
      icon: Icons.local_laundry_service_outlined,
      color: Color(0xFFCA8A04),
      bgColor: Color(0xFFFEF9C3),
    ),
    AppCategory(
      id: 'appliance',
      localizationKey: 'categories.appliance',
      icon: Icons.tv_outlined,
      color: Color(0xFFDC2626),
      bgColor: Color(0xFFFEE2E2),
    ),
    AppCategory(
      id: 'plumbing',
      localizationKey: 'categories.plumbing',
      icon: Icons.plumbing_outlined,
      color: Color(0xFF059669),
      bgColor: Color(0xFFD1FAE5),
    ),
    AppCategory(
      id: 'shifting',
      localizationKey: 'categories.shifting',
      icon: Icons.local_shipping_outlined,
      color: Color(0xFF0891B2),
      bgColor: Color(0xFFCFFAFE),
    ),
    AppCategory(
      id: 'beauty',
      localizationKey: 'categories.beauty',
      icon: Icons.content_cut_outlined,
      color: Color(0xFFDB2777),
      bgColor: Color(0xFFFCE7F3),
    ),
    AppCategory(
      id: 'ac_repair',
      localizationKey: 'categories.ac_repair',
      icon: Icons.ac_unit_outlined,
      color: Color(0xFF16A34A),
      bgColor: Color(0xFFDCFCE7),
    ),
    AppCategory(
      id: 'vehicle',
      localizationKey: 'categories.vehicle',
      icon: Icons.directions_car_outlined,
      color: Color(0xFF4F46E5),
      bgColor: Color(0xFFE0E7FF),
    ),
    AppCategory(
      id: 'electronics',
      localizationKey: 'categories.electronics',
      icon: Icons.laptop_outlined,
      color: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
    ),
    AppCategory(
      id: 'massage',
      localizationKey: 'categories.massage',
      icon: Icons.spa_outlined,
      color: Color(0xFFE11D48),
      bgColor: Color(0xFFFFE4E6),
    ),
    AppCategory(
      id: 'mens_salon',
      localizationKey: 'categories.mens_salon',
      icon: Icons.person_outline,
      color: Color(0xFF7C3AED),
      bgColor: Color(0xFFF5F3FF),
    ),
    AppCategory(
      id: 'carpentry',
      localizationKey: 'categories.carpentry',
      icon: Icons.carpenter,
      color: Color(0xFF92400E),
      bgColor: Color(0xFFFEF3C7),
    ),
    AppCategory(
      id: 'electricity',
      localizationKey: 'categories.electricity',
      icon: Icons.electrical_services_outlined,
      color: Color(0xFFB45309),
      bgColor: Color(0xFFFFFBEB),
    ),
    AppCategory(
      id: 'gardening',
      localizationKey: 'categories.gardening',
      icon: Icons.yard_outlined,
      color: Color(0xFF15803D),
      bgColor: Color(0xFFF0FDF4),
    ),
    AppCategory(
      id: 'security',
      localizationKey: 'categories.security',
      icon: Icons.security_outlined,
      color: Color(0xFF1D4ED8),
      bgColor: Color(0xFFEFF6FF),
    ),
    AppCategory(
      id: 'education',
      localizationKey: 'categories.education',
      icon: Icons.school_outlined,
      color: Color(0xFF7C3AED),
      bgColor: Color(0xFFF5F3FF),
    ),
    AppCategory(
      id: 'events',
      localizationKey: 'categories.events',
      icon: Icons.celebration_outlined,
      color: Color(0xFFBE185D),
      bgColor: Color(0xFFFDF2F8),
    ),
    AppCategory(
      id: 'others',
      localizationKey: 'categories.others',
      icon: Icons.more_horiz,
      color: Color(0xFF64748B),
      bgColor: Color(0xFFF8FAFC),
    ),
  ];

  /// All technical IDs, suitable for the form dropdown value list.
  static List<String> get ids => all.map((c) => c.id).toList();

  /// `['all', ...ids]` — for filter chip lists that include an "All" option.
  static List<String> get filterIds => ['all', ...ids];

  /// Look up a category by its technical [id]. Returns null if not found.
  static AppCategory? byId(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Attempts to find a matching category by id, localization key, or translated string.
  /// Useful for handling legacy data where localized names were stored directly in the DB.
  static AppCategory? matchCategory(String query) {
    if (query.isEmpty) return null;
    final qClean = query.toLowerCase().trim();

    // 1. Exact ID match
    var match = byId(query);
    if (match != null) return match;

    // 2. Match by current locale translation
    try {
      return all.firstWhere(
        (c) => tr(c.localizationKey).toLowerCase() == qClean,
      );
    } catch (_) {}

    // 3. Match by localization key suffix
    try {
      return all.firstWhere(
        (c) => c.localizationKey.split('.').last.toLowerCase() == qClean,
      );
    } catch (_) {}

    return null;
  }
}
