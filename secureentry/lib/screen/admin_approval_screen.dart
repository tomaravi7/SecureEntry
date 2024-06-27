import 'package:flutter/material.dart';
import '../main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<Map<String, dynamic>> _allPendingAccounts = [];
  List<Map<String, dynamic>> _filteredPendingAccounts = [];
  final TextEditingController _searchController = TextEditingController();

  static const String _fixedPassword = 'default';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPendingAccounts();
    _searchController.addListener(() {
      _filterAccounts(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      _showErrorSnackBar(error.message);
    } catch (error) {
      _showErrorSnackBar('Unexpected Error');
    } finally {
      context.go('/');
    }
  }

  Future<void> _fetchPendingAccounts() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await supabase.from('users_account').select().eq('status', 'pending');
      setState(() {
        _allPendingAccounts.clear();
        _allPendingAccounts.addAll(List<Map<String, dynamic>>.from(response));
        _filteredPendingAccounts = List.from(_allPendingAccounts);
      });
    } catch (error) {
      _showErrorSnackBar(
          "Failed to fetch pending accounts: ${error.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterAccounts(String query) {
    setState(() {
      _filteredPendingAccounts = _allPendingAccounts.where((account) {
        final searchLower = query.toLowerCase();
        return account.values.any(
            (value) => value.toString().toLowerCase().contains(searchLower));
      }).toList();
    });
  }

  Future<void> _approveAccount(Map<String, dynamic> account) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Create a new Supabase client instance
      final newClient = SupabaseClient(
        supabase.supabaseUrl,
        supabase.supabaseKey,
      );

      // Sign up the new user
      final AuthResponse res = await newClient.auth.signUp(
        email: account['email'],
        password: _fixedPassword,
        data: {
          'full_name': account['name'],
          'phone': account['phone'],
          'address': account['address']
        },
      );

      if (res.user == null) {
        throw Exception('Failed to create user account');
      }

      await _sendPasswordEmail(account['email'], _fixedPassword);

      // Use the admin's session to insert user role and update account status
      await supabase.from('user_roles').insert({
        'user_id': res.user!.id,
        'role': account['user_type'],
      });

      await supabase
          .from('users_account')
          .update({'status': 'approved'}).eq('email', account['email']);

      await _fetchPendingAccounts();
      _showSuccessSnackBar('Account approved successfully');
    } on AuthException catch (error) {
      _showErrorSnackBar(error.message);
    } catch (error) {
      _showErrorSnackBar('Unexpected error: ${error.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          'Your new password is: ${_fixedPassword} \n\nPlease change this password after logging in.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. ${e.toString()}');
      throw e;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 91, 47, 209),
        title:
            const Text('Admin Approval', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterAccounts,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 91, 47, 209)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 91, 47, 209), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 91, 47, 209)))
                : _filteredPendingAccounts.isEmpty
                    ? const Center(
                        child: Text('No pending accounts',
                            style: TextStyle(color: Colors.white)))
                    : ListView.builder(
                        itemCount: _filteredPendingAccounts.length,
                        itemBuilder: (context, index) {
                          final account = _filteredPendingAccounts[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 91, 47, 209)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ExpansionTile(
                              title: Text(account['name'],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(account['email'],
                                  style:
                                      const TextStyle(color: Colors.white70)),
                              trailing: ElevatedButton(
                                onPressed: () => _approveAccount(account),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 91, 47, 209),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Approve'),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Phone: ${account['phone']}',
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      Text('Address: ${account['address']}',
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      Text('User Type: ${account['user_type']}',
                                          style: const TextStyle(
                                              color: Colors.white)),
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
        onPressed: _fetchPendingAccounts,
        backgroundColor: const Color.fromARGB(255, 91, 47, 209),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
