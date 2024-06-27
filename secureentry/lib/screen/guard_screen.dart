import 'package:flutter/material.dart';
import 'package:secureentry/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

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
        const SnackBar(
          content: Text('Failed to log out. Please try again.'),
          backgroundColor: Color.fromARGB(255, 91, 47, 209),
        ),
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
          .eq('noti_status', 'pending')
          .order('timestamp', ascending: false)
          .execute();

      _notifications = List<Map<String, dynamic>>.from(response.data);

      // Fetch resident details for each notification
      for (int index = 0; index < _notifications.length; index++) {
        final residentEmail = _notifications[index]['resident_email'];
        if (residentEmail is String) {
          final userInfoResponse = await Supabase.instance.client
              .from('users_account')
              .select('name, phone, address, status')
              .eq('email', residentEmail)
              .single()
              .execute();

          final userInfo = userInfoResponse.data;

          // Check if the account is approved before adding details
          if (userInfo['status'] == 'approved') {
            _notifications[index]['resident_name'] = userInfo['name'];
            _notifications[index]['resident_phone'] = userInfo['phone'];
            _notifications[index]['resident_address'] = userInfo['address'];
          } else {
            _notifications[index]['resident_name'] = 'Account not approved';
            _notifications[index]['resident_phone'] = '';
            _notifications[index]['resident_address'] = '';
          }
        }
      }

      setState(() {
        _filteredNotifications = _notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch notifications. Please try again.';
        _isLoading = false;
      });
      print('Error fetching notifications: $e');
    }
  }

  Future<void> _markAsResolved(int notificationId) async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'noti_status': 'resolved'})
          .eq('id', notificationId)
          .execute();
      await _fetchNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark as resolved. Please try again. $e'),
          backgroundColor: Color.fromARGB(255, 91, 47, 209),
        ),
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

  Future<void> _callResident(dynamic phoneNumber) async {
    if (phoneNumber == null || phoneNumber.toString().trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No phone number available'),
          backgroundColor: Color.fromARGB(255, 91, 47, 209),
        ),
      );
      return;
    }

    final String formattedPhoneNumber =
        phoneNumber.toString().replaceAll(RegExp(r'\D'), '');

    if (formattedPhoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid phone number'),
          backgroundColor: Color.fromARGB(255, 91, 47, 209),
        ),
      );
      return;
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: formattedPhoneNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch phone call'),
            backgroundColor: Color.fromARGB(0, 0, 0, 209),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error launching phone call: $e'),
          backgroundColor: Color.fromARGB(255, 91, 47, 209),
        ),
      );
    }
  }

  Color _getStatusColor(String type) {
    switch (type) {
      case 'emergency':
        return Colors.red;
      case 'expected_guest':
        return Colors.blue;
      case 'expected_package':
        return Colors.green;
      case 'file_complaint':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'expected_guest':
        return Icons.person;
      case 'expected_package':
        return Icons.local_shipping;
      case 'file_complaint':
        return Icons.report_problem;
      case 'emergency':
        return Icons.emergency;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guard Dashboard'),
        backgroundColor: Color.fromARGB(255, 91, 47, 209),
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
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 91, 47, 209),
                              width: 2.0,
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
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
                                final DateTime timestamp =
                                    DateTime.parse(notification['timestamp']);
                                final DateTime expectedTime = DateTime.parse(
                                    notification['expected_time']);

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  child: ExpansionTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          _getStatusColor(notification['type']),
                                      child: Icon(
                                          _getNotificationIcon(
                                              notification['type']),
                                          color: Colors.white),
                                    ),
                                    title: Text(
                                      _getNotificationTitle(
                                          notification['type']),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                        'From: ${notification['resident_name'] ?? 'Unknown'}\n'
                                        'Expected Time: ${DateFormat('MMM d, y HH:mm').format(expectedTime)}'),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Phone: ${notification['resident_phone'] ?? 'N/A'}'),
                                            Text(
                                                'Address: ${notification['resident_address'] ?? 'N/A'}'),
                                            Text(
                                                'Received At: ${DateFormat('MMM d, y HH:mm').format(timestamp)}'),
                                            if (notification['message'] !=
                                                    null &&
                                                notification['message']
                                                    .isNotEmpty)
                                              Text(
                                                  'Message: ${notification['message']}'),
                                            const SizedBox(height: 16),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton.icon(
                                                  icon: const Icon(Icons.call),
                                                  label: const Text(
                                                      'Call Resident'),
                                                  onPressed: () => _callResident(
                                                      notification[
                                                          'resident_phone']),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 91, 47, 209),
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      _markAsResolved(
                                                          notification['id']),
                                                  child: const Text(
                                                      'Mark as Resolved'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 91, 47, 209),
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
        backgroundColor: Color.fromARGB(255, 91, 47, 209),
      ),
      backgroundColor: Colors.black,
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
