import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:empleame/widgets/home/service_card.dart';
import 'package:empleame/providers/providers.dart';
import 'package:empleame/providers/services_provider.dart';
import 'package:empleame/config/app_categories.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bookmarkedAsync = ref.watch(bookmarkedServicesProvider);
    final user = ref.watch(currentUserStreamProvider).valueOrNull;

    // Filter Logic setup
    // Index 0 represents "All"
    // Other indices represent AppCategories.all[index - 1]
    final categoriesCount = AppCategories.all.length + 1;

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
        title: Text(
          tr('bookmarks.title'),
          style: const TextStyle(
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
              itemCount: categoriesCount,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                final label = index == 0
                    ? tr('bookmarks.all')
                    : tr(AppCategories.all[index - 1].localizationKey);

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(
                      label,
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
            child: bookmarkedAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (services) {
                // Apply filter locally
                final filteredServices = _selectedCategoryIndex == 0
                    ? services
                    : services
                          .where(
                            (s) =>
                                AppCategories.matchCategory(s.category)?.id ==
                                AppCategories
                                    .all[_selectedCategoryIndex - 1]
                                    .id,
                          )
                          .toList();

                if (filteredServices.isEmpty) {
                  return Center(
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
                          tr('bookmarks.noBookmarks'),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  itemCount: filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = filteredServices[index];
                    final isBookmarked =
                        user?.savedServices.contains(service.id) ?? false;

                    return ServiceCard(
                      title: service.title,
                      category: service.category,
                      provider: service
                          .workerId, // Ideally we would fetch the worker's name
                      price: service.rate,
                      rating: 4.8, // Mocked until reviews are built
                      reviews: 120, // Mocked
                      imageUrl: service.imageUrls.isNotEmpty
                          ? service.imageUrls.first
                          : null,
                      isBookmarked: isBookmarked,
                      onTap: () {
                        context.push('/service-detail/${service.id}');
                      },
                      onBookmark: () {
                        if (user != null) {
                          ref
                              .read(userRepositoryProvider)
                              .toggleSavedService(
                                uid: user.uid,
                                serviceId: service.id,
                                save: !isBookmarked,
                              );
                        }
                      },
                    );
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
