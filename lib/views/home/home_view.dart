import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/routes/app_routes.dart';
import 'package:management_debts_app/widgets/stateCard.dart';
import 'package:management_debts_app/widgets/totalPaymentCard.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});


  String _formatCurrency(double amount) {
    return NumberFormat.decimalPattern('ar').format(amount);
  }
  @override
  Widget build(BuildContext context) {
     final provider = 'context.watch<CustomersProvider>();';
    final debtorsCount = 15;
    final recentCustomers = "لا يوجد";
    return  Scaffold(
              appBar: AppBar(
        title: const Text('حسابي'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
        ),
      body: SafeArea(child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Container(
                   width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text('إجمالي المتبقي عند الزبائن',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 10),
                  Text(
                    '${_formatCurrency(5000)} ريال',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ),
                   const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TotalPaymentsCard(storeId: '5',),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.people_outline,
                    iconColor: AppColors.primary,
                    label: 'عدد الزبائن المدينين',
                    value: '$debtorsCount',
                  ),
                ),
              ],
            ),
              const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.addTransaction),
              icon: const Icon(Icons.add),
              label: const Text('تسجيل عملية'),
            ),
            const SizedBox(height: 20),

                  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.addTransaction),
                  child: const Text('عرض الكل'),
                ),
                const Text('آخر الحسابات',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
              if (provider.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'لا يوجد زبائن بعد\nاضغط "تسجيل عملية" لإضافة أول زبون',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
          // else
            
             // ...recentCustomers.map((c) => RecentCustomerTile(customer: c)),
        ],

      )),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'الزبائن'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'التقارير'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'الإعدادات'),
        ],
        onDestinationSelected: (i) {
          if (i == 1) Navigator.pushNamed(context, AppRoutes.customers);
          if (i == 2) Navigator.pushNamed(context, AppRoutes.reports);
          if (i == 3) Navigator.pushNamed(context, AppRoutes.settings);
        },
      ),
    );
  }
}