import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:url_launcher/url_launcher.dart';

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
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(elevation: 0, backgroundColor: AppColors.background),
        body: const Center(
          child: Text(
            'هذا العميل غير موجود',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تفاصيل العميل',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.textSecondary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: PopupMenuButton(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textPrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              position: PopupMenuPosition.under,
              onSelected: (value) {
                if (value == 'edit') _showEditDialog(context, customer);
                if (value == 'delete') {
                  _confirmDelete(context, customer, customersProvider.storeId);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 12),
                      Text('تعديل البيانات'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppColors.danger,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'حذف العميل',
                        style: TextStyle(color: AppColors.danger),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          CustomerHeaderCard(customer: customer),
          const SizedBox(height: 24),

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
                  icon: const Icon(
                    Icons.payments_outlined,
                    color: AppColors.success,
                  ),
                  label: const Text(
                    'إضافة دفعة',
                    style: TextStyle(color: AppColors.success),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success.withValues(alpha: 0.1),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                  icon: const Icon(
                    Icons.add_shopping_cart_rounded,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'إضافة دين',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.danger, // أو اللون الأساسي للتطبيق
                    elevation: 4,
                    shadowColor: AppColors.danger.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'سجل المعاملات',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              Icon(
                Icons.history_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TransactionsList(
            storeId: customersProvider.storeId,
            customerId: customer.id,
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () => _shareStatement(context, customer),

            icon: FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Colors.white,
              size: 20,
            ),
            label: const Text(
              'إرسال كشف الحساب',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366), // لون واتساب الرسمي
              elevation: 4,
              shadowColor: const Color(0xFF25D366).withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'تعديل بيانات العميل',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'اسم العميل',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'أدخل اسم العميل' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'حفظ التعديلات',
              style: TextStyle(color: Colors.white),
            ),
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.danger,
              size: 28,
            ),
            SizedBox(width: 8),
            Text('حذف العميل', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          hasDebt
              ? 'تنبيه: هذا العميل عليه ${NumberFormat.decimalPattern('ar').format(customer.balance)} ريال لم يُسدد بعد.\nحذفه سيخفيه من قوائمك، لكن سجل عملياته السابقة يبقى محفوظاً في التقارير التاريخية. هل تريد المتابعة؟'
              : 'هل أنت متأكد من حذف "${customer.name}"؟ سجل عملياته السابقة يبقى محفوظاً في التقارير التاريخية.',
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'نعم، احذف',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await FirebaseSevice().deleteCustomer(
      storeId: storeId,
      customerId: customer.id,
    );

    if (!context.mounted) return;
    Navigator.pop(context); // نرجع لقائمة الزبائن بعد الحذف
  }
}

Future<void> _shareStatement(
  BuildContext context,
  CustomerModel customer,
) async {
  final storeId = context.read<CustomersProvider>().storeId;
  final firebaseService = FirebaseSevice();

  // نجلب آخر العمليات مرة واحدة (وليس Stream) فقط لغرض تجميع نص المشاركة
  final snapshot = await firebaseService
      .transactionsRef(storeId, customer.id)
      .orderBy('date', descending: true)
      .limit(10)
      .get();

  final transactions = snapshot.docs
      .map(
        (d) => TransactionModel.fromMap(d.id, d.data() as Map<String, dynamic>),
      )
      .toList();

  final buffer = StringBuffer()
    ..writeln('كشف حساب — ${customer.name}')
    ..writeln(DateFormat('yyyy/MM/dd', 'ar').format(DateTime.now()))
    ..writeln('—' * 20)
    ..writeln(
      'المتبقي عليه: ${NumberFormat.decimalPattern('ar').format(customer.balance)} ريال',
    )
    ..writeln('—' * 20);

  for (final t in transactions) {
    final sign = t.isDebt ? '+' : '-';
    final label = t.isDebt ? 'مشتريات' : 'دفعة';
    buffer.writeln(
      '${DateFormat('d/M', 'ar').format(t.date)}  •  $label  $sign${NumberFormat.decimalPattern('ar').format(t.amount)} ريال',
    );
  }
  final message = buffer.toString();
  final cleanedPhone = formatPhoneForWhatsApp(customer.phone);
  if (!context.mounted) return;
  final whatsappUri = Uri.parse(
    'https://wa.me/$cleanedPhone?text=${Uri.encodeComponent(message)}',
  );
  await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
}

String formatPhoneForWhatsApp(String phone) {
  // تنظيف الرقم من المسافات وأي رموز غير رقمية
  String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');

  // إزالة الصفر في البداية إن وجد (مثل 078xxxxxx)
  if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }

  if (!digits.startsWith('967')) {
    digits = '967$digits';
  }

  return digits;
}
