import 'package:flutter/material.dart';

class VisualComponent extends StatefulWidget {
  const VisualComponent(
      {super.key, required this.duration, required this.color});
  final int duration;
  final Color color;

  @override
  State<VisualComponent> createState() => _VisualComponentState();
}

class _VisualComponentState extends State<VisualComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    );
    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutSine,
    );
    _animation = Tween<double>(begin: 0, end: 30).animate(curvedAnimation)
      ..addListener(
        () {
          setState(() {});
        },
      );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(5),
      ),
      height: _animation.value,
    );
  }
}
