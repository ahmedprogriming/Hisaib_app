class AppConstsnt 
{
 static const String appName = 'حسابي';

  // أسماء الـ Collections في Firestore
  static const String storesCollection = 'stores';
  static const String customersSubCollection = 'customers';
  static const String transactionsSubCollection = 'transactions';

  // أنواع العمليات
  static const String transactionTypeDebt = 'debt'; // دين
  static const String transactionTypePayment = 'payment'; // دفعة

  // حالة تسديد الزبون (تُستخدم في الفلاتر)
  static const String statusPaid = 'paid'; // مسدد
  static const String statusOwing = 'owing'; // عليه دين
  static const String statusOverdue = 'overdue'; // متأخر

}