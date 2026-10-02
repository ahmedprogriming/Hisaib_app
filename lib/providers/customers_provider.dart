import 'dart:async';
import 'package:flutter/material.dart';
import 'package:management_debts_app/models/customer_model.dart';
import 'package:management_debts_app/services/firebase_sevice.dart';

class CustomersProvider extends ChangeNotifier {
    final FirebaseSevice _firebaseService = FirebaseSevice();
  final String storeId;
  StreamSubscription? _subscription;

  CustomersProvider({required this.storeId}) {
    // storeId فارغ يعني المستخدم لسه ما سجّل دخول — لا تستمع لأي شيء
    if (storeId.isNotEmpty) _listenToCustomers();
  }

  List<CustomerModel> _customers = [];
  List<CustomerModel> get customers => _customers;

   double get totalOwed =>
      _customers.fold(0, (sum, c) => sum + (c.balance > 0 ? c.balance : 0));

  void _listenToCustomers() {
    _subscription = _firebaseService.watchCustomers(storeId).listen((snapshot) {
      _customers = snapshot.docs
          .map((doc) => CustomerModel.fromMap(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    });
  }

    List<CustomerModel> filterByStatus(String status) {
    if (status == 'all') return _customers;
    return _customers.where((c) => c.status == status).toList();
  }

  /// يُنشئ زبون جديد ويرجّع الـ id فوراً (يعمل حتى بدون إنترنت،
  /// لأن Firestore يولّد الـ id محلياً قبل الرفع للسيرفر).
  Future<String> addCustomer({required String name, required String phone}) {
    return _firebaseService.addCustomer(storeId: storeId, name: name, phone: phone);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}