import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String userEmail = '';
  late String userPassword = '';
  bool isLoading = false;
  bool redirecting = false;
  late final StreamSubscription<AuthState> authStateSub;
  bool obscure = true;

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (userEmail.isEmpty || userPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email and password are required'),
          ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final AuthResponse res =
          await Supabase.instance.client.auth.signInWithPassword(
        email: userEmail,
        password: userPassword,
      );
      final User? user = res.user;
      final Session? session = res.session;
      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged in successfully as ${user.email}'),
          ),
        );
      }

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
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error on login: ${e.message}'),
        ),
      );
      context.go('/');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
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
  void initState() {
    super.initState();
    authStateSub =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (redirecting) return;
      final session = data.session;
      if (session != null) {
        redirecting = true;
      }
    });
  }

  @override
  void dispose() {
    authStateSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Secure Entry',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w500,
            decorationStyle: TextDecorationStyle.solid,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(height: 5),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
              onChanged: (value) => setState(() {
                userEmail = value;
              }),
            ),
            TextField(
              obscureText: obscure,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Password',
                hintText: 'Enter your password',
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      obscure = !obscure;
                    });
                  },
                ),
              ),
              onChanged: (value) => setState(() {
                userPassword = value;
              }),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : signIn,
              child: Text(isLoading ? 'Loading...' : 'Login'),
            ),
            ElevatedButton(
              onPressed: () {
                context.go('/signup');
              },
              child: const Text('Don\'t have an account? Sign up'),
            ),
          ]
              .map((e) => Padding(padding: const EdgeInsets.all(16), child: e))
              .toList(),
        ),
      ),
    );
  }
}
