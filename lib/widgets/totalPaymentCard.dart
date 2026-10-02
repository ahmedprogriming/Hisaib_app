import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/services/firebase_sevice.dart';
import 'package:management_debts_app/widgets/stateCard.dart';
/// كرت "إجمالي المدفوعات" — يستخدم استعلام تجميع (قراءة واحدة فقط على السيرفر)
/// بدل تحميل كل عمليات كل الزبائن على الجهاز.
class TotalPaymentsCard extends StatelessWidget {
  final String storeId;
  const TotalPaymentsCard({required this.storeId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: FirebaseSevice().getTotalPayments(storeId),
builder: (context, snapshot) {
        final value = snapshot.data;
        return StatCard(
          icon: Icons.credit_card,
          iconColor: AppColors.success,
          label: 'إجمالي المدفوعات',
          value: value == null
              ? '...'
              : '${NumberFormat.decimalPattern('ar').format(value)} ريال',
        );
      },
    );
  }
}