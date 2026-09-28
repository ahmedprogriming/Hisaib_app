import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

void showSnackbar(
  BuildContext context,
  String message, {
  SnackBarType type = SnackBarType.info,
  Duration duration = const Duration(seconds: 4),
}) {
  // إخفاء أي تنبيه حالي على الفور لمنع تراكم التنبيهات
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  // تحديد اللون والأيقونة حسب نوع التنبيه
  // تم تحديث الألوان هنا لتتناسب مع الشعار الفيروزي
  Color backgroundColor;
  Color borderColor;
  Color textColor;
  IconData iconData;

  // الألوان الأساسية المستخرجة من الشعار للاستخدام كمرجع
  // const Color logoPrimaryTeal = Color(0xff1BCBDC);
  // const Color logoDarkTeal = Color(0xff09838E);

  switch (type) {
    case SnackBarType.success:
      // نجاح: أخضر زمردي مائل للزرقة يتناغم مع الفيروزي
      backgroundColor = const Color(0xffF2FFFD); // فاتح جداً
      borderColor = const Color(0xff00B8A0);     // أخضر زمردي
      textColor = const Color(0xff006155);       // داكن
      iconData = Icons.check_circle_rounded;
      break;
    case SnackBarType.error:
      // خطأ: أحمر قرمزي دافئ يتناقض بشكل جميل مع الفيروزي
      backgroundColor = const Color(0xffFFFAFA); // فاتح جداً
      borderColor = const Color(0xffEF4444);     // أحمر دافئ
      textColor = const Color(0xff8A2121);       // داكن
      iconData = Icons.error_rounded;
      break;
    case SnackBarType.warning:
      // تحذير: برتقالي ذهبي دافئ يتناغم مع الفيروزي
      backgroundColor = const Color(0xffFFFBF2); // فاتح جداً
      borderColor = const Color(0xffFF8F00);     // برتقالي دافئ
      textColor = const Color(0xff8A4D00);       // داكن
      iconData = Icons.warning_rounded;
      break;
    case SnackBarType.info:
    default:
      // معلومات/افتراضي: استخدام لون الشعار الأساسي مباشرة
      backgroundColor = const Color(0xffF2FEFE); // فاتح جداً من الفيروزي
      borderColor = const Color(0xff1BCBDC);     // لون الشعار الفاتح
      textColor = const Color(0xff064F56);       // فيروزي داكن جداً للنص
      iconData = Icons.info_rounded;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 6, // زيادة الظل قليلاً لإبرازه على الخلفيات الملونة
      duration: duration,
      backgroundColor: backgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), // زيادة الهامش السفلي قليلاً
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // زوايا أكثر استدارة لتتناسب مع انحناءات الشعار
        side: BorderSide(color: borderColor.withValues(alpha: 0.4), width: 1.5), // زيادة سماكة الحد قليلاً
      ),
      content: Directionality(
        textDirection: TextDirection.rtl, // تغيير الاتجاه للعربية افتراضياً
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.12), // خلفية أيقونة أكثر نعومة
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: borderColor,
                size: 24, // زيادة حجم الأيقونة قليلاً
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15, // زيادة حجم الخط قليلاً للوضوح
                  fontWeight: FontWeight.w700, // خط أكثر سمكاً ليتناسب مع الشعار
                  height: 1.4,
                  // يمكن إضافة خط مخصص هنا إذا كان متاحاً
                  // fontFamily: 'YourCustomFont', 
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}