import 'package:go_router/go_router.dart';
import 'package:empleame/widgets/navigation/bottom_nav_scaffold.dart';
import 'package:empleame/screens/services/all_services_screen.dart';
import 'package:empleame/screens/services/popular_services_screen.dart';
import 'package:empleame/screens/services/special_offers_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const BottomNavScaffold()),
    GoRoute(
      path: '/all-services',
      builder: (context, state) => const AllServicesScreen(),
    ),
    GoRoute(
      path: '/popular-services',
      builder: (context, state) {
        final category = state.uri.queryParameters['category'];
        return PopularServicesScreen(category: category);
      },
    ),
    GoRoute(
      path: '/special-offers',
      builder: (context, state) => const SpecialOffersScreen(),
    ),
  ],
);
