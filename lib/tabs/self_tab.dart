import 'dart:convert';

import 'package:advocate_todo_list/const.dart';
import 'package:advocate_todo_list/dialogs/info_dialog.dart';
import 'package:advocate_todo_list/model/todo_list_model.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

class SelfTab extends StatefulWidget {
  const SelfTab({
    super.key,
    this.toDoResponse,
    required this.onTransfer,
    required this.onRefresh,
  });
  final ToDoResponse? toDoResponse;
  final VoidCallback onTransfer;
  final Future<void> Function() onRefresh;

  @override
  State<SelfTab> createState() => _SelfTabState();
}

class _SelfTabState extends State<SelfTab> {
  final List<DragAndDropList> _lists = [];

  @override
  void initState() {
    super.initState();
    _buildLists();
  }

  Future<void> changeWorkStatus(String todoId, int newListIndex) async {
    String? empId = await getLoginUserId();
    debugPrint('empid: $empId');
    String status;

    if (newListIndex == 0) {
      status = 'Work-Inprogress';
    } else if (newListIndex == 1) {
      status = 'Pending';
    } else {
      status = 'Completed';
    }
    const String url = ApiConstants.todoWorkStatusChange;

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['enc_key'] = encKey
      ..fields['emp_id'] = empId!
      ..fields['todo_id'] = todoId
      ..fields['todo_status'] = status;

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        debugPrint('responsebody: $responseBody');
        if (mounted) {}
      } else {
        debugPrint('Failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error id: $e');
    }
  }

  String _getContent(String? content) {
    return content?.isEmpty ?? true ? 'Content name' : content!;
  }

  String _getPriority(String? priority) {
    return priority?.isEmpty ?? true ? 'High' : priority!;
  }

  void _buildLists() {
    if (widget.toDoResponse == null || widget.toDoResponse!.data!.isEmpty) {
      return;
    }

    // Clear existing lists
    _lists.clear();

    // Create lists based on your ToDoResponse data
    Map<String, List<DragAndDropItem>> categorizedItems = {
      taskStatus['IN_PROGRESS']!: [],
      taskStatus['PENDING']!: [],
      taskStatus['COMPLETED']!: [],
    };
    final data = widget.toDoResponse!.data;

    // Categorize items based on their status
    for (int index = 0; index < data!.length; index++) {
      var todo = data[index];
      // debugPrint('Index of lists = $index');

      CustomDragAndDropItem item = CustomDragAndDropItem(
        todoId: todo.todoId!,
        child: _buildListItem(
          _getContent(todo.content),
          index + 1,
          _getPriorityColor(
            _getPriority(todo.priority),
          ),
          () {
            todoDetailsApi(
              context,
              todo.todoId!,
              widget.onTransfer,
              'Transfer',
            );
          },
        ),
      );

      // Categorize items based on their status
      switch (todo.todoStatus) {
        case 'Pending':
          categorizedItems[taskStatus['PENDING']!]!.add(item);
          break;
        case 'Completed':
          categorizedItems[taskStatus['COMPLETED']!]!.add(item);
          break;
        case 'Work-Inprogress':
          categorizedItems[taskStatus['IN_PROGRESS']!]!.add(item);
          break;
      }
    }

    // Build DragAndDropList for each category
    categorizedItems.forEach((title, items) {
      _lists.add(
        DragAndDropList(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          header: _buildListHeader(title, _getListColor(title)),
          children: items,
        ),
      );
    });
    _recalculateNumbers();

    debugPrint('Pending list = ${categorizedItems[taskStatus['PENDING']!]!}');
    debugPrint(
        'In progress list = ${categorizedItems[taskStatus['IN_PROGRESS']!]!}');
    debugPrint(
        'Completed list = ${categorizedItems[taskStatus['COMPLETED']!]!}');
  }

  // Get the appropriate color for the list header based on the title
  Color _getListColor(String title) {
    switch (title) {
      case 'Work in Progress':
        return const Color(0xFF659BFF);
      case 'Pending Task':
        return const Color(0xFFFFC260);
      case 'Completed Task':
        return const Color(0xFF2DCB4A);
      default:
        return Colors.grey;
    }
  }

  // Get color based on priority
  Color _getPriorityColor(String priority) {
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
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(
    String title,
    int number,
    Color color,
    void Function()? onTap,
  ) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
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
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
        child: RefreshIndicator(
          onRefresh: widget.onRefresh,
          color: Colors.black,
          backgroundColor: Colors.white,
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

      String todoId = (movedItem as CustomDragAndDropItem).todoId;
      debugPrint('Dragged todoId = $todoId');
      changeWorkStatus(todoId, newListIndex);
      _recalculateNumbers();
    });

    debugPrint('Olditemindex = $oldItemIndex');
    debugPrint('Oldlistindex = $oldListIndex');
    debugPrint('newitemindex = $newItemIndex');
    debugPrint('newListindex = $newListIndex');
  }

  void _recalculateNumbers() {
    for (var list in _lists) {
      for (int i = 0; i < list.children.length; i++) {
        var dragAndDropItem = list.children[i];
        var custom = dragAndDropItem as CustomDragAndDropItem;
        String todoId = (custom).todoId;
        if (dragAndDropItem.child is Material) {
          var material = list.children[i].child as Material;
          var inkWell = material.child as InkWell;
          var onTap = inkWell.onTap;
          var padding1 = inkWell.child as Padding;
          var row1 = padding1.child as Row;

          var expanded1 = row1.children[2] as Expanded;
          var container1 = expanded1.child as Container;
          var row2 = container1.child as Row;

          var expanded = row2.children[4] as Expanded;
          var currentText = expanded.child as Text;
          String title = currentText.data ?? '';

          Color color;
          var firstChild = row2.children[0] as Container;

          if (firstChild.decoration is BoxDecoration) {
            color =
                (firstChild.decoration as BoxDecoration).color ?? Colors.grey;
          } else {
            color = Colors.grey;
          }

          list.children[i] = CustomDragAndDropItem(
            todoId: todoId,
            child: _buildListItem(title, i + 1, color, onTap),
          );
        } else {
          debugPrint(
              "Expected GestureDetector but found: ${dragAndDropItem.child.runtimeType}");
        }
      }
    }
  }
}

class CustomDragAndDropItem extends DragAndDropItem {
  final String todoId;

  CustomDragAndDropItem({
    required super.child,
    required this.todoId,
  });
}
