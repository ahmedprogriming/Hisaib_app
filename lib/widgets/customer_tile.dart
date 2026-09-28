
import 'package:flutter/material.dart';
import 'package:management_debts_app/core/constants/app_constsnt.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/models/customer_model.dart';
import 'package:management_debts_app/routes/app_routes.dart';
import 'package:intl/intl.dart';

class CustomerTile extends StatelessWidget {
  final CustomerModel customer;
  const CustomerTile({required this.customer});

  ({String label, Color bg, Color fg}) _statusStyle() {
    switch (customer.status) {
      case AppConstants.statusOverdue:
        return (label: 'متأخر', bg: AppColors.dangerBg, fg: AppColors.danger);
      case AppConstants.statusOwing:
        return (label: 'عليه دين', bg: AppColors.warningBg, fg: AppColors.warning);
      default:
        return (label: 'مسدد', bg: AppColors.successBg, fg: AppColors.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.customerDetails,
          arguments: customer.id,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Text(
            customer.name.isNotEmpty ? customer.name[0] : '؟',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ),
        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: customer.phone.isNotEmpty
            ? Text(customer.phone,/* textDirection: TextDirection.ltr*/ textAlign: TextAlign.right)
            : null,
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: style.bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(style.label, style: TextStyle(color: style.fg, fontSize: 11)),
            ),
            const SizedBox(height: 4),
            Text(
              '${NumberFormat.decimalPattern('ar').format(customer.balance)} ريال',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}