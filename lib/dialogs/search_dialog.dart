import 'dart:convert';
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
    _getActiveUsers();
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

      showUserList = true;
    });
  }

  void _addUser(Map<String, String> user) {
    if (!widget.selectedUsers
        .any((selected) => selected['user_id'] == user['user_id'])) {
      widget.onUserSelected(user);
      _searchController.clear();
      filteredUsers.clear();
      showUserList = false;
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      alignment: WrapAlignment.start,
                      children: [
                        for (Map<String, String> user in widget.selectedUsers)
                          Container(
                            height: 36, // Ensure uniform height with TextField
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: const Color(0xFFCACACA),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  user['name']!,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.0,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => widget.onUserRemoved(user),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          height: 36, // Match the height of the tagged boxes
                          width: 150,
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            style: const TextStyle(
                              fontSize: 14.0,
                              height: 1.5, // Adjust line height
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                              const EdgeInsets.symmetric(vertical: 15),
                              hintText: widget.selectedUsers.isEmpty
                                  ? 'Search Users'
                                  : null,
                            ),
                            onTap: () async {
                              await _getActiveUsers();
                              setState(() {
                                showUserList = true;
                              });
                            },
                            textAlignVertical: TextAlignVertical.center,
                            cursorColor: Colors.black,
                            autofocus: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showUserList && filteredUsers.isNotEmpty)
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey),
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                height: 150,
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
