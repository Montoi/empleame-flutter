import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:empleame/providers/providers.dart';
import 'package:empleame/providers/services_provider.dart';
import 'package:empleame/models/service_model.dart';
import 'package:empleame/widgets/common/section_header.dart';
import 'package:empleame/widgets/home/app_header.dart';
import 'package:empleame/widgets/home/search_bar_widget.dart';
import 'package:empleame/widgets/home/offer_carousel.dart';
import 'package:empleame/widgets/home/services_grid.dart';
import 'package:empleame/widgets/home/popular_services_section.dart';
import 'package:empleame/data/mock_data.dart' show specialOffers;
import 'package:empleame/config/app_categories.dart';
import 'package:empleame/screens/profile/notifications_screen.dart';
import 'package:empleame/screens/home/bookmarks_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserStreamProvider);
    final user = userAsync.valueOrNull;

    // Compute a time-based greeting key
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? tr('home.goodMorning')
        : hour < 18
        ? tr('home.goodAfternoon')
        : tr('home.goodEvening');

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header — real user data from Firestore
            SliverToBoxAdapter(
              child: AppHeader(
                userName: user?.displayName.isNotEmpty == true
                    ? user!.displayName
                    : tr('home.welcome'),
                greeting: greeting,
                profileImageUrl: user?.photoUrl.isNotEmpty == true
                    ? user!.photoUrl
                    : null,
                role: user?.role,
                onNotificationTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                onBookmarkTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookmarksScreen(),
                    ),
                  );
                },
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: SearchBarWidget(
                hintText: tr('home.searchHint'),
                onFilterTap: () {},
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 4)),

            // Special Offers Section
            SliverToBoxAdapter(
              child: SectionHeader(
                title: tr('home.specialOffers'),
                onSeeAll: () => context.push('/special-offers'),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 4)),

            const SliverToBoxAdapter(
              child: OfferCarousel(offers: specialOffers),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Services Section
            SliverToBoxAdapter(
              child: SectionHeader(
                title: tr('home.services'),
                onSeeAll: () => context.push('/all-services'),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 4)),

            SliverToBoxAdapter(
              child: ServicesGrid(
                services: _buildGridServices(context),
                onServiceTap: (index) {
                  final items = _buildGridServices(context);
                  final item = items[index];
                  if (item.categoryId == 'more') {
                    context.push('/all-services');
                    return;
                  }
                  // item.id holds the technical category id
                  final uri = Uri(
                    path: '/popular-services',
                    queryParameters: {'category': item.categoryId},
                  );
                  context.push(uri.toString());
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Popular Services Section
            SliverToBoxAdapter(
              child: SectionHeader(
                title: tr('home.popularServices'),
                onSeeAll: () => context.push('/popular-services'),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 4)),

            SliverToBoxAdapter(
              child: ref
                  .watch(popularServicesProvider)
                  .when(
                    data: (services) {
                      if (services.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              tr('home.noServices'),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return PopularServicesSection(
                        categories: AppCategories.filterIds,
                        resolveLabel: (id) => id == 'all'
                            ? tr('filter.all')
                            : tr(AppCategories.byId(id)?.localizationKey ?? id),
                        services: _convertLivePopularServices(
                          context,
                          services,
                        ),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, stack) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(height: 8),
                            Text(tr('home.errorLoading')),
                            TextButton(
                              onPressed: () =>
                                  ref.invalidate(popularServicesProvider),
                              child: Text(tr('common.retry')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  /// Builds the 8-item grid list: first 7 AppCategories + a 'Más' tile.
  List<ServiceData> _buildGridServices(BuildContext context) {
    final items = AppCategories.all.take(7).map((cat) {
      return ServiceData(
        categoryId: cat.id,
        icon: cat.icon,
        label: tr(cat.localizationKey),
        color: cat.color,
      );
    }).toList();
    // 'Más' tile navigates to AllServicesScreen
    items.add(
      ServiceData(
        categoryId: 'more',
        icon: Icons.more_horiz,
        label: tr('home.more'),
        color: const Color(0xFF64748B),
      ),
    );
    return items;
  }

  List<ServiceCardData> _convertLivePopularServices(
    BuildContext context,
    List<ServiceModel> activeServices,
  ) {
    return activeServices.map((service) {
      return ServiceCardData(
        title: service.title,
        category: service.category,
        provider:
            'Worker Name', // TODO: join with user table or store denormalized names
        price: service.rate,
        rating: 5.0, // TODO: store real rating in ServiceModel
        reviews: 0,
        imageUrl: service.imageUrls.isNotEmpty ? service.imageUrls.first : '',
        isBookmarked: false,
        onTap: () {
          // Navigation logic strictly relies on ID to support deep linking and
          // provider family caching in ServiceDetailScreen
          context.push('/service-detail/${service.id}');
        },
        onBookmark: () {},
      );
    }).toList();
  }
}
