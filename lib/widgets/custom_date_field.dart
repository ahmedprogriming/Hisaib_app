
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
class DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool enabled;
  final VoidCallback? onTap;

  const DateField({
    required this.label,
    required this.date,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = date != null ? DateFormat('yyyy/MM/dd').format(date!) : '—';
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(text, style: const TextStyle(color: AppColors.textPrimary)),
      ),
    );
  }
}