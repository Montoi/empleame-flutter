import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:empleame/screens/home/home_screen.dart';
import 'package:empleame/screens/bookings/bookings_screen.dart';
import 'package:empleame/screens/referrals/referrals_screen.dart';
import 'package:empleame/screens/profile/profile_screen.dart';
import 'package:empleame/screens/admin/admin_screen.dart';
import 'package:empleame/services/auth_service.dart';
import 'package:empleame/providers/providers.dart';
import 'package:empleame/models/user_model.dart';

class BottomNavScaffold extends ConsumerStatefulWidget {
  final AuthService? authService;

  const BottomNavScaffold({super.key, this.authService});

  @override
  ConsumerState<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends ConsumerState<BottomNavScaffold> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavigationTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserStreamProvider);
    final user = userAsync.valueOrNull;
    final isAdmin = user?.role == UserRole.admin;

    final screens = <Widget>[
      const HomeScreen(),
      const BookingsScreen(),
      if (isAdmin) const AdminScreen(),
      const ReferralsScreen(),
      ProfileScreen(authService: widget.authService),
    ];

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined, size: 22),
        selectedIcon: Icon(Icons.home, size: 22),
        label: 'Inicio',
      ),
      const NavigationDestination(
        icon: Icon(Icons.calendar_today_outlined, size: 22),
        selectedIcon: Icon(Icons.calendar_today, size: 22),
        label: 'Reservas',
      ),
      if (isAdmin)
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined, size: 22),
          selectedIcon: Icon(Icons.admin_panel_settings, size: 22),
          label: 'Admin',
        ),
      const NavigationDestination(
        icon: Icon(Icons.people_outline, size: 22),
        selectedIcon: Icon(Icons.people, size: 22),
        label: 'Referidos',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline, size: 22),
        selectedIcon: Icon(Icons.person, size: 22),
        label: 'Perfil',
      ),
    ];

    // Ensure _currentIndex is within bounds if role changes
    if (_currentIndex >= screens.length) {
      _currentIndex = screens.length - 1;
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        // DragStartBehavior.start (default) delays gesture recognition until
        // intentional movement is detected, fixing the "sticky swipe" issue.
        dragStartBehavior: DragStartBehavior.start,
        // Default PageScrollPhysics without Clamping prevents the gesture
        // arena from locking vertical scroll prematurely.
        physics: const PageScrollPhysics(),
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigationTapped,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        destinations: destinations,
      ),
    );
  }
}
