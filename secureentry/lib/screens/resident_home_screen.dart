import 'package:flutter/material.dart';
import 'package:secureentry/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResidentHomeScreen extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    router.go('/');
  }

  Future<void> _notifyGuard(BuildContext context, String notificationType) async {
    try {
      await Supabase.instance.client.from('notifications').insert({
        'resident_id': Supabase.instance.client.auth.currentUser!.id,
        'type': notificationType,
        'status': 'pending',
        'timestamp': DateTime.now().toIso8601String(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Guard notified successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to notify guard: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resident Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, Resident!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _notifyGuard(context, 'expected_guest'),
              child: Text('Notify Guard: Expecting Guest'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _notifyGuard(context, 'expected_package'),
              child: Text('Notify Guard: Expecting Package'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _notifyGuard(context, 'file_complaint'),
              child: Text('File a Complaint'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _notifyGuard(context, 'emergency'),
              child: Text('Report Emergency'),
              style: ElevatedButton.styleFrom( backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}