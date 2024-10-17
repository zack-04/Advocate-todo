import 'package:advocate_todo_list/dialogs/info_dialog.dart';
import 'package:advocate_todo_list/model/todo_list_model.dart';
import 'package:advocate_todo_list/widgets/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class OthersTab extends StatelessWidget {
  const OthersTab({super.key, this.toDoResponse, required this.onRefresh});
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
          child: ListView.builder(
            itemCount: toDoResponse!.data!.length + 1,
            itemBuilder: (context, index) {
              if (index < toDoResponse!.data!.length) {
                final data = toDoResponse!.data![index];
                return _listItem(
                  data.content!,
                  index + 1,
                  getPriorityColor(data.priority!),
                  context,
                );
              } else {
                return const SizedBox(height: 100);
              }
            },
          ),
        ),
      ),
    );
  }
}

Widget _listItem(String title, int number, Color color, BuildContext context) {
  return GestureDetector(
    onTap: () {
      // showInfoDialog(
      //   context,
      //   () {
      //     pickDateAndTime(context);
      //   },
      // );
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

Future<void> pickDateAndTime(BuildContext context) async {
  // Date picker
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2101),
  );
  debugPrint('Picked date = $pickedDate');

  if (pickedDate != null) {
    // Time picker
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    debugPrint('Picked time = $pickedTime');

    if (pickedTime != null) {
      // Combine date and time
      final DateTime scheduledDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      debugPrint('Scheduled time = $scheduledDateTime');
      Navigator.pop(context);
      showCustomToastification(
        context: context,
        type: ToastificationType.success,
        title: 'Time picked!',
        icon: Icons.check,
        primaryColor: Colors.green,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      );
    }
  }
}
