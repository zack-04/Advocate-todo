import 'package:advocate_todo_list/dialogs/accept_or_deny_dialog.dart';
import 'package:flutter/material.dart';

class AssignedTab extends StatelessWidget {
  const AssignedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            _listItem(
              'This is assigned item 1...',
              1,
              const Color(0xFFFF4400),
              context,
            ),
            _listItem(
              'This is assigned item 2...',
              2,
              const Color(0xFF659BFF),
              context,
            ),
          ],
        ),
      ),
    );
  }
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
