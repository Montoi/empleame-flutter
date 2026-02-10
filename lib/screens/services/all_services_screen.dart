import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:empleame/data/mock_data.dart';
import 'package:empleame/utils/icon_mapper.dart';
import 'package:empleame/widgets/home/service_icon_item.dart';

class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              // TODO: Show more options
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 32,
          childAspectRatio: 0.85,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return ServiceIconItem(
            icon: IconMapper.getIcon(service.icon),
            label: service.name,
            color: IconMapper.parseColor(service.iconColor),
            onTap: () {
              // Navigate to popular services filtered by this category
              context.push('/popular-services?category=${service.name}');
            },
          );
        },
      ),
    );
  }
}
