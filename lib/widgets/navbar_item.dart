import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NavbarItem extends StatelessWidget {
  const NavbarItem({
    super.key,
    this.onTap,
    required this.path,
    required this.itemColor,
    required this.bgColor,
    this.padding,
  });
  final void Function()? onTap;
  final String path;
  final Color itemColor;
  final Color bgColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(
        left: 2,
        right: 2,
        top: 2,
        bottom: 2,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: h * 0.07,
          height: h * 0.07,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: bgColor,
          ),
          child: Center(
            child: SvgPicture.asset(
              path,
              height: 18,
              width: 18,
              color: itemColor,
            ),
          ),
        ),
      ),
    );
  }
}
