import 'package:go_router/go_router.dart';
import './screens/login_screen.dart';
import './screens/resident_home_screen.dart';
import './screens/guard_home_screen.dart';
import './screens/signup_screen.dart';
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => SignupScreen(),
    ),
    GoRoute(
      path: '/resident_home',
      builder: (context, state) => ResidentHomeScreen(),
    ),
    GoRoute(
      path: '/guard_home',
      builder: (context, state) => GuardHomeScreen(),
    ),
  ],
);