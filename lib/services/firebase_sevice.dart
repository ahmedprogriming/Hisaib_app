import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:management_debts_app/core/constants/app_constsnt.dart';

/// طبقة الوصول لـ Firestore — كل الاستعلامات هنا "مقيّدة" بـ storeId
/// حتى نضمن عزل بيانات كل بقالة عن الثانية (Multi-tenant isolation).
class FirebaseSevice {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// يجب استدعاؤها مرة وحدة عند بداية التطبيق (main.dart)
  static Future<void> enableOfflinePersistence() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  DocumentReference storeDoc(String storeId) =>
      _db.collection(AppConstants.storesCollection).doc(storeId);

  Stream<DocumentSnapshot> watchStore(String storeId) {
    if (storeId.isEmpty) return const Stream.empty();
    return storeDoc(storeId).snapshots();
  }

  Future<void> updateStore({
    required String storeId,
    required String name,
    required String phone,
    required String currency,
  }) {
    return storeDoc(
      storeId,
    ).update({'name': name, 'phone': phone, 'currency': currency});
  }

  /// تعديل اسم/هاتف الزبون فقط — لا يمس الرصيد أو سجل العمليات إطلاقاً
  Future<void> updateCustomer({
    required String storeId,
    required String customerId,
    required String name,
    required String phone,
  }) {
    return customersRef(
      storeId,
    ).doc(customerId).update({'name': name, 'phone': phone});
  }

  Future<void> deleteCustomer({
    required String storeId,
    required String customerId,
  }) {
    return customersRef(storeId).doc(customerId).delete();
  }

  /// يستورد نسخة احتياطية سابقة (customers + transactions) بنفس المعرّفات
  /// الأصلية حتى لا يتكرر الاستيراد لو نُفّذ أكثر من مرة بالخطأ.
  /// أي عملية موجودة مسبقاً بنفس الـ id تُرفض تلقائياً من قاعدة الأمان
  /// (لأن العمليات Append-only) فنعدّها "متجاوزة" وليست فشلاً حقيقياً.
  Future<
    ({int customersRestored, int transactionsRestored, int transactionsSkipped})
  >
  importBackup({
    required String storeId,
    required Map<String, dynamic> backupData,
  }) async {
    int customersRestored = 0;
    int transactionsRestored = 0;
    int transactionsSkipped = 0;

    final customers = (backupData['customers'] as List?) ?? [];

    for (final rawCustomer in customers) {
      final customer = Map<String, dynamic>.from(rawCustomer as Map);
      final customerId = customer['id'] as String;

      await customersRef(storeId).doc(customerId).set({
        'name': customer['name'],
        'phone': customer['phone'],
        'balance': (customer['balance'] ?? 0).toDouble(),
        if (customer['lastTransactionAt'] != null)
          'lastTransactionAt': DateTime.tryParse(customer['lastTransactionAt']),
        if (customer['nextDueDate'] != null)
          'nextDueDate': DateTime.tryParse(customer['nextDueDate']),
      }, SetOptions(merge: true));
      customersRestored++;

      final transactions = (customer['transactions'] as List?) ?? [];
      for (final rawTxn in transactions) {
        final txn = Map<String, dynamic>.from(rawTxn as Map);
        final txnId = txn['id'] as String;
        try {
          await transactionsRef(storeId, customerId).doc(txnId).set({
            'storeId': storeId,
            'customerId': customerId,
            'amount': (txn['amount'] ?? 0).toDouble(),
            'type': txn['type'],
            'description': txn['description'],
            'date': DateTime.tryParse(txn['date'] ?? '') ?? DateTime.now(),
            if (txn['dueDate'] != null)
              'dueDate': DateTime.tryParse(txn['dueDate']),
          });
          transactionsRestored++;
        } on FirebaseException {
          // متوقع لو العملية مستوردة من قبل — العمليات Append-only لا تُستبدل
          transactionsSkipped++;
        }
      }
    }

    return (
      customersRestored: customersRestored,
      transactionsRestored: transactionsRestored,
      transactionsSkipped: transactionsSkipped,
    );
  }

