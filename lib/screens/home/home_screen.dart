import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:empleame/widgets/common/section_header.dart';
import 'package:empleame/widgets/home/app_header.dart';
import 'package:empleame/widgets/home/search_bar_widget.dart';
import 'package:empleame/widgets/home/offer_carousel.dart';
import 'package:empleame/widgets/home/services_grid.dart';
import 'package:empleame/widgets/home/popular_services_section.dart';
import 'package:empleame/data/mock_data.dart';
import 'package:empleame/utils/icon_mapper.dart';
import 'package:empleame/screens/profile/notifications_screen.dart';
import 'package:empleame/screens/home/bookmarks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: AppHeader(
                userName: userData.name,
                greeting: userData.greeting,
                profileImageUrl: userData.avatar,
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
                hintText: 'Buscar servicios...',
                onFilterTap: () {},
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Special Offers Section
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Ofertas Especiales',
                onSeeAll: () => context.push('/special-offers'),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            const SliverToBoxAdapter(
              child: OfferCarousel(offers: specialOffers),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Services Section
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Servicios',
                onSeeAll: () => context.push('/all-services'),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            SliverToBoxAdapter(
              child: ServicesGrid(
                services: _convertServices().take(7).toList(),
                onServiceTap: (index) {
                  final service = _convertServices().toList()[index];
                  context.push('/popular-services?category=${service.label}');
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Popular Services Section
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Servicios Más Populares',
                onSeeAll: () => context.push('/popular-services'),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            SliverToBoxAdapter(
              child: PopularServicesSection(
                categories: categories,
                services: _convertPopularServices().take(5).toList(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  List<ServiceData> _convertServices() {
    return services.map((service) {
      return ServiceData(
        icon: IconMapper.getIcon(service.icon),
        label: service.name,
        color: IconMapper.parseColor(service.iconColor),
      );
    }).toList();
  }

  List<ServiceCardData> _convertPopularServices() {
    return popularServices.map((service) {
      return ServiceCardData(
        title: service.title,
        category: service.category,
        provider: service.provider,
        price: service.price,
        rating: service.rating,
        reviews: service.reviewCount,
        imageUrl: service.image,
        isBookmarked: service.isBookmarked,
        onTap: () {
          // Handle service tap
        },
        onBookmark: () {
          // Handle bookmark
        },
      );
    }).toList();
  }
}
