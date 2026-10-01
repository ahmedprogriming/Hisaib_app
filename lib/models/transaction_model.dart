import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:management_debts_app/core/constants/app_constsnt.dart';


/// يمثل عملية واحدة (دين أو دفعة).
/// مهم: هذا سجل Append-only — لا نعدّل عليه، فقط نضيف عمليات جديدة،
/// والرصيد يُحسب من مجموع كل العمليات (يحمي من تعارض المزامنة أوفلاين).
class TransactionModel {
  final String id;
  final String storeId;
  final String customerId;
  final double amount; // موجب = دين، سالب = دفعة (أو استخدم type للتمييز)
  final String type; // debt | payment
  final String? description;
  final DateTime date;
  final DateTime? dueDate;
  final bool isSynced; // للتتبع المحلي فقط قبل رفعها للسيرفر

  TransactionModel({
    required this.id,
    required this.storeId,
    required this.customerId,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
    this.dueDate,
    this.isSynced = false,
  });

  bool get isDebt => type == AppConstants.transactionTypeDebt;

  factory TransactionModel.fromMap(String id, Map<String, dynamic> map) {
    return TransactionModel(
      id: id,
      storeId: map['storeId'] ?? '',
      customerId: map['customerId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? AppConstants.transactionTypeDebt,
      description: map['description'],
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
      isSynced: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'customerId': customerId,
      'amount': amount,
      'type': type,
      'description': description,
      'date': date,
      'dueDate': dueDate,
    };
  }
}
