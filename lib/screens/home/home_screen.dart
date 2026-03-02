import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:empleame/providers/providers.dart';
import 'package:empleame/providers/services_provider.dart';
import 'package:empleame/models/service_model.dart';
import 'package:empleame/widgets/common/section_header.dart';
import 'package:empleame/widgets/home/app_header.dart';
import 'package:empleame/widgets/home/search_bar_widget.dart';
import 'package:empleame/widgets/home/offer_carousel.dart';
import 'package:empleame/widgets/home/services_grid.dart';
import 'package:empleame/widgets/home/popular_services_section.dart';
import 'package:empleame/data/mock_data.dart'
    show categories, specialOffers, services;
import 'package:empleame/utils/icon_mapper.dart';
import 'package:empleame/screens/profile/notifications_screen.dart';
import 'package:empleame/screens/home/bookmarks_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserStreamProvider);
    final user = userAsync.valueOrNull;

    // Compute a time-based greeting
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Buenos días'
        : hour < 18
        ? 'Buenas tardes'
        : 'Buenas noches';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header — real user data from Firestore
            SliverToBoxAdapter(
              child: AppHeader(
                userName: user?.displayName.isNotEmpty == true
                    ? user!.displayName
                    : 'Bienvenido',
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
                hintText: 'Buscar servicios...',
                onFilterTap: () {},
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 4)),

            // Special Offers Section
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Ofertas Especiales',
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
                title: 'Servicios',
                onSeeAll: () => context.push('/all-services'),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 4)),

            SliverToBoxAdapter(
              child: ServicesGrid(
                services: [
                  ..._convertServices().take(7),
                  _convertServices().firstWhere(
                    (s) => s.label == 'More',
                    orElse: () => _convertServices().last,
                  ),
                ],
                onServiceTap: (index) {
                  final displayedServices = [
                    ..._convertServices().take(7),
                    _convertServices().firstWhere(
                      (s) => s.label == 'More',
                      orElse: () => _convertServices().last,
                    ),
                  ];
                  final service = displayedServices[index];

                  if (service.label == 'More') {
                    context.push('/all-services');
                    return;
                  }

                  final uri = Uri(
                    path: '/popular-services',
                    queryParameters: {'category': service.label},
                  );
                  context.push(uri.toString());
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Popular Services Section
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Servicios Más Populares',
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
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No hay servicios populares disponibles aún.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return PopularServicesSection(
                        categories: categories,
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
                            const Text('Error al cargar servicios'),
                            TextButton(
                              onPressed: () =>
                                  ref.invalidate(popularServicesProvider),
                              child: const Text('Reintentar'),
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

  List<ServiceData> _convertServices() {
    return services.map((service) {
      return ServiceData(
        icon: IconMapper.getIcon(service.icon),
        label: service.name,
        color: IconMapper.parseColor(service.iconColor),
      );
    }).toList();
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
