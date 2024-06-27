import 'package:flutter/material.dart';
import 'package:secureentry/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GuardScreen extends StatefulWidget {
  const GuardScreen({super.key});

  @override
  State<GuardScreen> createState() => _GuardScreenState();
}

class _GuardScreenState extends State<GuardScreen> {
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _filteredNotifications = [];
  bool _isLoading = false;
  String _errorMessage = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      router.go('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log out. Please try again.')),
      );
    }
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('status', 'pending')
          .order('timestamp', ascending: false);

      setState(() {
        _notifications = List<Map<String, dynamic>>.from(response);
        _filteredNotifications = _notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch notifications. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsResolved(int notificationId) async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'status': 'resolved'}).eq('id', notificationId);
      await _fetchNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to mark as resolved. Please try again.')),
      );
    }
  }

  void _filterNotifications(String query) {
    setState(() {
      _filteredNotifications = _notifications.where((notification) {
        final typeLower = notification['type'].toString().toLowerCase();
        final searchLower = query.toLowerCase();

        return typeLower.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guard Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search by notification type',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: _filterNotifications,
                      ),
                    ),
                    Expanded(
                      child: _filteredNotifications.isEmpty
                          ? const Center(
                              child: Text('No pending notifications'))
                          : ListView.builder(
                              itemCount: _filteredNotifications.length,
                              itemBuilder: (context, index) {
                                final notification =
                                    _filteredNotifications[index];
                                return ListTile(
                                  title: Text(_getNotificationTitle(
                                      notification['type'])),
                                  subtitle: Text(
                                      'Time: ${notification['timestamp']}'),
                                  trailing: ElevatedButton(
                                    onPressed: () =>
                                        _markAsResolved(notification['id']),
                                    child: const Text('Mark as Resolved'),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchNotifications,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  String _getNotificationTitle(String type) {
    switch (type) {
      case 'expected_guest':
        return 'Expected Guest';
      case 'expected_package':
        return 'Expected Package';
      case 'file_complaint':
        return 'New Complaint Filed';
      case 'emergency':
        return 'EMERGENCY';
      default:
        return 'Unknown Notification';
    }
  }
}
