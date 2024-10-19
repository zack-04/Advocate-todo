import 'package:advocate_todo_list/dialogs/accept_or_deny_dialog.dart';
import 'package:advocate_todo_list/model/todo_list_model.dart';
import 'package:flutter/material.dart';

class AssignedTab extends StatelessWidget {
  const AssignedTab({super.key, this.toDoResponse, required this.onRefresh});
  final ToDoResponse? toDoResponse;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    Color getPriorityColor(String priority) {
      switch (priority) {
        case 'High':
          return const Color(0xFFFF4400);
        case 'Medium':
          return const Color(0xFFFFE100);
        case 'Low':
          return const Color(0xFF659BFF);
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: RefreshIndicator(
          onRefresh: onRefresh,
          color: Colors.black,
          backgroundColor: Colors.white,
          child: toDoResponse!.data!.isEmpty
              ? _buildEmptyState()
              : Stack(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: toDoResponse!.data!.length,
                      itemBuilder: (context, index) {
                        final data = toDoResponse!.data![index];
                        return _listItem(
                          data.content!,
                          index + 1,
                          getPriorityColor(data.priority!),
                          context,
                        );
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

Widget _buildEmptyState() {
  return ListView(
    children: const [
      SizedBox(height: 300),
      Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 50),
          child: Text(
            'No assigned task',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    ],
  );
}

Widget _listItem(String title, int number, Color color, BuildContext context) {
  return GestureDetector(
    onTap: () {
      showAcceptOrDenyDialog(context);
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 4,
      ),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$number.',
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
      ),
    ),
  );
}
