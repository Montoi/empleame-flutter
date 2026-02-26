import 'package:flutter/material.dart';
import 'package:empleame/models/home_models.dart';
import 'package:empleame/screens/services/all_reviews_screen.dart';

const _primary = Color(0xFF7210FF);

/// Shows up to 5 reviews inline. Tapping "Ver todo" pushes [AllReviewsScreen]
/// which uses SliverList.builder for performance with N reviews.
class ReviewsSection extends StatefulWidget {
  final double rating;
  final int reviewCount;
  final String serviceTitle;
  final List<Review> allReviews;

  const ReviewsSection({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.serviceTitle,
    required this.allReviews,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  String _selected = 'All';

  static const _maxInline = 5;

  List<Review> get _filtered {
    final all = _selected == 'All'
        ? widget.allReviews
        : widget.allReviews
              .where((r) => r.rating.toInt().toString() == _selected)
              .toList();
    // Cap at 5 for the inline view
    return all.take(_maxInline).toList();
  }

  void _openAllReviews() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AllReviewsScreen(
          serviceTitle: widget.serviceTitle,
          rating: widget.rating,
          reviewCount: widget.reviewCount,
          reviews: widget.allReviews,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _filtered;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, size: 20, color: Color(0xFFFFC107)),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.rating} (${widget.reviewCount} reseñas)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _openAllReviews,
                child: const Text(
                  'Ver todo',
                  style: TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          // Filter chips
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', '5', '4', '3', '2'].map((rate) {
                final active = _selected == rate;
                return GestureDetector(
                  onTap: () => setState(() => _selected = rate),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                            color: active
                                ? Colors.white
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Up to 5 reviews — uses shared ReviewCard
          if (reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
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
          else ...[
            ...List.generate(
              reviews.length,
              (i) => Padding(
                padding: EdgeInsets.only(
                  bottom: i < reviews.length - 1 ? 24 : 0,
                ),
                child: ReviewCard(review: reviews[i]),
              ),
            ),
            // "Ver todo" nudge when there are more
            if (widget.allReviews.length > _maxInline) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _openAllReviews,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Ver todas las reseñas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
