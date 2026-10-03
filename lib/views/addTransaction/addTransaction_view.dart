import 'package:flutter/material.dart';
import 'package:management_debts_app/core/constants/app_constsnt.dart';
import 'package:management_debts_app/providers/customers_provider.dart';
import 'package:management_debts_app/services/firebase_sevice.dart';
import 'package:management_debts_app/widgets/custom_date_field.dart';
import 'package:management_debts_app/widgets/custom_showscanr.dart';
import 'package:management_debts_app/widgets/showAddCustomerDilog.dart';
import 'package:provider/provider.dart';

/// قرار تصميم مهم لدعم الأوفلاين الحقيقي:
/// لا ننتظر (await) تأكيد رفع العملية للسيرفر قبل إغلاق الشاشة،
/// لأن Firestore لا "يُنهي" عملية الكتابة فعلياً إلا بعد تأكيد الشبكة،
/// وهذا يجعل الزر "معلّق" لفترة طويلة لو المستخدم بدون إنترنت.
/// بدل ذلك: نحفظ محلياً (يظهر فوراً في الواجهة عبر الـ Stream)
/// وننتقل مباشرة، والرفع يستمر تلقائياً في الخلفية.
///
class AddtransactionPage extends StatefulWidget {
  final String? initialCustomerId;
  final String? initialType;
  const AddtransactionPage({
    super.key,
    this.initialCustomerId,
    this.initialType,
  });

  @override
  State<AddtransactionPage> createState() => _AddtransactionPageState();
}

class _AddtransactionPageState extends State<AddtransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _firebaseService = FirebaseSevice();
  String _type = AppConstants.transactionTypeDebt;

  String? _selectedCustomerId;
  DateTime _date = DateTime.now();
  DateTime? _dueDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = widget.initialCustomerId;
    _type = widget.initialType ?? AppConstants.transactionTypeDebt;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleAddCustomer() async {
    final newId = await showAddCustomerDialog(context);
    if (newId != null && mounted) setState(() => _selectedCustomerId = newId);
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCustomerId == null) {
      showSnackbar(context, 'اختر الزبون أولاً', type: SnackBarType.info);

      return;
    }

    final amount = double.parse(_amountController.text.trim());

    setState(() => _isSaving = true);

    // لا نستخدم await هنا عمداً — راجع التعليق أعلى الملف
    _firebaseService
        .addTransaction(
          storeId: context.read<CustomersProvider>().storeId,
          customerId: _selectedCustomerId!,
          amount: amount,
          type: _type,
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          dueDate: _dueDate,
        )
        .catchError((_) {
          // لو فشلت نهائياً (مو بسبب انقطاع مؤقت) نعرض تنبيه لاحقاً عبر آلية إشعارات مركزية.
          // لا نوقف تدفق المستخدم الحالي لأن الشاشة أصلاً أُغلقت.
        });

    Navigator.pop(context);

    showSnackbar(
      context,
      'تم حفظ العملية، سيُضاف المبلغ تلقائياً إلى «المتبقي»',
      type: SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomersProvider>().customers;
    final isDebt = _type == AppConstants.transactionTypeDebt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل عملية'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: AppConstants.transactionTypeDebt,
                    label: Text('إضافة دين'),
                    icon: Icon(Icons.add_shopping_cart_outlined),
                  ),
                  ButtonSegment(
                    value: AppConstants.transactionTypePayment,
                    label: Text('تسجيل دفعة'),
                    icon: Icon(Icons.payments_outlined),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCustomerId,
                      decoration: const InputDecoration(labelText: 'الزبون'),
                      hint: const Text('اختر الزبون'),
                      items: customers
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCustomerId = v),
                      validator: (v) => v == null ? 'اختر الزبون' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: _handleAddCustomer,
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    tooltip: 'زبون جديد',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'المبلغ',
                  suffixText: 'ريال',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'أدخل المبلغ';
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed <= 0)
                    return 'أدخل مبلغاً صحيحاً أكبر من صفر';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'الوصف (اختياري)',
                  hintText: isDebt ? 'مثال: مشتريات بقالة' : 'مثال: دفعة نقدية',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DateField(
                      label: 'التاريخ',
                      date: _date,
                      enabled: false, // تاريخ اليوم دائماً — غير قابل للتعديل
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DateField(
                      label: 'تاريخ الاستحقاق (اختياري)',
                      date: _dueDate,
                      onTap: _pickDueDate,
                    ),
                  ),

                  
                ],
              ),

              const SizedBox(height: 28),

                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _handleSave,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('حفظ العملية'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
