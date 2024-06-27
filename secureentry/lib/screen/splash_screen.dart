import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => redirect());
  }

  Future<void> redirect() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        final userRole = await _getUserRole(session.user.id);
        if (userRole != null) {
          switch (userRole) {
            case 'admin':
              context.go('/admin_approval');
              break;
            case 'resident':
              context.go('/resident_home');
              break;
            case 'guard':
              context.go('/guard_home');
              break;
            default:
              context.go('/');
          }
        } else {
          context.go('/');
        }
      } else {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        print('Error on splash screen: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error on splash screen: $e'),
          ),
        );
        context.go('/');
      }
    }
  }

  Future<String?> _getUserRole(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('user_roles')
          .select('role')
          .eq('id', userId)
          .single();

      return response['role'] as String?;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching user role on splash screen: $e'),
          ),
        );
      }
      print('Error fetching user role on splash screen: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