  /// يجمع نسخة كاملة من بيانات البقالة (زبائن + عمليات) كخريطة واحدة
  /// جاهزة للتحويل إلى JSON. يُستخدم في زر "تصدير نسخة احتياطية" فقط،
  /// وليس عملية تحدث باستمرار، فقراءة كل البيانات مرة واحدة هنا مقبولة.
  Future<Map<String, dynamic>> exportBackup(String storeId) async {
    final storeSnap = await storeDoc(storeId).get();
    final customersSnap = await customersRef(storeId).get();

    final customersData = <Map<String, dynamic>>[];
    for (final customerDoc in customersSnap.docs) {
      final txnsSnap = await transactionsRef(storeId, customerDoc.id).get();
      customersData.add({
        'id': customerDoc.id,
        ...customerDoc.data() as Map<String, dynamic>,
        'transactions': txnsSnap.docs
            .map((t) => {'id': t.id, ...t.data() as Map<String, dynamic>})
            .toList(),
      });
    }

    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'store': storeSnap.data(),
      'customers': customersData,
    };
  }

  // ---------- مرجع مجموعة زبائن بقالة معينة ----------
  CollectionReference customersRef(String storeId) => _db
      .collection(AppConstants.storesCollection)
      .doc(storeId)
      .collection(AppConstants.customersSubCollection);

  // ---------- مرجع مجموعة عمليات زبون معين ----------
  CollectionReference transactionsRef(String storeId, String customerId) =>
      customersRef(
        storeId,
      ).doc(customerId).collection(AppConstants.transactionsSubCollection);

  Future<void> addTransaction({
    required String storeId,
    required String customerId,
    required double amount,
    required String type,
    String? description,
    DateTime? dueDate,
  }) async {
    // 1. جلب بيانات العميل والحد الأقصى للدين أولاً
    final customerSnap = await customersRef(storeId).doc(customerId).get();
    final customerData = customerSnap.data() as Map<String, dynamic>?;
    final currentBalance =
        (customerData?['balance'] as num?)?.toDouble() ?? 0.0;
    final customerName = customerData?['name'] ?? 'غير معروف';
    final customerPhone = customerData?['phone'] ?? '';

    final debtLimit = await getDebtLimit(storeId);

    // حساب الرصيد الجديد محلياً للتحقق منه
    final delta = type == AppConstants.transactionTypeDebt ? amount : -amount;
    final expectedNewBalance = currentBalance + delta;

    final batch = _db.batch();

    final txnDoc = transactionsRef(storeId, customerId).doc();
    batch.set(txnDoc, {
      'storeId': storeId,
      'customerId': customerId,
      'amount': amount,
      'type': type,
      'description': description,
      'date': FieldValue.serverTimestamp(),
      'dueDate': dueDate,
    });

    final customerDoc = customersRef(storeId).doc(customerId);

    final updateData = <String, dynamic>{
      'balance': FieldValue.increment(delta),
      'lastTransactionAt': FieldValue.serverTimestamp(),
    };

    if (type == AppConstants.transactionTypeDebt && dueDate != null) {
      updateData['nextDueDate'] = dueDate;
    }

    batch.update(customerDoc, updateData);

    if (type == AppConstants.transactionTypePayment) {
      batch.update(storeDoc(storeId), {
        'totalPayments': FieldValue.increment(amount),
      });
    }

    if (type == AppConstants.transactionTypeDebt &&
        debtLimit > 0 &&
        expectedNewBalance >= debtLimit) {
      final alertDoc = storeDoc(
        storeId,
      ).collection('debtAlerts').doc(customerId);
      batch.set(alertDoc, {
        'customerId': customerId,
        'customerName': customerName,
        'balance': expectedNewBalance,
        'limit': debtLimit,
        'customerPhone': customerPhone,
        'createdAt': FieldValue.serverTimestamp(),
        'dismissed': false,
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Stream<QuerySnapshot> watchDebtAlerts(String storeId) {
    if (storeId.isEmpty) return const Stream.empty();
    return storeDoc(storeId)
        .collection('debtAlerts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> dismissDebtAlert(String storeId, String alertId) => storeDoc(
    storeId,
  ).collection('debtAlerts').doc(alertId).update({'dismissed': true});

  Future<void> saveDebtLimit(String storeId, double limit) =>
      storeDoc(storeId).set({'debtLimit': limit}, SetOptions(merge: true));

  Future<double> getDebtLimit(String storeId) async {
    final snap = await storeDoc(storeId).get();
    return ((snap.data() as Map<String, dynamic>?)?['debtLimit'] as num?)
            ?.toDouble() ??
        0;
  }

  Future<String> addCustomer({
    required String storeId,
    required String name,
    required String phone,
  }) async {
    final doc = customersRef(storeId).doc();
    await doc.set({
      'name': name,
      'phone': phone,
      'balance': 0,
      'lastTransactionAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Stream<QuerySnapshot> watchCustomers(String storeId) {
    if (storeId.isEmpty) return const Stream.empty();
    return customersRef(
      storeId,
    ).orderBy('lastTransactionAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> watchTransactions(String storeId, String customerId) {
    if (storeId.isEmpty || customerId.isEmpty) return const Stream.empty();
    return transactionsRef(
      storeId,
      customerId,
    ).orderBy('date', descending: true).snapshots();
  }

  Future<double> getTotalPayments(String storeId) async {
    final query = FirebaseFirestore.instance
        .collectionGroup(AppConstants.transactionsSubCollection)
        .where('storeId', isEqualTo: storeId)
        .where('type', isEqualTo: AppConstants.transactionTypePayment);

    final snapshot = await query.aggregate(sum('amount')).get();
    return (snapshot.getSum('amount') ?? 0).toDouble();
  }

  /// مجاميع فترة زمنية معينة لشاشة التقارير (اليوم/الأسبوع/الشهر).
  /// ثلاث قراءات تجميع فقط، بغض النظر عن عدد العمليات الفعلي داخل الفترة.
  Future<({double totalDebtAdded, double totalPayments, int transactionsCount})>
  getPeriodTotals({
    required String storeId,
    required DateTime start,
    required DateTime end,
  }) async {
    final base = FirebaseFirestore.instance
        .collectionGroup(AppConstants.transactionsSubCollection)
        .where('storeId', isEqualTo: storeId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end));

    final debtSnap = await base
        .where('type', isEqualTo: AppConstants.transactionTypeDebt)
        .aggregate(sum('amount'))
        .get();

    final paymentSnap = await base
        .where('type', isEqualTo: AppConstants.transactionTypePayment)
        .aggregate(sum('amount'))
        .get();

    final countSnap = await base.count().get();

    return (
      totalDebtAdded: (debtSnap.getSum('amount') ?? 0).toDouble(),
      totalPayments: (paymentSnap.getSum('amount') ?? 0).toDouble(),
      transactionsCount: countSnap.count ?? 0,
    );
  }

  /// يسجّل "آخر مزامنة ناجحة مع السيرفر" على مستند البقالة بوقت السيرفر (موثوق).
  /// يُقرأ لاحقاً من الكاش عند العمل بدون إنترنت لحساب عدد أيام الانقطاع.
  Future<void> markSynced(String storeId) =>
      storeDoc(storeId).update({'lastSyncAt': FieldValue.serverTimestamp()});

  /// قراءة إجبارية من السيرفر (تفشل لو لا يوجد إنترنت) — لزر "تحقق من الاتصال الآن".
  Future<DocumentSnapshot> fetchStoreFromServer(String storeId) =>
      storeDoc(storeId).get(const GetOptions(source: Source.server));
}
