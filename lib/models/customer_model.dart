
import 'package:management_debts_app/core/constants/app_constsnt.dart';


/// يمثل زبون واحد تابع لبقالة معينة
class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final double balance; // المتبقي عليه (محسوب من العمليات — Denormalized)
  final DateTime? lastTransactionAt;
  final DateTime? nextDueDate; // أقرب تاريخ استحقاق دين لم يُسدد بعد

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.balance = 0,
    this.lastTransactionAt,
    this.nextDueDate,
  });

  /// حالة الزبون تُستخدم في فلترة شاشة الزبائن
  String get status {
    if (balance <= 0) return AppConstants.statusPaid;
    if (nextDueDate != null && nextDueDate!.isBefore(DateTime.now())) {
      return AppConstants.statusOverdue;
    }
    return AppConstants.statusOwing;
  }

  factory CustomerModel.fromMap(String id, Map<String, dynamic> map) {
    return CustomerModel(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      balance: (map['balance'] ?? 0).toDouble(),
     // lastTransactionAt: (map['lastTransactionAt'] as Timestamp?)?.toDate(),
     // nextDueDate: (map['nextDueDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'balance': balance,
      'lastTransactionAt': lastTransactionAt,
      'nextDueDate': nextDueDate,
    };
  }
}
