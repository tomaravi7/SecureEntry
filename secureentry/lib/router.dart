import 'package:go_router/go_router.dart';
import './screens/login_screen.dart';
import './screens/resident_home_screen.dart';
import './screens/guard_home_screen.dart';
import './screens/signup_screen.dart';
import './screens/admin_approval_screen.dart';
import './screens/splash_screen.dart';  // Import the new SplashScreen

final router = GoRouter(
  initialLocation: '/splash',  // Set the initial route to the splash screen
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => SplashScreen(),
    ),
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
    GoRoute(
      path: '/admin_approval',
      builder: (context, state) => AdminApprovalScreen(),
    ),
  ],
);