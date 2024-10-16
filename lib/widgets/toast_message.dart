import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showCustomToastification({
  required BuildContext context,
  required ToastificationType type,
  required String title,
  required IconData icon,
  required Color primaryColor,
  required Color backgroundColor,
  required Color foregroundColor,
  ToastificationStyle style = ToastificationStyle.flatColored,
  Duration autoCloseDuration = const Duration(seconds: 5),
}) {
  toastification.show(
    context: context,
    type: type,
    style: style,
    autoCloseDuration: autoCloseDuration,
    title: Text(title),
    alignment: Alignment.topRight,
    direction: TextDirection.ltr,
    icon: Icon(icon),
    showIcon: true,
    primaryColor: primaryColor,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Color(0x07000000),
        blurRadius: 16,
        offset: Offset(0, 16),
        spreadRadius: 0,
      )
    ],
    showProgressBar: true,
    closeButtonShowType: CloseButtonShowType.always,
  );
}
