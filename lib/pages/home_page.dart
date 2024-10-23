import 'package:advocate_todo_list/pages/bulletin_page.dart';
import 'package:advocate_todo_list/pages/cause_list_page.dart';
import 'package:advocate_todo_list/pages/todo_list_page.dart';
import 'package:advocate_todo_list/widgets/navbar_item.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;
  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedTabIndex,
            children: const [
              TodoListPage(),
              BulletinPage(),
              CaseListPage(),
            ],
          ),
          Positioned(
            bottom: 25,
            left: w * 0.2,
            right: w * 0.2,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF545454),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
              ),
              height: h * 0.065,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NavbarItem(
                      onTap: () {
                        _onTabSelected(0);
                      },
                      path: 'assets/icons/todo.svg',
                      itemColor:
                          _selectedTabIndex == 0 ? Colors.white : Colors.black,
                      bgColor:
                          _selectedTabIndex == 0 ? Colors.black : Colors.white,
                    ),
                    NavbarItem(
                      onTap: () {
                        _onTabSelected(1);
                      },
                      path: 'assets/icons/bulletin.svg',
                      itemColor:
                          _selectedTabIndex == 1 ? Colors.white : Colors.black,
                      bgColor:
                          _selectedTabIndex == 1 ? Colors.black : Colors.white,
                    ),
                    NavbarItem(
                      onTap: () {
                        _onTabSelected(2);
                      },
                      path: 'assets/icons/case.svg',
                      itemColor:
                          _selectedTabIndex == 2 ? Colors.white : Colors.black,
                      bgColor:
                          _selectedTabIndex == 2 ? Colors.black : Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
