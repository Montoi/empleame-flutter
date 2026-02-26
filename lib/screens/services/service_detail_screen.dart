import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:empleame/data/mock_data.dart';
import 'package:empleame/widgets/service_detail/detail_header.dart';
import 'package:empleame/widgets/service_detail/info_section.dart';
import 'package:empleame/widgets/service_detail/about_section.dart';
import 'package:empleame/widgets/service_detail/photos_section.dart';
import 'package:empleame/widgets/service_detail/reviews_section.dart';
import 'package:empleame/widgets/service_detail/bottom_action_tab.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String title;
  final String provider;
  final String category;
  final String image;
  final double price;
  final double rating;
  final int reviewCount;

  const ServiceDetailScreen({
    super.key,
    required this.title,
    required this.provider,
    required this.category,
    required this.image,
    required this.price,
    required this.rating,
    required this.reviewCount,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DetailHeader(
                  imageUrl: widget.image,
                  onBack: () => context.pop(),
                  onShare: () {},
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    InfoSection(
                      title: widget.title,
                      provider: widget.provider,
                      category: widget.category,
                      rating: widget.rating,
                      reviewCount: widget.reviewCount,
                      price: widget.price,
                      isBookmarked: _isBookmarked,
                      onBookmark: () =>
                          setState(() => _isBookmarked = !_isBookmarked),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const AboutSection(
                      text:
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    PhotosSection(photos: mockPhotos, onSeeAll: () {}),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    ReviewsSection(
                      rating: widget.rating,
                      reviewCount: widget.reviewCount,
                      serviceTitle: widget.title,
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
