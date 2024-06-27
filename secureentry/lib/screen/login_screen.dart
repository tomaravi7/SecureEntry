import 'package:flutter/material.dart';
import 'package:secureentry/main.dart';
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
            backgroundColor: Color.fromARGB(255, 91, 47, 209),
          ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: userEmail,
        password: userPassword,
      );
      final User? user = res.user;
      final Session? session = res.session;

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged in successfully as ${user.email}'),
            backgroundColor: Color.fromARGB(255, 91, 47, 209),
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
          backgroundColor: Color.fromARGB(255, 91, 47, 209),
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
      final response = await supabase
          .from('user_roles')
          .select('role')
          .eq('user_id', userId)
          .single();
      print(response);

      return response['role'] as String?;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching user role on login: $e'),
            backgroundColor: Color.fromARGB(255, 91, 47, 209),
          ),
        );
      }
      print('Error fetching user role on login screen: $e');
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
        title: const Text('Secure Entry'),
        backgroundColor: Color.fromARGB(0, 0, 0, 209),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 100.0),
              // Placeholder for the logo
              Image.asset('assets/image/login.png', height: 100.0),
              const SizedBox(height: 32.0),
              const Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 91, 47, 209), width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(
                    color: Colors.white, fontFamily: 'YourProfessionalFont'),
                onChanged: (value) => setState(() {
                  userEmail = value;
                }),
              ),
              const SizedBox(height: 16.0),
              TextField(
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(color: Colors.white),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 91, 47, 209), width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(
                    color: Colors.white, fontFamily: 'YourProfessionalFont'),
                onChanged: (value) => setState(() {
                  userPassword = value;
                }),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: isLoading ? null : signIn,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey; // Disabled color
                      }
                      return Color.fromARGB(255, 91, 47, 209); // Regular color
                    },
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.black; // Disabled text color
                      }
                      return Colors.white; // Regular text color
                    },
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                child: Text(isLoading ? 'Loading...' : 'Login'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  context.go('/signup');
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey; // Disabled color
                      }
                      return Colors.white; // Regular color
                    },
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.black; // Disabled text color
                      }
                      return Color.fromARGB(
                          255, 91, 47, 209); // Regular text color
                    },
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                child: const Text('Don\'t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
