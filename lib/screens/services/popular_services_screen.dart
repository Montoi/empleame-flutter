import 'package:flutter/material.dart';
import 'package:empleame/data/mock_data.dart';
import 'package:empleame/widgets/home/service_card.dart';

class PopularServicesScreen extends StatefulWidget {
  final String? category;

  const PopularServicesScreen({super.key, this.category});

  @override
  State<PopularServicesScreen> createState() => _PopularServicesScreenState();
}

class _PopularServicesScreenState extends State<PopularServicesScreen> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    // Filter services by category
    final filteredServices = _selectedCategory == 'All'
        ? popularServices
        : popularServices
              .where((s) => s.category == _selectedCategory)
              .toList();

    final headerTitle = widget.category != null
        ? '${widget.category} Services'
        : 'Most Popular Services';

    return Scaffold(
      appBar: AppBar(
        title: Text(headerTitle),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),

          // Services List
          Expanded(
            child: filteredServices.isEmpty
                ? Center(
                    child: Text(
                      'No services found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = filteredServices[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ServiceCard(
                          title: service.title,
                          category: service.category,
                          provider: service.provider,
                          price: service.price,
                          rating: service.rating,
                          reviews: service.reviewCount,
                          imageUrl: service.image,
                          isBookmarked: service.isBookmarked,
                          onTap: () {
                            // TODO: Navigate to service detail
                          },
                          onBookmark: () {
                            // TODO: Toggle bookmark
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
