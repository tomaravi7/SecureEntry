import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _houseController = TextEditingController();
  String _userType = 'resident';

  bool _isLoading = false;
  bool _hasError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _houseController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      try {
        final response = await supabase.from('users_account').upsert([
          {
            'email': _emailController.text,
            'name': _nameController.text,
            'phone': _phoneController.text,
            'user_type': _userType,
            'address': _houseController.text,
            'status': 'pending',
          }
        ]);
      } on PostgrestException catch (error) {
        setState(() {
          _hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup request failed: ${error.message}')),
        );
      } catch (error) {
        setState(() {
          _hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $error')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Signup request submitted. Please wait for admin approval.')),
          );
          context.go('/');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    errorText: _hasError ? 'Invalid Input' : null,
                  ),
                  autofillHints: const [AutofillHints.name],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _houseController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    errorText: _hasError ? 'Invalid Input' : null,
                  ),
                  autofillHints: const [AutofillHints.fullStreetAddress],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: _hasError ? 'Invalid Input' : null,
                  ),
                  autofillHints: const [AutofillHints.email],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    errorText: _hasError ? 'Invalid Input' : null,
                  ),
                  autofillHints: const [AutofillHints.telephoneNumber],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _userType,
                  decoration: const InputDecoration(labelText: 'User Type'),
                  items: const [
                    DropdownMenuItem(
                        child: Text('Resident'), value: 'resident'),
                    DropdownMenuItem(child: Text('Guard'), value: 'guard'),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _userType = value!;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Sign Up'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.go('/');
                  },
                  child: const Text('Already have an account? Sign In'),
                ),
              ]
                  .map((e) =>
                      Padding(padding: const EdgeInsets.all(16), child: e))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
