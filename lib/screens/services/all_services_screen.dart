import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:empleame/config/app_categories.dart';
import 'package:empleame/widgets/home/service_icon_item.dart';

class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos los Servicios'),
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
          childAspectRatio: 0.75,
        ),
        itemCount: AppCategories.all.length,
        itemBuilder: (context, index) {
          final category = AppCategories.all[index];
          return ServiceIconItem(
            icon: category.icon,
            label: tr(category.localizationKey),
            color: category.color,
            onTap: () {
              // Pass the technical ID as query param — locale-independent,
              // matches correctly against Firestore `category` field.
              final uri = Uri(
                path: '/popular-services',
                queryParameters: {'category': category.id},
              );
              context.push(uri.toString());
            },
          );
        },
      ),
    );
  }
}
