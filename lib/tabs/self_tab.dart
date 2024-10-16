import 'package:advocate_todo_list/dialogs/info_dialog.dart';
import 'package:advocate_todo_list/methods/methods.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SelfTab extends StatefulWidget {
  const SelfTab({super.key});

  @override
  State<SelfTab> createState() => _SelfTabState();
}

class _SelfTabState extends State<SelfTab> {
  List<DragAndDropList> _lists = [];

  @override
  void initState() {
    super.initState();

    _lists = [
      DragAndDropList(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        header: _buildListHeader('Work in Progress', const Color(0xFF659BFF)),
        children: [
          DragAndDropItem(
            child: _buildListItem(
              'My name is Krishna...',
              1,
              const Color(0xFFFF4400),
            ),
          ),
          DragAndDropItem(
            child: _buildListItem(
              'My name is Swetha...',
              2,
              const Color(0xFF659BFF),
            ),
          ),
        ],
      ),
      DragAndDropList(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        header: _buildListHeader('Pending Task', const Color(0xFFFFC260)),
        children: [
          DragAndDropItem(
            child: _buildListItem(
              'My name is Sarath...',
              1,
              const Color(0xFFFF4400),
            ),
          ),
          DragAndDropItem(
            child: _buildListItem(
              'My name is Rima...',
              2,
              const Color(0xFF659BFF),
            ),
          ),
          DragAndDropItem(
            child: _buildListItem(
              'My name is Nandhini...',
              3,
              const Color(0xFFFFE100),
            ),
          ),
        ],
      ),
      DragAndDropList(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        header: _buildListHeader('Completed Task', const Color(0xFF2DCB4A)),
        children: [
          DragAndDropItem(
            child: _buildListItem(
              'My name is Ripunjay...',
              1,
              const Color(0xFFFF4400),
            ),
          ),
          DragAndDropItem(
            child: _buildListItem(
              'My name is Sam...',
              2,
              const Color(0xFF659BFF),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildListHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [color, Colors.white],
            stops: const [
              0.0,
              0.8,
            ],
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(String title, int number, Color color) {
    return GestureDetector(
      onTap: () {
        showInfoDialog(
          context,
          () {
            scheduleNotification(context);
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 4,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/drag.svg',
              width: 20,
              height: 20,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            Expanded(
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DragAndDropLists(
          children: _lists,
          onItemReorder: _onItemReorder,
          onListReorder: (oldListIndex, newListIndex) {},
          listPadding: const EdgeInsets.symmetric(vertical: 8),
          itemDivider: const Divider(thickness: 0.5, height: 0.5),
          listDecoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _onItemReorder(
    int oldItemIndex,
    int oldListIndex,
    int newItemIndex,
    int newListIndex,
  ) {
    setState(() {
      var movedItem = _lists[oldListIndex].children.removeAt(oldItemIndex);
      _lists[newListIndex].children.insert(newItemIndex, movedItem);
      _recalculateNumbers();
    });
  }

  void _recalculateNumbers() {
    for (var list in _lists) {
      for (int i = 0; i < list.children.length; i++) {
        var gesture = list.children[i].child as GestureDetector;
        var padding1 = gesture.child as Padding;
        var row1 = padding1.child as Row;

        var expanded1 = row1.children[2] as Expanded;
        var container1 = expanded1.child as Container;
        var row2 = container1.child as Row;

        var currentText = row2.children[4] as Text;
        String title = currentText.data ?? '';

        Color color;
        var firstChild = row2.children[0] as Container;

        if (firstChild.decoration is BoxDecoration) {
          color = (firstChild.decoration as BoxDecoration).color ?? Colors.grey;
        } else {
          color = Colors.grey;
        }

        list.children[i] = DragAndDropItem(
          child: _buildListItem(title, i + 1, color),
        );
      }
    }
  }
}
