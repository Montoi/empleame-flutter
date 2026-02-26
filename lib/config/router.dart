import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:empleame/widgets/navigation/bottom_nav_scaffold.dart';
import 'package:empleame/screens/services/all_services_screen.dart';
import 'package:empleame/screens/services/popular_services_screen.dart';
import 'package:empleame/screens/services/special_offers_screen.dart';
import 'package:empleame/screens/services/service_detail_screen.dart';
import 'package:empleame/screens/auth/welcome_screen.dart';
import 'package:empleame/screens/auth/login_screen.dart';
import 'package:empleame/screens/auth/sign_up_screen.dart';
import 'package:empleame/services/auth_service.dart';

GoRouter createRouter(AuthService authService) {
  return GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) {
      final isAuthenticated = authService.currentUser != null;
      final isAuthRoute =
          state.matchedLocation == '/welcome' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/sign-up';

      // If user is authenticated and on auth screen, redirect to home
      if (isAuthenticated && isAuthRoute) {
        return '/';
      }

      // If user is not authenticated and not on auth screen, redirect to welcome
      if (!isAuthenticated && !isAuthRoute) {
        return '/welcome';
      }

      // No redirect needed
      return null;
    },
    refreshListenable: _AuthStateNotifier(authService),
    routes: [
      // Auth Routes
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(authService: authService),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => SignUpScreen(authService: authService),
      ),

      // Main App Routes
      GoRoute(
        path: '/',
        builder: (context, state) =>
            BottomNavScaffold(authService: authService),
      ),
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
      GoRoute(
        path: '/service-detail',
        builder: (context, state) {
          final p = state.uri.queryParameters;
          return ServiceDetailScreen(
            title: p['title'] ?? 'Servicio',
            provider: p['provider'] ?? '',
            category: p['category'] ?? '',
            image: p['image'] ?? '',
            price: double.tryParse(p['price'] ?? '0') ?? 0,
            rating: double.tryParse(p['rating'] ?? '4.8') ?? 4.8,
            reviewCount: int.tryParse(p['reviewCount'] ?? '0') ?? 0,
          );
        },
      ),
    ],
  );
}

// Listenable that notifies GoRouter when auth state changes
class _AuthStateNotifier extends ChangeNotifier {
  final AuthService _authService;

  _AuthStateNotifier(this._authService) {
    _authService.authStateChanges.listen((_) {
      notifyListeners();
    });
  }
}
