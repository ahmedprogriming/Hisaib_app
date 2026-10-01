import 'package:cloud_firestore/cloud_firestore.dart';

/// يمثل بيانات البقالة الواحدة (المستأجر / Tenant)
class StoreModel {
  final String id;
  final String name;
  final String phone;
  final String currency;
  final DateTime? subscriptionEndsAt;
  final bool isActive;

  StoreModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.currency,
    this.subscriptionEndsAt,
    this.isActive = true,
  });

  factory StoreModel.fromMap(String id, Map<String, dynamic> map) {
    return StoreModel(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      currency: map['currency'] ?? 'ريال يمني',
      subscriptionEndsAt: (map['subscriptionEndsAt'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'currency': currency,
      'subscriptionEndsAt': subscriptionEndsAt,
      'isActive': isActive,
    };
  }
}
