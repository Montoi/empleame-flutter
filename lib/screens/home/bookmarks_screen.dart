import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:empleame/widgets/home/service_card.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final List<String> categories = [
    'All',
    'Cleaning',
    'Repairing',
    'Painting',
    'Laundry',
    'Appliance',
    'Plumbing',
    'Shifting',
  ];

  int _selectedCategoryIndex = 0;

  // Mock data for bookmarks
  final List<Map<String, dynamic>> _allBookmarks = [
    {
      'title': 'House Cleaning',
      'category': 'Cleaning',
      'provider': 'Jenny Wilson',
      'price': 25.0,
      'rating': 4.8,
      'reviews': 820, // 4.8k reviews logic in component
      'imageUrl': 'https://i.pravatar.cc/300?img=1',
    },
    {
      'title': 'Washing Machine Repair',
      'category': 'Repairing',
      'provider': 'Guy Hawkins',
      'price': 40.0,
      'rating': 4.7,
      'reviews': 1200,
      'imageUrl': 'https://i.pravatar.cc/300?img=2',
    },
    {
      'title': 'Bathroom Cleaning',
      'category': 'Cleaning',
      'provider': 'Esther Howard',
      'price': 30.0,
      'rating': 4.9,
      'reviews': 6500, // 6.5k
      'imageUrl': 'https://i.pravatar.cc/300?img=3',
    },
    {
      'title': 'Kitchen Painting',
      'category': 'Painting',
      'provider': 'Robert Fox',
      'price': 55.0,
      'rating': 4.6,
      'reviews': 320,
      'imageUrl': 'https://i.pravatar.cc/300?img=4',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final currentCategory = categories[_selectedCategoryIndex];
    final filteredBookmarks = currentCategory == 'All'
        ? _allBookmarks
        : _allBookmarks
              .where((item) => item['category'] == currentCategory)
              .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Off-white background
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: false,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Center(
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(20),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
              ),
            ),
          ),
        ),
        title: const Text(
          'My Bookmark',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: IconButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.more_horiz,
                  size: 20,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Category Filter
          SizedBox(
            height: 40,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(
                      categories[index],
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
                        _selectedCategoryIndex = index;
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
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Bookmarks List
          Expanded(
            child: filteredBookmarks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bookmarks yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    itemCount: filteredBookmarks.length,
                    itemBuilder: (context, index) {
                      final item = filteredBookmarks[index];
                      return ServiceCard(
                        title: item['title'],
                        category: item['category'],
                        provider: item['provider'],
                        price: item['price'],
                        rating: item['rating'],
                        reviews: item['reviews'],
                        imageUrl: item['imageUrl'],
                        isBookmarked: true, // Always true for bookmarks screen
                        onTap: () {
                          // Handle navigation to details
                        },
                        onBookmark: () {
                          // Handle remove bookmark logic
                          setState(() {
                            // In a real app this would update state management
                            // For mock only:
                            // _allBookmarks.remove(item); // Don't remove for now to keep demo data
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
