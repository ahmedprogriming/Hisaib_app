import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

void showSnackbar(
  BuildContext context,
  String message, {
  SnackBarType type = SnackBarType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  // إخفاء أي تنبيه حالي على الفور لمنع تراكم التنبيهات
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  // تحديد اللون والأيقونة حسب نوع التنبيه
  Color backgroundColor;
  Color borderColor;
  Color textColor;
  IconData iconData;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = const Color(0xffF4FBF7);
      borderColor = const Color(0xff66BB6A);
      textColor = const Color(0xff1B5E20);
      iconData = Icons.check_circle_outline_rounded;
      break;
    case SnackBarType.error:
      backgroundColor = const Color(0xffFDF4F4);
      borderColor = const Color(0xffEF5350);
      textColor = const Color(0xffB71C1C);
      iconData = Icons.error_outline_rounded;
      break;
    case SnackBarType.warning:
      backgroundColor = const Color(0xffFFFDF0);
      borderColor = const Color(0xffFFA726);
      textColor = const Color(0xffE65100);
      iconData = Icons.warning_amber_rounded;
      break;
    case SnackBarType.info:
    default:
      // طابع العيادة (الذهبي الدافئ)
      backgroundColor = const Color(0xffFCF8EF);
      borderColor = const Color(0xffD4AF37);
      textColor = const Color(0xff3D291C);
      iconData = Icons.info_outline_rounded;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 4,
      duration: duration,
      backgroundColor: backgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor.withValues(alpha: 0.5), width: 1.2),
      ),
      content: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: borderColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}