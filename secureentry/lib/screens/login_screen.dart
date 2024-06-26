import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;

  Future<void> _signIn() async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.session != null) {
        print('User signed in successfully. User ID: ${response.user!.id}');


        final userRole = await _getUserRole(response.user!.id);

        if (userRole != null) {
          print('User role fetched: $userRole');
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
              throw Exception('Unknown user role: $userRole');
          }
        } else {
          throw Exception('User role not found');
        }
      } else {
        throw Exception('Sign in failed: Session is null');
      }
    } catch (error) {
      print('Sign in error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: ${error.toString()}')),
      );
    }
  }

  Future<String?> _getUserRole(String userId) async {
    try {
      print('Fetching role for user ID: $userId');

      final response = await Supabase.instance.client
          .from('user_roles')
          .select()
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
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              autofillHints: [AutofillHints.email],
            ),
            TextField(
              controller: _passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  )),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Sign In'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.go('/signup');
              },
              child: Text('Don\'t have an account? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
