import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/providers/customers_provider.dart';
import 'package:management_debts_app/routes/app_routes.dart';
import 'package:management_debts_app/services/firebase_sevice.dart';
import 'package:management_debts_app/widgets/recentCustomer.dart';
import 'package:management_debts_app/widgets/stateCard.dart';
import 'package:management_debts_app/widgets/totalPaymentCard.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _formatCurrency(double amount) {
    return NumberFormat.decimalPattern('ar').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomersProvider>();
    final debtorsCount = provider.customers.where((c) => c.balance > 0).length;
    final recentCustomers = provider.customers.take(3).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // ترويسة احترافية مدمجة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً بك،',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'الرئيسية',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textSecondary.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseSevice().watchDebtAlerts(
                      context.watch<CustomersProvider>().storeId,
                    ),
                    builder: (context, snapshot) {
                      int activeAlertsCount = 0;

                      if (snapshot.hasData) {
                        activeAlertsCount = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return !(data['dismissed'] as bool? ?? false);
                        }).length;
                      }
                      return IconButton(
                        color: AppColors.textPrimary,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.notification);
                        },
                        icon: Badge(
                          // إظهار الدائرة الحمراء فقط إذا كان هناك إشعارات
                          isLabelVisible: activeAlertsCount > 0,
                          // عرض عدد الإشعارات داخل الدائرة (يمكنك حذفه إذا أردت نقطة حمراء فقط)
                          label: Text(
                            '$activeAlertsCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                          child: const Icon(Icons.notifications_none_rounded),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // بطاقة الإجمالي الرئيسية
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'إجمالي المبالغ المستحقة',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${_formatCurrency(provider.totalOwed)} ريال',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // بطاقات الإحصائيات (StatCards)
            Row(
              children: [
                Expanded(child: TotalPaymentsCard(storeId: provider.storeId)),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    icon: Icons.people_outline_rounded,
                    iconColor: AppColors.primary,
                    label: 'المدينون',
                    value: '$debtorsCount',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // زر إضافة معاملة بتصميم بارز
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.addTransaction),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline_rounded, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'إضافة معاملة جديدة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // قسم أحدث الزبائن
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'أحدث العملاء',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.customers),
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // التعامل مع القائمة الفارغة بشكل احترافي
            if (provider.customers.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.textSecondary.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_alt_outlined,
                      size: 48,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'لا يوجد عملاء بعد',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'انقر على "إضافة معاملة جديدة" للبدء بتسجيل ديون عملاءك.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...recentCustomers.map((c) => RecentCustomerTile(customer: c)),
          ],
        ),
      ),
    );
  }
}
