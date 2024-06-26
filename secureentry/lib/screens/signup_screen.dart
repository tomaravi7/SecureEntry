import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _houseController = TextEditingController();
  String _userType = 'resident'; // Default to resident

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response =
            await Supabase.instance.client.from('pending_accounts').insert({
          'email': _emailController.text,
          'name': _nameController.text,
          'phone': _phoneController.text,
          'user_type': _userType,
          'address': _houseController.text,
          'status': 'pending',
        }).execute();

        if (response.status == 201) {
          // Signup request successful
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Signup request submitted. Please wait for admin approval.')),
          );
          _sendPasswordEmail(_emailController.text, _passwordController.text);
          // Navigate back to login screen
          context.go('/');
        }
      } on PostgrestException catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup request failed: ${error.message}')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $error')),
        );
      } finally {
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  Future<void> _sendPasswordEmail(String email, String pass) async {
    String username = 'tomaravi7@gmail.com'; // Your email
    String password = 'zccb lvrg zubr srsc'; // Your email password

    final smtpServer = gmail(username, password); // Using Gmail SMTP server

    final message = Message()
      ..from = Address(username, 'SECURE ENTRY ')
      ..recipients.add(email)
      ..subject = 'Your New Password'
      ..text =
          'Your new password is: DEFAULT \n\nPlease change this password after logging in.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. ${e.toString()}');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _houseController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
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
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: "Password will be sent to you via email"),
                // obscureText: true,
                enabled: false,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter a password';
                //   }
                //   if (value.length < 6) {
                //     return 'Password must be at least 6 characters long';
                //   }
                //   return null;
                // },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _userType,
                decoration: InputDecoration(labelText: 'User Type'),
                items: [
                  DropdownMenuItem(child: Text('Resident'), value: 'resident'),
                  DropdownMenuItem(child: Text('Guard'), value: 'guard'),
                ],
                onChanged: (value) {
                  setState(() {
                    _userType = value!;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _signUp,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
