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
            icon: const Icon(Icons.more_horiz, color: Color(0xFF0F172A)),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.filter_list),
                        title: const Text('Filter'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.sort),
                        title: const Text('Sort'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.refresh),
                        title: const Text('Refresh'),
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
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
        itemCount: services.where((s) => s.name != 'More').length,
        itemBuilder: (context, index) {
          final service = services
              .where((s) => s.name != 'More')
              .toList()[index];
          return ServiceIconItem(
            icon: IconMapper.getIcon(service.icon),
            label: service.name,
            color: IconMapper.parseColor(service.iconColor),
            onTap: () {
              // Navigate to popular services filtered by this category
              // Using Uri to properly encode parameters (handles special chars like ' & spaces)
              final uri = Uri(
                path: '/popular-services',
                queryParameters: {'category': service.name},
              );
              context.push(uri.toString());
            },
          );
        },
      ),
    );
  }
}
