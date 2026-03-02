import 'package:flutter/material.dart';
import 'service_icon_item.dart';

class ServiceData {
  final IconData icon;
  final String label;
  final Color color;

  const ServiceData({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class ServicesGrid extends StatelessWidget {
  final List<ServiceData> services;
  final Function(int)? onServiceTap;

  const ServicesGrid({super.key, required this.services, this.onServiceTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 20,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return ServiceIconItem(
            icon: service.icon,
            label: service.label,
            color: service.color,
            onTap: onServiceTap != null ? () => onServiceTap!(index) : null,
          );
        },
      ),
    );
  }
}
