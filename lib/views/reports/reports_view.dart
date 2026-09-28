import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/widgets/report_state_card.dart';
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
   //  final storeId = context.watch<CustomersProvider>().storeId;
    final range = _rangeFor(_period);

   /* final topDebtors = context.watch<CustomersProvider>().customers
        .where((c) => c.balance > 0)
        .toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));
*/
    return Scaffold(
   appBar: AppBar(title: const Text('التقارير')),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
               SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'day', label: Text('اليوم')),
              ButtonSegment(value: 'week', label: Text('هذا الأسبوع')),
              ButtonSegment(value: 'month', label: Text('هذا الشهر')),
            ],
            selected: {_period},
            onSelectionChanged: (s) => setState(() => _period = s.first),
          ),
          const SizedBox(height: 4),
              Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'الفترة: ${_formatRange(range.start, range.end)}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),

                    // كل تغيير للفترة يشغّل استعلام تجميع جديد — قراءات معدودة فقط
          // بغض النظر عن عدد العمليات الفعلي، حتى لو كانت البقالة عندها آلاف العمليات.
         /* FutureBuilder(
            key: ValueKey(_period),
            future: FirebaseService().getPeriodTotals(
              storeId: storeId,
              start: range.start,
              end: range.end,
            ),
            */
           /* builder: (context, snapshot) {*/
             // final totals = ;
               GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  ReportStatCard(
                    icon: Icons.trending_down,
                    iconColor: AppColors.success,
                    label: 'إجمالي المدفوعات (الفترة)',
                    value: totals == null
                        ? '...'
                        : '${NumberFormat.decimalPattern('ar').format(15000)} ريال',
                  ),
                  ReportStatCard(
                    icon: Icons.trending_up,
                    iconColor: AppColors.danger,
                    label: 'إجمالي الديون (الفترة)',
                    value: totals == null
                        ? '...'
                        : '${NumberFormat.decimalPattern('ar').format(/*totals.totalDebtAdded*/350000)} ريال',
                  ),
                  ReportStatCard(
                    icon: Icons.people_outline,
                    iconColor: AppColors.primary,
                    label: 'عدد الزبائن المدينين',
                    value: '${/*topDebtors.length*/100}',
                  ),
                  ReportStatCard(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.warning,
                    label: 'إجمالي المتبقي (الكل)',
                    value:
                        '${NumberFormat.decimalPattern('ar').format(/*context.watch<CustomersProvider>().totalOwed*/16000)} ريال',
                  ),
                ],
              ),
           /* },*/
         /* ),*/
         
          const SizedBox(height: 24),
          const Row(
            children: [
              Text('🏆', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text('أعلى الحسابات مديونية',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),

            if (totals!=null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'لا توجد ديون حالية — كل الحسابات مسدّدة 🎉',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          //else
           // ...topDebtors.take(5).map((c) => _TopDebtorTile(customer: c)),
        ],
      ),
    );
  }
}