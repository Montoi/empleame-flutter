import 'package:flutter/material.dart';
import 'service_card.dart';

class PopularServicesSection extends StatefulWidget {
  final List<String> categories;
  final List<ServiceCardData> services;

  const PopularServicesSection({
    super.key,
    required this.categories,
    required this.services,
  });

  @override
  State<PopularServicesSection> createState() => _PopularServicesSectionState();
}

class _PopularServicesSectionState extends State<PopularServicesSection> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    widget.categories[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  backgroundColor: Colors.transparent,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Service Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: widget.services.map((service) {
              return ServiceCard(
                title: service.title,
                category: service.category,
                provider: service.provider,
                price: service.price,
                rating: service.rating,
                reviews: service.reviews,
                imageUrl: service.imageUrl,
                isBookmarked: service.isBookmarked,
                onTap: service.onTap,
                onBookmark: service.onBookmark,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class ServiceCardData {
  final String title;
  final String category;
  final String provider;
  final double price;
  final double rating;
  final int reviews;
  final String? imageUrl;
  final bool isBookmarked;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;

  const ServiceCardData({
    required this.title,
    required this.category,
    required this.provider,
    required this.price,
    required this.rating,
    required this.reviews,
    this.imageUrl,
    this.isBookmarked = false,
    this.onTap,
    this.onBookmark,
  });
}
