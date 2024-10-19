import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NavbarItem extends StatelessWidget {
  const NavbarItem({
    super.key,
    this.onTap,
    required this.path,
    required this.itemColor,
    required this.bgColor,
  });
  final void Function()? onTap;
  final String path;
  final Color itemColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 5,
        right: 5,
        top: 5,
        bottom: 5,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 80,
          height: 65,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: bgColor,
          ),
          child: SvgPicture.asset(
            path,
            // height: 40,
            // width: 40,
            color: itemColor,
          ),
        ),
      ),
    );
  }
}
