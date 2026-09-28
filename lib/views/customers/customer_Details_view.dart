import 'package:flutter/material.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/models/customer_model.dart';
import 'package:intl/intl.dart';

/// شاشة تفاصيل الزبون — تطابق الصورة الثالثة والرابعة:
/// معلومات الزبون + زر دفعة/دين + سجل المعاملات + إرسال كشف الحساب
class CustomerDetailsPage extends StatelessWidget {
    final String customerId;
  const CustomerDetailsPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
      final customersProvider = 'context.watch<CustomersProvider>()';

    // نبحث عن الزبون داخل القائمة المحمّلة أصلاً بدل طلب مستقل من الشبكة —
    // هذا يخلي الشاشة تفتح فوراً حتى بدون إنترنت.
    final customer = null;
    //customersProvider.customers
        //.cast<CustomerModel?>()
        //.firstWhere((c) => c?.id == customerId, orElse: () => null);

    if (customer == null) {
      return const Scaffold(body: Center(child: Text('تعذر العثور على الزبون')));
    }
    return Scaffold(
       appBar: AppBar(
        title: const Text('تفاصيل الزبون'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _showEditDialog(context, customer);
              if (value == 'delete') _confirmDelete(context, customer, '5'/*customersProvider.storeId*/);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('تعديل بيانات الزبون')),
              PopupMenuItem(
                value: 'delete',
                child: Text('حذف الزبون', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        ],

    )
    );
  }


  
  Future<void> _showEditDialog(BuildContext context, CustomerModel customer) async {
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    final formKey = GlobalKey<FormState>();
   // final storeId = context.read<CustomersProvider>().storeId;

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
                validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل الاسم' : null,
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

   /* await FirebaseService().updateCustomer(
      storeId: storeId,
      customerId: customer.id,
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
    );
    */
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

   // await FirebaseService().deleteCustomer(storeId: storeId, customerId: customer.id);

    if (!context.mounted) return;
    Navigator.pop(context); // نرجع لقائمة الزبائن بعد الحذف
  }
}