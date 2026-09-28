import 'package:flutter/material.dart';
import 'package:management_debts_app/core/constants/app_constsnt.dart';
import 'package:management_debts_app/widgets/showAddCustomerDilog.dart';

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

  String _type = AppConstants.transactionTypeDebt;

  String? _selectedCustomerId;
  DateTime _date = DateTime.now();
  DateTime? _dueDate;
  bool _isSaving = false;
  final  custom = [{1:'احممد جميل'},{ 2:'سالم علي'},{3: 'خالد مبروك'}];

  
  Future<void> _handleAddCustomer() async {
    final newId = await showAddCustomerDialog(context);
    if (newId != null && mounted) setState(() => _selectedCustomerId = newId);
  }

  @override
  Widget build(BuildContext context) {
    final customers = custom.toList();
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
                          .map((c) => DropdownMenuItem(value:c.toString() , child: Text('مرحبا')))
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
            ],
          ),
        ),
      ),
    );
  }
}
