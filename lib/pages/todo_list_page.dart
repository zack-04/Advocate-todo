import 'package:advocate_todo_list/tabs/assigned_tab.dart';
import 'package:advocate_todo_list/tabs/others_tab.dart';
import 'package:advocate_todo_list/tabs/self_tab.dart';
import 'package:advocate_todo_list/widgets/custom_button.dart';
import 'package:advocate_todo_list/widgets/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  int _selectedIndex = 0;
  bool showCreateForm = false;
  final List<String> _tabs = ['Self', 'Assigned', 'Buzz', 'Others'];
  final List<int> _badges = [22, 1, 0, 0];

  void _onTabTapped(int index) {
    if (!showCreateForm) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void toggleCreateForm() {
    setState(() {
      showCreateForm = !showCreateForm;
      if (showCreateForm) {
        _selectedIndex = -1;
      } else {
        _selectedIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'To Do List',
          style: GoogleFonts.inter(
            fontSize: 25.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(showCreateForm ? Icons.close : Icons.add),
            onPressed: toggleCreateForm,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: showCreateForm
                ? SingleChildScrollView(
                    child: ToDoCreationForm(onPressed: toggleCreateForm),
                  )
                : _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: const Color(0xFFF6F6F6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_tabs.length, (index) {
            return GestureDetector(
              onTap: () => _onTabTapped(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: _selectedIndex == index
                        ? Colors.white
                        : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _tabs[index],
                        style: TextStyle(
                          color: _selectedIndex == index
                              ? Colors.black
                              : Colors.black54,
                          fontWeight: _selectedIndex == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (_badges[index] > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${_badges[index]}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedIndex < 0 || _selectedIndex >= _tabs.length) {
      return const Center(
        child: Text('No tab selected.'),
      );
    }
    List<Widget> tabViews = [
      const SelfTab(),
      const AssignedTab(),
      const Center(
        child: Text(
          'Buzz Tab Content',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      const OthersTab(),
    ];

    return tabViews[_selectedIndex];
  }
}

class ToDoCreationForm extends StatefulWidget {
  const ToDoCreationForm({
    super.key,
    required this.onPressed,
  });
  final void Function() onPressed;

  @override
  State<ToDoCreationForm> createState() => _ToDoCreationFormState();
}

class _ToDoCreationFormState extends State<ToDoCreationForm> {
  final TextEditingController controller = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final FocusNode focusNode = FocusNode();

  String selectedPriority = 'High';
  bool isDropdownOpen = false;
  DateTime selectedDate = DateTime.now();

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.yellow;
      case 'Low':
        return Colors.blue[900]!;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 20,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "To Do Creation",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
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
                        return 'Please enter content';
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
                const SizedBox(height: 10),
                const Text(
                  'Priority',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isDropdownOpen = !isDropdownOpen;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFF6F6F6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: _getPriorityColor(selectedPriority),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 22),
                            Text(
                              selectedPriority,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          isDropdownOpen
                              ? FontAwesome.chevron_up_solid
                              : FontAwesome.chevron_down_solid,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Complete Before',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFF6F6F6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd-MMM-yyyy').format(selectedDate),
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                CustomButton(
                  text: 'Create List',
                  onPressed: () {
                    showCustomToastification(
                      context: context,
                      type: ToastificationType.success,
                      title: 'Created successfully!',
                      icon: Icons.check,
                      primaryColor: Colors.green,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    );
                    widget.onPressed();
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),

            // Dropdown menu overlay
            if (isDropdownOpen)
              Positioned(
                top: 170,
                left: 0,
                right: 0,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    children: <String>['High', 'Medium', 'Low']
                        .map((priority) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedPriority = priority;
                                  isDropdownOpen = false;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 15,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor(priority),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 22),
                                    Text(
                                      priority,
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
