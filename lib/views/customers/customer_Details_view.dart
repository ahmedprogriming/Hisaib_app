import 'package:flutter/material.dart';
import 'package:management_debts_app/core/constants/app_constsnt.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/models/customer_model.dart';
import 'package:intl/intl.dart';
import 'package:management_debts_app/models/transaction_model.dart';
import 'package:management_debts_app/providers/customers_provider.dart';
import 'package:management_debts_app/routes/app_routes.dart';
import 'package:management_debts_app/services/firebase_sevice.dart';
import 'package:management_debts_app/widgets/transaction_list.dart';
import 'package:management_debts_app/widgets/transcaction_card.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

/// شاشة تفاصيل الزبون — تطابق الصورة الثالثة والرابعة:
/// معلومات الزبون + زر دفعة/دين + سجل المعاملات + إرسال كشف الحساب
class CustomerDetailsPage extends StatelessWidget {
  final String customerId;
  const CustomerDetailsPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    final customersProvider = context.watch<CustomersProvider>();

    // نبحث عن الزبون داخل القائمة المحمّلة أصلاً بدل طلب مستقل من الشبكة —
    // هذا يخلي الشاشة تفتح فوراً حتى بدون إنترنت.
    final customer = customersProvider.customers
        .cast<CustomerModel?>()
        .firstWhere((c) => c?.id == customerId, orElse: () => null);

    if (customer == null) {
      return const Scaffold(
        body: Center(child: Text('تعذر العثور على الزبون')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الزبون'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _showEditDialog(context, customer);
              if (value == 'delete')
                _confirmDelete(context, customer, customersProvider.storeId);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('تعديل بيانات الزبون')),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  'حذف الزبون',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CustomerHeaderCard(customer: customer),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.addTransaction,
                    arguments: {
                      'customerId': customer.id,
                      'type': AppConstants.transactionTypePayment,
                    },
                  ),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('تسجيل دفعة'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.addTransaction,
                    arguments: {
                      'customerId': customer.id,
                      'type': AppConstants.transactionTypeDebt,
                    },
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة دين'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text('سجل المعاملات', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          const SizedBox(height: 10),

          TransactionsList(storeId: customersProvider.storeId, customerId: customer.id),

          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _shareStatement(context, customer),
            icon: const Icon(Icons.ios_share_outlined),
            label: const Text('إرسال كشف الحساب'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    CustomerModel customer,
  ) async {
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    final formKey = GlobalKey<FormState>();
     final storeId = context.read<CustomersProvider>().storeId;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل بيانات الزبون'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الزبون'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'أدخل الاسم' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                // textDirection: TextDirection.ltr,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate())
                Navigator.pop(context, true);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

     await FirebaseSevice().updateCustomer(
      storeId: storeId,
      customerId: customer.id,
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
    );
    
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CustomerModel customer,
    String storeId,
  ) async {
    final hasDebt = customer.balance > 0;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الزبون'),
        content: Text(
          hasDebt
              ? 'تنبيه: هذا الزبون عليه ${NumberFormat.decimalPattern('ar').format(customer.balance)} ريال لم يُسدد بعد.\nحذفه سيخفيه من قوائمك، لكن سجل عملياته السابقة يبقى محفوظاً في التقارير التاريخية. هل تريد المتابعة؟'
              : 'هل أنت متأكد من حذف "${customer.name}"؟ سجل عملياته السابقة يبقى محفوظاً في التقارير التاريخية.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

     await FirebaseSevice().deleteCustomer(storeId: storeId, customerId: customer.id);

    if (!context.mounted) return;
    Navigator.pop(context); // نرجع لقائمة الزبائن بعد الحذف
  }

  
}

Future<void> _shareStatement(BuildContext context, CustomerModel customer) async {
    final storeId = context.read<CustomersProvider>().storeId;
    final firebaseService = FirebaseSevice();

    // نجلب آخر العمليات مرة واحدة (وليس Stream) فقط لغرض تجميع نص المشاركة
    final snapshot = await firebaseService.transactionsRef(storeId, customer.id)
        .orderBy('date', descending: true)
        .limit(10)
        .get();

    final transactions = snapshot.docs
        .map((d) => TransactionModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();

    final buffer = StringBuffer()
      ..writeln('كشف حساب — ${customer.name}')
      ..writeln(DateFormat('yyyy/MM/dd', 'ar').format(DateTime.now()))
      ..writeln('—' * 20)
      ..writeln('المتبقي عليه: ${NumberFormat.decimalPattern('ar').format(customer.balance)} ريال')
      ..writeln('—' * 20);

    for (final t in transactions) {
      final sign = t.isDebt ? '+' : '-';
      final label = t.isDebt ? 'مشتريات' : 'دفعة';
      buffer.writeln(
        '${DateFormat('d/M', 'ar').format(t.date)}  •  $label  $sign${NumberFormat.decimalPattern('ar').format(t.amount)} ريال',
      );
    }

    if (!context.mounted) return;
    await SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

