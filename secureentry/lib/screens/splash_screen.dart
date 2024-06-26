import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        final userRole = await _getUserRole(session.user!.id);
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
      print('Error recovering session: $e');
      context.go('/');
    }
  }

  Future<String?> _getUserRole(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('user_roles')
          .select('role')
          .eq('id', userId)
          .single()
          .execute();


      return response.data['role'] as String?;
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
