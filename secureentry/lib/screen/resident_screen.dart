import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class ResidentScreen extends StatefulWidget {
  const ResidentScreen({super.key});

  @override
  State<ResidentScreen> createState() => _ResidentScreenState();
}

class _ResidentScreenState extends State<ResidentScreen> {
  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    context.go('/');
  }

  Future<void> _notifyGuard(
      BuildContext context, String notificationType) async {
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
        title: const Text('Resident Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, Resident!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _notifyGuard(context, 'expected_guest'),
              child: const Text('Notify Guard: Expecting Guest'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _notifyGuard(context, 'expected_package'),
              child: const Text('Notify Guard: Expecting Package'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _notifyGuard(context, 'file_complaint'),
              child: const Text('File a Complaint'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _notifyGuard(context, 'emergency'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Report Emergency'),
            ),
          ],
        ),
      ),
    );
  }
}
