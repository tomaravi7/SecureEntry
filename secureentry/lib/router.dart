import 'package:go_router/go_router.dart';
import './screen/login_screen.dart';
import './screen/resident_screen.dart';
import './screen/guard_screen.dart';
import './screen/signup_screen.dart';
import './screen/admin_approval_screen.dart';
import './screen/splash_screen.dart'; // Import the new SplashScreen

final router = GoRouter(
  initialLocation: '/splash', // Set the initial route to the splash screen
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUp(),
    ),
    GoRoute(
      path: '/resident_home',
      builder: (context, state) => const ResidentScreen(),
    ),
    GoRoute(
      path: '/guard_home',
      builder: (context, state) => const GuardScreen(),
    ),
    GoRoute(
      path: '/admin_approval',
      builder: (context, state) => const AdminScreen(),
    ),
  ],
);
