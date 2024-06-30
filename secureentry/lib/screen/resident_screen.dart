import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../main.dart';

class ResidentScreen extends StatefulWidget {
  const ResidentScreen({super.key});

  @override
  State createState() => _ResidentScreenState();
}

class _ResidentScreenState extends State<ResidentScreen> {
  final TextEditingController _messageController = TextEditingController();
  DateTime? _selectedTime;
  String _notificationType = '';

  Future _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    context.go('/');
  }

  Future _notifyGuard(BuildContext context) async {
    if (_notificationType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a notification type',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromARGB(255, 91, 47, 209),
        ),
      );
      return;
    }

    try {
      await supabase.from('notifications').upsert([
        {
          'resident_email': Supabase.instance.client.auth.currentUser!.email,
          'type': _notificationType,
          'message': _messageController.text,
          'expected_time': _selectedTime?.toIso8601String(),
          'noti_status': 'pending',
          'timestamp': DateTime.now().toIso8601String(),
        }
      ]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guard notified successfully',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromARGB(255, 91, 47, 209),
        ),
      );
      _resetForm();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to notify guard: $error',
              style: const TextStyle(color: Colors.white)),
          backgroundColor: Color.fromARGB(255, 91, 47, 209),
        ),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _notificationType = '';
      _messageController.clear();
      _selectedTime = null;
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resident Home'),
        backgroundColor: Color.fromARGB(0, 0, 0, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome, ${Supabase.instance.client.auth.currentUser!.email}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Notification Type:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildNotificationButton(
                    'expected_guest', 'Expecting Guest', Icons.person),
                _buildNotificationButton('expected_package',
                    'Expecting Package', Icons.local_shipping),
                _buildNotificationButton(
                    'file_complaint', 'File a Complaint', Icons.report_problem),
                _buildNotificationButton(
                    'emergency', 'Report Emergency', Icons.emergency,
                    isEmergency: true),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter additional details',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 91, 47, 209), width: 2.0),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _selectTime(context),
              icon: const Icon(Icons.access_time),
              label: Text(_selectedTime != null
                  ? 'Expected Time: ${DateFormat('HH:mm').format(_selectedTime!)}'
                  : 'Select Expected Time'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 91, 47, 209),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _notifyGuard(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 91, 47, 209),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Submit Notification',
                  style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _buildNotificationButton(String type, String label, IconData icon,
      {bool isEmergency = false}) {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _notificationType = type;
        });
      },
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: _notificationType == type
            ? (isEmergency ? Colors.red : Color.fromARGB(255, 91, 47, 209))
            : Colors.white,
        foregroundColor:
            _notificationType == type ? Colors.white : Colors.black,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
