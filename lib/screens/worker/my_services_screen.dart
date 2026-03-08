import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:empleame/models/service_model.dart';
import 'package:empleame/providers/my_services_provider.dart';
import 'package:empleame/screens/worker/service_form_screen.dart';
import 'package:empleame/screens/services/service_detail_screen.dart';

class MyServicesScreen extends ConsumerStatefulWidget {
  const MyServicesScreen({super.key});

  @override
  ConsumerState<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends ConsumerState<MyServicesScreen> {
  static const _primary = Color(0xFF7210FF);
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(myServicesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mis Servicios',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        leading: const BackButton(color: Color(0xFF0F172A)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(serviceFormProvider.notifier).reset();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ServiceFormScreen()),
          );
        },
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nuevo servicio',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (services) {
          if (services.isEmpty) {
            return RefreshIndicator(
              color: _primary,
              onRefresh: () async => ref.refresh(myServicesProvider.future),
              child: Stack(children: [ListView(), const _EmptyState()]),
            );
          }
          return RefreshIndicator(
            color: _primary,
            onRefresh: () async => ref.refresh(myServicesProvider.future),
            child: Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  itemCount: services.length,
                  itemBuilder: (_, i) => _ServiceCard(
                    service: services[i],
                    onEdit: services[i].status == 'pending_review'
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No puedes editar un servicio que está en validación.',
                                ),
                              ),
                            );
                          }
                        : () {
                            ref
                                .read(serviceFormProvider.notifier)
                                .loadForEdit(services[i]);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ServiceFormScreen(editing: services[i]),
                              ),
                            );
                          },
                    onDelete: () => _confirmDelete(services[i].id),
                  ),
                ),
                if (_isDeleting)
                  Container(
                    color: Colors.white.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: _primary),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Eliminar servicio?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este servicio?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _isDeleting = true);
      try {
        await ref.read(serviceRepositoryProvider).deleteService(id);
        ref.invalidate(myServicesProvider);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isDeleting = false);
        }
      }
    }
  }
}

// ── Service card ──────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _statusColor => switch (service.status) {
    'active' => const Color(0xFF10B981),
    'rejected' => const Color(0xFFEF4444),
    _ => const Color(0xFFF59E0B), // pending_review
  };

  String get _statusLabel => switch (service.status) {
    'active' => 'Activo',
    'rejected' => 'Rechazado',
    _ => 'En revisión',
  };

  @override
  Widget build(BuildContext context) {
    final thumb = service.imageUrls.isNotEmpty ? service.imageUrls.first : null;
    final isPending = service.status == 'pending_review';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                builder: (_) => ServiceDetailScreen(service: service),
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
                        placeholder: (_, _) => Container(
                          width: 90,
                          height: 90,
                          color: const Color(0xFFF3ECFF),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, _, _) => Container(
                          width: 90,
                          height: 90,
                          color: const Color(0xFFF3ECFF),
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: Color(0xFF7210FF),
                          ),
                        ),
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
                        service.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _statusLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _statusColor,
                              ),
                            ),
                          ),
                          const Spacer(),
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
                    ],
                  ),
                ),
              ),
              // Actions
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: isPending
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF7210FF),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: const Color(0xFFEF4444),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF3ECFF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.work_outline,
            size: 40,
            color: Color(0xFF7210FF),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Aún no tienes servicios',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Crea tu primer servicio y empieza\na recibir solicitudes de clientes.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
      ],
    ),
  );
}
