import 'package:flutter/material.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/models/customer_model.dart';
import 'package:management_debts_app/routes/app_routes.dart';
import 'package:intl/intl.dart';

class TopDebtorTile extends StatelessWidget {
  final CustomerModel customer;
  const TopDebtorTile({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface, // لون الخلفية هنا
        borderRadius: BorderRadius.circular(14), // الحواف الدائرية هنا
        clipBehavior: Clip.antiAlias, // لضمان عدم خروج تأثير الضغط عن الحواف الدائرية
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, AppRoutes.customerDetails,
            arguments: customer.id),
        leading: CircleAvatar(
          backgroundColor: AppColors.dangerBg,
          child: Text(
            customer.name.isNotEmpty ? customer.name[0] : '؟',
            style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
          ),
        ),
        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(
          '${NumberFormat.decimalPattern('ar').format(customer.balance)} ريال',
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.danger),
        ),
      ),
    )
    );
  }
}
