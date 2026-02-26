import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:empleame/screens/home/home_screen.dart';
import 'package:empleame/screens/bookings/bookings_screen.dart';
import 'package:empleame/screens/referrals/referrals_screen.dart';
import 'package:empleame/screens/profile/profile_screen.dart';
import 'package:empleame/services/auth_service.dart';

class BottomNavScaffold extends StatefulWidget {
  final AuthService? authService;

  const BottomNavScaffold({super.key, this.authService});

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  late final PageController _pageController;
  int _currentIndex = 0;

  // List of screens for PageView
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _screens = [
      const HomeScreen(),
      const BookingsScreen(),
      const ReferralsScreen(),
      ProfileScreen(authService: widget.authService),
    ];
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
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        // DragStartBehavior.down: gesture tracking starts from first touch,
        // so the page settles faster and releases the gesture arena sooner.
        dragStartBehavior: DragStartBehavior.down,
        // ClampingScrollPhysics: page snaps sharply with no elastic bounce,
        // releasing vertical scroll in the new tab immediately.
        physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigationTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Reservas',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Referidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
