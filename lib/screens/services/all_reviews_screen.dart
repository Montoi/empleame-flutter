import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:empleame/models/home_models.dart';

const _primary = Color(0xFF7210FF);
const _primaryLight = Color(0xFFF3ECFF);

/// Full reviews screen — uses SliverList.builder for O(1) memory regardless
/// of how many reviews exist. Only visible items are built at any time.
class AllReviewsScreen extends StatefulWidget {
  final String serviceTitle;
  final double rating;
  final int reviewCount;
  final List<Review> reviews;

  const AllReviewsScreen({
    super.key,
    required this.serviceTitle,
    required this.rating,
    required this.reviewCount,
    required this.reviews,
  });

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  String _selectedRating = 'All';

  List<Review> get _filtered {
    if (_selectedRating == 'All') return widget.reviews;
    return widget.reviews
        .where((r) => r.rating.toInt().toString() == _selectedRating)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0F172A),
            elevation: 0,
            surfaceTintColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.serviceTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.rating} · ${widget.reviewCount} reseñas',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Sticky filter chips ───────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterHeaderDelegate(
              selected: _selectedRating,
              onSelect: (r) => setState(() => _selectedRating = r),
            ),
          ),

          // ── Empty state ───────────────────────────────────────────────
          if (filtered.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'No hay reseñas para este filtro.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            // ── Lazy list — only visible items are built ──────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              sliver: SliverList.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: ReviewCard(review: filtered[index]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Sticky filter bar ─────────────────────────────────────────────────────────

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String selected;
  final ValueChanged<String> onSelect;

  const _FilterHeaderDelegate({required this.selected, required this.onSelect});

  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 56;

  @override
  bool shouldRebuild(_FilterHeaderDelegate old) => old.selected != selected;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        scrollDirection: Axis.horizontal,
        children: ['All', '5', '4', '3', '2'].map((rate) {
          final active = selected == rate;
          return GestureDetector(
            onTap: () => onSelect(rate),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: active ? _primary : Colors.white,
                border: Border.all(
                  color: active ? _primary : const Color(0xFFE2E8F0),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 12,
                    color: active ? Colors.white : _primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    rate,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: active ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Reusable review card (also imported by reviews_section.dart) ──────────────

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: CachedNetworkImage(
                imageUrl: review.avatar,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                placeholder: (ctx, url) =>
                    Container(width: 44, height: 44, color: Colors.grey[200]),
                errorWidget: (ctx, url, err) =>
                    const CircleAvatar(radius: 22, child: Icon(Icons.person)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.user,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    review.time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryLight,
                    border: Border.all(color: _primary.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 10, color: _primary),
                      const SizedBox(width: 4),
                      Text(
                        review.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.more_horiz,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          review.content,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF475569),
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.favorite, size: 16, color: Color(0xFFEF4444)),
            const SizedBox(width: 6),
            Text(
              '${review.likes}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
