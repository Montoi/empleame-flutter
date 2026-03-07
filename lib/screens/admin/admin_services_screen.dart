import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:empleame/models/service_model.dart';
import 'package:empleame/providers/locale_provider.dart';
import 'package:empleame/providers/my_services_provider.dart';
import 'package:empleame/screens/services/service_detail_screen.dart';

class AdminServicesScreen extends ConsumerWidget {
  const AdminServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final pendingAsync = ref.watch(pendingServicesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Text(
          tr('admin.validateServices'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        leading: const BackButton(color: Color(0xFF0F172A)),
      ),
      body: pendingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(tr('admin.error', namedArgs: {'error': e.toString()})),
        ),
        data: (services) {
          if (services.isEmpty) {
            return RefreshIndicator(
              color: const Color(0xFF7210FF),
              onRefresh: () async =>
                  ref.refresh(pendingServicesProvider.future),
              child: Stack(
                children: [
                  ListView(),
                  Center(
                    child: Text(
                      tr('admin.noServices'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF7210FF),
            onRefresh: () async => ref.refresh(pendingServicesProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return _AdminServiceCard(service: service);
              },
            ),
          );
        },
      ),
    );
  }
}

class _AdminServiceCard extends StatelessWidget {
  final ServiceModel service;

  const _AdminServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final thumb = service.imageUrls.isNotEmpty ? service.imageUrls.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ServiceDetailScreen(service: service, isAdminView: true),
              ),
            );
          },
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
                child: thumb != null
                    ? CachedNetworkImage(
                        imageUrl: thumb,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 90,
                        height: 90,
                        color: const Color(0xFFF3ECFF),
                        child: const Icon(
                          Icons.work_outline,
                          color: Color(0xFF7210FF),
                          size: 32,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tr(
                          'admin.workerId',
                          namedArgs: {'id': service.workerId},
                        ),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '\$${service.rate.toStringAsFixed(0)}/h',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7210FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
