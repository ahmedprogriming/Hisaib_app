import 'package:flutter/material.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String namebutton;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.namebutton,
    required this.onTap,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), // تم التعديل إلى 16 ليتماشى مع انحناءات التصميم الجديد
        gradient: onTap != null
            ? const LinearGradient(
                // استخدام الفيروزي والأخضر الزمردي لتدرج عصري ونظيف
                colors: [AppColors.primary, AppColors.success],
                begin: Alignment.centerRight, // يبدأ من اليمين لدعم الواجهة العربية
                end: Alignment.centerLeft,
              )
            : null,
        color: onTap == null ? Colors.grey.shade300 : null,
        boxShadow: onTap != null
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3), // ظل ناعم بلون التطبيق الأساسي
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onTap,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        namebutton,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700, // زيادة سمك الخط ليكون أوضح
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}