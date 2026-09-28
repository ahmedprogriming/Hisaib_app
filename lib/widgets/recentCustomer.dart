
import 'package:flutter/material.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/models/customer_model.dart';
import 'package:management_debts_app/routes/app_routes.dart';
import 'package:intl/intl.dart';

class RecentCustomerTile extends StatelessWidget {
  final CustomerModel customer;
  const RecentCustomerTile({required this.customer});

  @override
  Widget build(BuildContext context) {
    final isPaid = customer.balance <= 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, AppRoutes.customerDetails,
            arguments: customer.id),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Text(
            customer.name.isNotEmpty ? customer.name[0] : '؟',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ),
        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isPaid ? 'مسدد' : 'المتبقي عليه',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text(
              '${NumberFormat.decimalPattern('ar').format(customer.balance)} ريال',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isPaid ? AppColors.success : AppColors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
