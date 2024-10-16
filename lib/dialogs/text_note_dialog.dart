import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextNoteDialog extends StatefulWidget {
  const TextNoteDialog({super.key});

  @override
  State<TextNoteDialog> createState() => _TextNoteDialogState();
}

class _TextNoteDialogState extends State<TextNoteDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode focusNode = FocusNode();
  final List<String> allUsers = [
    'Sarath Kumar',
    'Abinaya',
    'John',
    'Suresh',
    'Mahesh',
    'Krishna',
    'Swetha',
    'Sam',
    'Ram',
    'Shyam',
    'Saransh',
    'Sikandar',
  ];
  List<String> filteredUsers = [];
  List<String> selectedUsers = [];
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterUsers() {
    setState(() {
      String searchTerm = _searchController.text.toLowerCase();
      if (searchTerm.isEmpty) {
        filteredUsers.clear();
      } else {
        filteredUsers = allUsers
            .where((user) => user.toLowerCase().contains(searchTerm))
            .toList();
      }
    });
  }

  void _addUser(String user) {
    setState(() {
      if (!selectedUsers.contains(user)) {
        selectedUsers.add(user);
      }
      _searchController.clear();
      filteredUsers.clear();
    });
    _focusNode.requestFocus();
  }

  void _removeUser(String user) {
    setState(() {
      selectedUsers.remove(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Enter note",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.close,
                          size: 25,
                          color: Color(0xFF545454),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxHeight: 130,
                    ),
                    child: TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      cursorColor: Colors.black,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      maxLines: null,
                      maxLength: 250,
                      minLines: 3,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter note';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF9F9F9),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Text(
                    'Tag Users',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Search Field with Chips
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      alignment: WrapAlignment.start,
                      children: [
                        for (String user in selectedUsers)
                          Chip(
                            backgroundColor: Colors.grey.shade300,
                            label: Text(user),
                            onDeleted: () => _removeUser(user),
                          ),
                        TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                selectedUsers.isEmpty ? 'Search Users' : '',
                          ),
                          onEditingComplete: () {
                            if (filteredUsers.isNotEmpty) {
                              _addUser(filteredUsers.first);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                if (filteredUsers.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return GestureDetector(
                            onTap: () => _addUser(user),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, top: 10),
                              child: Text(
                                user,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 10,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: MaterialButton(
                      height: 42,
                      minWidth: 130,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: const Color(0xFF4B4B4B),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Send',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showTextNoteDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const TextNoteDialog();
    },
  );
}
