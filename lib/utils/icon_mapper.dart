import 'package:flutter/material.dart';

class IconMapper {
  static IconData getIcon(String iconName) {
    final Map<String, IconData> iconMap = {
      'brush-outline': Icons.cleaning_services_outlined,
      'build-outline': Icons.handyman_outlined,
      'color-fill-outline': Icons.format_paint_outlined,
      'water-outline': Icons.local_laundry_service_outlined,
      'tv-outline': Icons.tv_outlined,
      'construct-outline': Icons.plumbing_outlined,
      'bus-outline': Icons.local_shipping_outlined,
      'cut-outline': Icons.content_cut_outlined,
      'snow-outline': Icons.ac_unit_outlined,
      'car-outline': Icons.directions_car_outlined,
      'laptop-outline': Icons.laptop_outlined,
      'leaf-outline': Icons.spa_outlined,
      'person-outline': Icons.person_outline,
      'ellipsis-horizontal': Icons.more_horiz,
    };

    return iconMap[iconName] ?? Icons.circle_outlined;
  }

  static Color parseColor(String hexColor) {
    return Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
  }
}
