import 'dart:convert';

import 'package:advocate_todo_list/dialogs/text_note_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../const.dart';

class UserSearch extends StatefulWidget {
  final List<Map<String, String>> selectedUsers;
  final Function(Map<String, String>) onUserSelected;
  final Function(Map<String, String>) onUserRemoved;

  const UserSearch({
    super.key,
    required this.selectedUsers,
    required this.onUserSelected,
    required this.onUserRemoved,
  });

  @override
  State<UserSearch> createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, String>> allUsers = [];
  List<Map<String, String>> filteredUsers = [];
  bool showUserList = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterUsers);
    _getActiveUsers(); // Fetch active users on init
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _getActiveUsers() async {
    const String url = ApiConstants.allUsers;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? loginUserId = prefs.getString('login_user_id');

    final Map<String, String> body = {
      'enc_key': encKey,
      'emp_id': loginUserId!,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Fetch all users with both name and user_id, excluding selected ones
          allUsers = (data['data'] as List)
              .map((user) => {
            'name': user['name'].toString(),
            'user_id': user['user_id'].toString()
          })
              .where((user) => !widget.selectedUsers
              .any((selected) => selected['user_id'] == user['user_id']))
              .toList();
          filteredUsers = allUsers;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error fetching users: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $e')),
      );
    }
  }

  void _filterUsers() {
    setState(() {
      String searchTerm = _searchController.text.toLowerCase();

      // Filter the users based on the search term and exclude already selected users
      if (searchTerm.isEmpty) {
        filteredUsers = allUsers
            .where((user) => !widget.selectedUsers
            .any((selected) => selected['user_id'] == user['user_id']))
            .toList();
      } else {
        filteredUsers = allUsers
            .where((user) =>
        user['name']!.toLowerCase().contains(searchTerm) &&
            !widget.selectedUsers
                .any((selected) => selected['user_id'] == user['user_id']))
            .toList();
      }

      showUserList = true; // Show user list dropdown when filtering
    });
  }

  void _addUser(Map<String, String> user) {
    if (!widget.selectedUsers
        .any((selected) => selected['user_id'] == user['user_id'])) {
      widget.onUserSelected(user);
      _searchController.clear();
      filteredUsers.clear();
      showUserList = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                for (Map<String, String> user in widget.selectedUsers)
                  Chip(
                    backgroundColor: Colors.grey.shade300,
                    label: Text(user['name']!),
                    onDeleted: () => widget.onUserRemoved(user),
                  ),
              ],
            ),
            TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search Users',
              ),
              onTap: () async {
                await _getActiveUsers(); // Fetch users on tap
                setState(() {
                  showUserList = true; // Show user list on tap
                });
              },
            ),
            if (showUserList && filteredUsers.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                height: 150, // Limit the dropdown height
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return ListTile(
                      title: Text(user['name']!),
                      onTap: () => _addUser(user),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}


