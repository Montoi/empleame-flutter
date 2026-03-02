import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:empleame/data/mock_data.dart';
import 'package:empleame/models/service_model.dart';
import 'package:empleame/widgets/service_detail/detail_header.dart';
import 'package:empleame/widgets/service_detail/info_section.dart';
import 'package:empleame/widgets/service_detail/about_section.dart';
import 'package:empleame/widgets/service_detail/photos_section.dart';
import 'package:empleame/widgets/service_detail/reviews_section.dart';
import 'package:empleame/widgets/service_detail/bottom_action_tab.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:empleame/providers/my_services_provider.dart';
import 'package:empleame/providers/services_provider.dart';

/// Displays a service's details.
///
/// **Legacy mode** (existing catalog): pass the flat [title], [provider], etc.
/// **Preview mode** (worker form): pass a [service] model and optionally
///   [localImages] so the worker sees their real photos inside the detail UI.
class ServiceDetailScreen extends ConsumerStatefulWidget {
  // ── ID approach (Deeplinking) ──────────────────────────────────────────────
  /// The Firestore ID of the service to fetch.
  final String? serviceId;

  // ── Preview-mode params ──────────────────────────────────────────────────
  /// When provided, this model's fields override the fetched data.
  final ServiceModel? service;

  /// Local files selected in the form — shown in the header and photos grid.
  final List<File>? localImages;

  // ── Admin-mode params ────────────────────────────────────────────────────
  /// When true, replaces the normal BottomActionTabs with Approve/Reject buttons
  final bool isAdminView;

  const ServiceDetailScreen({
    super.key,
    this.serviceId,
    // Preview mode
    this.service,
    this.localImages,
    // Admin mode
    this.isAdminView = false,
  });

  @override
  ConsumerState<ServiceDetailScreen> createState() =>
      _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends ConsumerState<ServiceDetailScreen> {
  bool _isBookmarked = false;

  Widget _buildContent(ServiceModel? resolvedService, bool isPreview) {
    // Resolved fields — prefer service model, then fallback to mock/defaults
    final String title = resolvedService?.title ?? '';
    final String provider = 'Tú'; // TODO: Provider lookup based on workerId
    final String category = resolvedService?.category ?? '';
    final double price = resolvedService?.rate ?? 0.0;
    // Mock rating/reviews for now, until added to ServiceModel
    final double rating = 5.0;
    final int reviewCount = 0;

    /// First image to show in the header.
    final String? remoteImage = resolvedService?.imageUrls.isNotEmpty == true
        ? resolvedService!.imageUrls.first
        : null;

    final File? localHeaderImage = widget.localImages?.isNotEmpty == true
        ? widget.localImages!.first
        : null;

    /// All photos for the gallery section.
    final List<String> remotePhotos =
        resolvedService?.imageUrls.isNotEmpty == true
        ? resolvedService!.imageUrls
        : mockPhotos;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DetailHeader(
                  imageUrl: localHeaderImage == null ? remoteImage : null,
                  imageFile: localHeaderImage,
                  onBack: () => context.pop(),
                  onShare: () {},
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Preview banner
                    if (isPreview)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFBBF24),
                            width: 1.5,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              color: Color(0xFFD97706),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Vista previa — así verán tu servicio los clientes',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFD97706),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    InfoSection(
                      title: title,
                      provider: provider,
                      category: category,
                      rating: rating,
                      reviewCount: reviewCount,
                      price: price,
                      isBookmarked: _isBookmarked,
                      onBookmark: () =>
                          setState(() => _isBookmarked = !_isBookmarked),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    AboutSection(
                      text: resolvedService?.description.isNotEmpty == true
                          ? resolvedService!.description
                          : 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    // Photos section — local files or remote URLs
                    if (widget.localImages?.isNotEmpty == true)
                      _LocalPhotosSection(files: widget.localImages!)
                    else
                      PhotosSection(photos: remotePhotos, onSeeAll: () {}),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    if (!isPreview)
                      ReviewsSection(
                        rating: rating,
                        reviewCount: reviewCount,
                        serviceTitle: title,
                        allReviews: mockReviews,
                      ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: widget.isAdminView
                ? _AdminActionTab(service: resolvedService)
                : BottomActionTab(onMessage: () {}, onBook: () {}),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPreview = widget.service != null || widget.localImages != null;

    // Fast-path: Preview Mode (Form injected data)
    if (isPreview) {
      return _buildContent(widget.service, isPreview);
    }

    // Require ID for live mode
    if (widget.serviceId == null || widget.serviceId!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Service ID not provided')),
      );
    }

    // Watch live provider
    final asyncService = ref.watch(serviceDetailProvider(widget.serviceId!));

    return asyncService.when(
      data: (service) {
        if (service == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Servicio no encontrado o retirado',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          );
        }
        return _buildContent(service, false);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Error al cargar el servicio'),
              TextButton(
                onPressed: () =>
                    ref.invalidate(serviceDetailProvider(widget.serviceId!)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Admin Actions tab ────────────────────────────────────────────────────────

class _AdminActionTab extends ConsumerWidget {
  final ServiceModel? service;

  const _AdminActionTab({required this.service});

  Future<void> _handleApprove(BuildContext context, WidgetRef ref) async {
    if (service == null) return;
    final repo = ref.read(serviceRepositoryProvider);
    try {
      await repo.updateServiceStatus(service!.id, 'active');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Servicio aprobado.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      ref.invalidate(pendingServicesProvider);
      context.pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al aprobar: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _handleReject(BuildContext context, WidgetRef ref) async {
    if (service == null) return;
    final notesController = TextEditingController();
    final shouldReject = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rechazar Servicio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Provee una razón para el rechazo (opcional):'),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Notas del administrador...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
              ),
              child: const Text('Rechazar'),
            ),
          ],
        );
      },
    );

    if (shouldReject == true) {
      final repo = ref.read(serviceRepositoryProvider);
      try {
        await repo.updateServiceStatus(
          service!.id,
          'rejected',
          adminNotes: notesController.text.trim().isNotEmpty
              ? notesController.text.trim()
              : null,
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Servicio rechazado.'),
            backgroundColor: Color(0xFFF59E0B),
          ),
        );
        ref.invalidate(pendingServicesProvider);
        context.pop();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al rechazar: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.paddingOf(context).bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _handleReject(context, ref),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                foregroundColor: const Color(0xFFEF4444),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              child: const Text('Rechazar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleApprove(context, ref),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              child: const Text('Aprobar'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Local photos section ──────────────────────────────────────────────────────

class _LocalPhotosSection extends StatelessWidget {
  final List<File> files;
  const _LocalPhotosSection({required this.files});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fotos y Videos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: files.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  files[i],
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
