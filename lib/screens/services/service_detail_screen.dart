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

/// Displays a service's details.
///
/// **Legacy mode** (existing catalog): pass the flat [title], [provider], etc.
/// **Preview mode** (worker form): pass a [service] model and optionally
///   [localImages] so the worker sees their real photos inside the detail UI.
class ServiceDetailScreen extends StatefulWidget {
  // ── Legacy params (catalog navigation) ─────────────────────────────────
  final String? title;
  final String? provider;
  final String? category;
  final String? image;
  final double? price;
  final double? rating;
  final int? reviewCount;

  // ── Preview-mode params ──────────────────────────────────────────────────
  /// When provided, this model's fields override the legacy params.
  final ServiceModel? service;

  /// Local files selected in the form — shown in the header and photos grid.
  final List<File>? localImages;

  const ServiceDetailScreen({
    super.key,
    // Legacy
    this.title,
    this.provider,
    this.category,
    this.image,
    this.price,
    this.rating,
    this.reviewCount,
    // Preview mode
    this.service,
    this.localImages,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _isBookmarked = false;

  // Resolved fields — prefer service model if present
  String get _title => widget.service?.title ?? widget.title ?? '';
  String get _provider => widget.provider ?? 'Tú';
  String get _category => widget.service?.category ?? widget.category ?? '';
  double get _price => widget.service?.rate ?? widget.price ?? 0;
  double get _rating => widget.rating ?? 0;
  int get _reviewCount => widget.reviewCount ?? 0;

  /// First image to show in the header.
  String? get _remoteImage => widget.service?.imageUrls.isNotEmpty == true
      ? widget.service!.imageUrls.first
      : widget.image;

  File? get _localHeaderImage =>
      widget.localImages?.isNotEmpty == true ? widget.localImages!.first : null;

  /// All photos for the gallery section.
  List<String> get _remotePhotos => widget.service?.imageUrls.isNotEmpty == true
      ? widget.service!.imageUrls
      : mockPhotos;

  @override
  Widget build(BuildContext context) {
    final isPreview = widget.service != null || widget.localImages != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DetailHeader(
                  imageUrl: _localHeaderImage == null ? _remoteImage : null,
                  imageFile: _localHeaderImage,
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
                            Text(
                              'Vista previa — así verán tu servicio los clientes',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFD97706),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    InfoSection(
                      title: _title,
                      provider: _provider,
                      category: _category,
                      rating: _rating,
                      reviewCount: _reviewCount,
                      price: _price,
                      isBookmarked: _isBookmarked,
                      onBookmark: () =>
                          setState(() => _isBookmarked = !_isBookmarked),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    AboutSection(
                      text: widget.service?.description.isNotEmpty == true
                          ? widget.service!.description
                          : 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    // Photos section — local files or remote URLs
                    if (widget.localImages?.isNotEmpty == true)
                      _LocalPhotosSection(files: widget.localImages!)
                    else
                      PhotosSection(photos: _remotePhotos, onSeeAll: () {}),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    if (!isPreview)
                      ReviewsSection(
                        rating: _rating,
                        reviewCount: _reviewCount,
                        serviceTitle: _title,
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
            child: BottomActionTab(onMessage: () {}, onBook: () {}),
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
