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
        borderRadius: BorderRadius.circular(14),
        gradient: onTap != null
            ? const LinearGradient(
                colors: [AppColors.primary, AppColors.warning],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: onTap == null ? Colors.grey.shade300 : null,
        boxShadow: onTap != null
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
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
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
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