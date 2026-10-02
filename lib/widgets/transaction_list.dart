import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/models/transaction_model.dart';
import 'package:management_debts_app/services/firebase_sevice.dart';
import 'package:intl/intl.dart';
class TransactionsList extends StatelessWidget {
  final String storeId;
  final String customerId;
  const TransactionsList({required this.storeId, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseSevice().watchTransactions(storeId, customerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('لا توجد معاملات بعد', style: TextStyle(color: AppColors.textSecondary)),
            ),
          );
        }

        final transactions = docs
            .map((d) => TransactionModel.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList();

        return Column(
          children: transactions.map((t) => _TransactionTile(transaction: t)).toList(),
        );
      },
    );
  }
}


class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  const _TransactionTile({required this.transaction});

  String _relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(date.year, date.month, date.day))
        .inDays;
    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'أمس';
    if (diff == 2) return 'قبل يومين';
    return DateFormat('d/M', 'ar').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDebt = transaction.isDebt;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDebt ? AppColors.dangerBg : AppColors.successBg),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDebt ? Icons.shopping_cart_outlined : Icons.credit_card,
              size: 16,
              color: isDebt ? AppColors.danger : AppColors.success,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description?.isNotEmpty == true
                      ? transaction.description!
                      : (isDebt ? 'مشتريات' : 'دفعة'),
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                ),
                Text(_relativeDate(transaction.date),
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            '${isDebt ? '+' : '-'}${NumberFormat.decimalPattern('ar').format(transaction.amount)} ريال',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDebt ? AppColors.danger : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
