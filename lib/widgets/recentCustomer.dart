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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface, // لون الخلفية هنا
        borderRadius: BorderRadius.circular(14), // الحواف الدائرية هنا
        clipBehavior:
            Clip.antiAlias, // لضمان عدم خروج تأثير الضغط عن الحواف الدائرية
        child: ListTile(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.customerDetails,
            arguments: customer.id,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Center(
              child: Text(
                customer.name.isNotEmpty ? customer.name[0] : '؟',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          title: Text(
            customer.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              isPaid ? 'مسدد بالكامل' : 'المتبقي عليه',
              style: TextStyle(
                fontSize: 12,
                color: isPaid
                    ? AppColors.success.withValues(alpha: 0.8)
                    : AppColors.textSecondary,
              ),
            ),
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${NumberFormat.decimalPattern('ar').format(customer.balance)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isPaid ? AppColors.success : AppColors.danger,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'ريال',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
