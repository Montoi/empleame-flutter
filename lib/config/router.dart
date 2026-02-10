import 'package:go_router/go_router.dart';
import 'package:empleame/widgets/navigation/bottom_nav_scaffold.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const BottomNavScaffold()),
  ],
);
