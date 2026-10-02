import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/models/customer_model.dart';
import 'package:intl/intl.dart';
class CustomerHeaderCard extends StatelessWidget {
  final CustomerModel customer;
  const CustomerHeaderCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    final isPaid = customer.balance <= 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              customer.name.isNotEmpty ? customer.name[0] : '؟',
              style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          Text(customer.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          if (customer.phone.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(customer.phone,
                textDirection: ui.TextDirection.ltr,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
          const SizedBox(height: 14),
          const Text('المتبقي عليه', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            '${NumberFormat.decimalPattern('ar').format(customer.balance)} ريال',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: isPaid ? AppColors.success : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}