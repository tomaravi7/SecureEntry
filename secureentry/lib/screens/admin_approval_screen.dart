import 'package:flutter/material.dart';
import 'package:secureentry/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminApprovalScreen extends StatefulWidget {
  @override
  _AdminApprovalScreenState createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  List<Map<String, dynamic>> _allPendingAccounts = [];
  List<Map<String, dynamic>> _filteredPendingAccounts = [];
  TextEditingController _searchController = TextEditingController();

  final String _fixedPassword = 'Default';

  @override
  void initState() {
    super.initState();
    _fetchPendingAccounts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    router.go('/');
  }

  Future<void> _fetchPendingAccounts() async {
    try {
      final response = await Supabase.instance.client
          .from('pending_accounts')
          .select()
          .eq('status', 'pending');

      setState(() {
        _allPendingAccounts = List<Map<String, dynamic>>.from(response);
        _filteredPendingAccounts = _allPendingAccounts;
      });
    } catch (error) {
      _showErrorSnackBar(
          'Failed to fetch pending accounts: ${error.toString()}');
    }
  }

  void _filterAccounts(String query) {
    setState(() {
      _filteredPendingAccounts = _allPendingAccounts.where((account) {
        final nameLower = account['name'].toString().toLowerCase();
        final emailLower = account['email'].toString().toLowerCase();
        final searchLower = query.toLowerCase();

        return nameLower.contains(searchLower) ||
            emailLower.contains(searchLower);
      }).toList();
    });
  }

  Future<void> _approveAccount(Map<String, dynamic> account) async {
    try {
      final AuthResponse authResponse =
          await Supabase.instance.client.auth.signUp(
        email: account['email'],
        password: _fixedPassword,
        data: {
          'name': account['name'],
          'phone': account['phone'],
        },
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user account');
      }

      await Supabase.instance.client.from('user_roles').insert({
        'id': authResponse.user!.id,
        'role': account['user_type'],
      });

      await Supabase.instance.client
          .from('pending_accounts')
          .update({'status': 'approved'}).eq('id', account['id']);

      await _fetchPendingAccounts();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account approved successfully')),
      );
    } catch (error) {
      print('Error in _approveAccount: $error');
      _showErrorSnackBar('Failed to approve account: ${error.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Approval'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by name or email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterAccounts,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredPendingAccounts.length,
              itemBuilder: (context, index) {
                final account = _filteredPendingAccounts[index];
                return ListTile(
                  title: Text(account['name']),
                  subtitle:
                      Text('${account['email']} - ${account['user_type']}'),
                  trailing: ElevatedButton(
                    onPressed: () => _approveAccount(account),
                    child: Text('Approve'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
