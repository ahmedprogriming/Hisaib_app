import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/providers/customers_provider.dart';
import 'package:management_debts_app/services/firebase_sevice.dart';
import 'package:management_debts_app/widgets/report_state_card.dart';
import 'package:management_debts_app/widgets/topDebt_orTole.dart';
import 'package:provider/provider.dart';
/// فلتر الفترة (اليوم/الأسبوع/الشهر) + كروت الإحصائيات + أعلى الحسابات مديونية
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {

    String _period = 'month';
 final totals='15000';
  ({DateTime start, DateTime end}) _rangeFor(String period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (period) {
      case 'day':
        return (start: today, end: today.add(const Duration(days: 1)));
      case 'week':
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return (start: startOfWeek, end: startOfWeek.add(const Duration(days: 7)));
      case 'month':
      default:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final startOfNextMonth = DateTime(now.year, now.month + 1, 1);
        return (start: startOfMonth, end: startOfNextMonth);
    }
  }

  
  String _formatRange(DateTime start, DateTime end) {
    final formatter = DateFormat('d MMMM', 'ar');
    final displayEnd = end.subtract(const Duration(days: 1));
    return '${formatter.format(start)} — ${formatter.format(displayEnd)}';
  }

  @override
  Widget build(BuildContext context) {
    final storeId = context.watch<CustomersProvider>().storeId;
    final range = _rangeFor(_period);

    final topDebtors = context.watch<CustomersProvider>().customers
        .where((c) => c.balance > 0)
        .toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));

    return Scaffold(
      backgroundColor: AppColors.background,
  appBar: AppBar(
        title: const Text(
          'التقارير المالية',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
      ),

      body: ListView(
       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
       // 1. شريط تبديل الفترات
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textSecondary.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildPeriodTab('day', 'اليوم'),
                _buildPeriodTab('week', 'هذا الأسبوع'),
                _buildPeriodTab('month', 'هذا الشهر'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 4),
              Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'الفترة: ${_formatRange(range.start, range.end)}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),

                  FutureBuilder(
            key: ValueKey('$_period-$storeId'),
            future: FirebaseSevice().getPeriodTotals(
              storeId: storeId,
              start: range.start,
              end: range.end,
            ),
            
            builder: (context, snapshot) {
              
            
                     if (snapshot.hasError) {

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.danger),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'حدث خطأ أثناء تحميل البيانات, يرجى المحاولة لاحقاً.تأكد من اتصالك بالإنترنت.',
                              style: TextStyle(color: AppColors.danger, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ),
                    ],
                  ),
                );
              }
                final totals = snapshot.data;
                final isLoading = snapshot.connectionState == ConnectionState.waiting;
             return  GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
               mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.35,
                children: [
                  ReportStatCard(
                    icon: Icons.trending_down_rounded,
                    iconColor: AppColors.success,
                    label: 'إجمالي المقبوضات',
                    value: isLoading
                       ? 'جاري التحميل...'
                        : '${NumberFormat.decimalPattern('ar').format(totals?.totalPayments ?? 0)} ريال',
                  ),
                  ReportStatCard(
                   icon: Icons.trending_up_rounded,
                    iconColor: AppColors.danger,
                   label: 'إجمالي الديون الجديدة',
                    value: isLoading
                        ? 'جاري التحميل...'
                        : '${NumberFormat.decimalPattern('ar').format(totals?.totalDebtAdded ?? 0)} ريال',
                  ),
                  ReportStatCard(
                   icon: Icons.people_outline_rounded,
                    iconColor: AppColors.primary,
                    label: 'المدينون الحاليون',
                    value: '${topDebtors.length} عميل',
                  ),
                  ReportStatCard(
                  icon: Icons.account_balance_wallet_outlined,
                    iconColor: const Color(0xFFE65100),
                    label: 'إجمالي ديون السوق',
                    value:
                        '${NumberFormat.decimalPattern('ar').format(context.watch<CustomersProvider>().totalOwed)} ريال',
                  ),
                ],
              );
      
            },
            
          ),
         
 const SizedBox(height: 32),
         // 3. قسم أعلى المدينين
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'أعلى العملاء مديونية',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.12)),
                ),
                child: Text(
                  'أعلى ${topDebtors.take(5).length}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

            if (topDebtors.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.08)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 44,
                    color: AppColors.success.withValues(alpha:0.7),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'لا توجد ديون مسجلة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'جميع الحسابات والعملاء مسددة بالكامل!',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ...topDebtors.take(5).map((c) => TopDebtorTile(customer: c)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String key, String title) {
    final isSelected = _period == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _period = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}