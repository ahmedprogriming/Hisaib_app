import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:management_debts_app/core/constants/app_constsnt.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/providers/customers_provider.dart';
import 'package:management_debts_app/services/firebase_sevice.dart';
import 'package:management_debts_app/widgets/custom_date_field.dart';
import 'package:management_debts_app/widgets/custom_showscanr.dart';
import 'package:management_debts_app/widgets/showAddCustomerDilog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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

  StreamSubscription<DocumentSnapshot>? _storeSub;

  String? _selectedCustomerId;
  DateTime _date = DateTime.now();
  DateTime? _dueDate;
  bool _isSaving = false;

  // 1. القائمة الثابتة للمنتجات الشائعة
  final List<String> _defaultProducts = [
    'ارز',
    'سكر',
    'زيت',
    'دقيق',
    'صلصة',
    'حليب',
    'شاي',
    'بيض',
    'زبادي',
    'بسكويت',
    'دجاج',
    'مرقة دجاج',
    'فاصول',
    'فول',
    'خضار',
    'فاكهة',
    'مياه',
    'مشروبات غازية',
    'عصائر',
    'شامبو',
    'صابون',
    'منظفات',
    ' تونة صغيرة',
    'تونة كبيرة',
    'معلبات',
    'مربى',
    'عصير برتقال',
    'عصير تفاح',
    'عصير مانجو',
    'عصير أناناس',
    'سمن مبروك',
    'زبدة',
    'جبنة مالحة',
    ' كريمة',
    'سمن',
    'قشطة',
    'سمن اريج',
    'سمن عبير',
    'صابون كريستال',
    'حنظل',
    'شاي اخضر',

    'طحينة حلاوة',
    'عسل',
    'جبن',
    'قهوة',
    'معكرونة',
    'شوربة سريعة التحضير',
    'فواكه مجففة',
    'مكسرات',
    'بهارات',
    'زيوت نباتية',
    'زيوت زيتون',

    "هيل حبوب",
    "طماطم حب",
    "بطاطس حب",
    "كراميل",

    "سمن اريج",
    "ليمون",
    "خل ابيض",
    "اعواد كبريت",
    "فانيليا",
  ];
  // قائمة لتخزين المنتجات الخاصة بالمتجر
  List<String> _storeCustomProducts = [];

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = widget.initialCustomerId;
    _type = widget.initialType ?? AppConstants.transactionTypeDebt;

    // 2. جلب المنتجات المخصصة للمتجر من قاعدة البيانات عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeId = context.read<CustomersProvider>().storeId;
      if (storeId.isNotEmpty) {
        _storeSub = FirebaseFirestore.instance
            .collection(AppConstants.storesCollection)
            .doc(storeId)
            .snapshots()
            .listen((doc) {
              if (doc.exists && doc.data()!.containsKey('customProducts')) {
                if (mounted) {
                  setState(() {
                    _storeCustomProducts = List<String>.from(
                      doc.data()!['customProducts'],
                    );
                  });
                }
              }
            });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _storeSub?.cancel();
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
      showSnackbar(
        context,
        'الرجاء اختيار العميل أولاً',
        type: SnackBarType.info,
      );

      return;
    }

   // إزالة الفواصل قبل الحفظ في قاعدة البيانات
final cleanAmountText = _amountController.text.replaceAll(',', '').trim();
final amount = double.parse(cleanAmountText);
    String description = _descController.text.trim();
    if (description.endsWith('-')) {
      description = description.substring(0, description.length - 1).trim();
    }
    final storeId = context.read<CustomersProvider>().storeId;

    setState(() => _isSaving = true);

    try {
      _firebaseService.addTransaction(
        storeId: storeId,
        customerId: _selectedCustomerId!,
        amount: amount,
        type: _type,
        description: description.isEmpty ? null : description,
        dueDate: _dueDate,
      );

      // 3. حفظ المنتج الجديد إذا كان ديناً ولم يكن مسجلاً في أي من القائمتين
      if (_type == AppConstants.transactionTypeDebt && description.isNotEmpty) {
        // تقسيم النص بناءً على علامة (-) للحصول على كل منتج لوحده
        final items = description
            .split('-')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        List<String> newProducts = [];

        for (var item in items) {
          // إذا كان المنتج غير موجود في القائمة الافتراضية ولا قائمة المتجر، أضفه كمنتج جديد
          if (!_defaultProducts.contains(item) &&
              !_storeCustomProducts.contains(item)) {
            newProducts.add(item);
          }
        }
        // حفظ المنتجات الجديدة في فايربيس في وضع الأوفلاين كدفعة واحدة
        if (newProducts.isNotEmpty) {
          FirebaseFirestore.instance
              .collection(AppConstants.storesCollection)
              .doc(storeId)
              .set({
                'customProducts': FieldValue.arrayUnion(newProducts),
              }, SetOptions(merge: true))
              .catchError((_) {});
        }
      }

      if (mounted) {
        Navigator.pop(context);
        showSnackbar(
          context,
          'تم تسجيل المعاملة بنجاح',
          type: SnackBarType.success,
        );
      }
    } catch (_) {
      if (mounted) {
        showSnackbar(
          context,
          'حدث خطأ أثناء حفظ المعاملة. تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
          type: SnackBarType.error,
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomersProvider>().customers;
    final isDebt = _type == AppConstants.transactionTypeDebt;
    final primaryThemeColor = isDebt ? AppColors.danger : AppColors.success;
    final isValidCustomer = customers.any((c) => c.id == _selectedCustomerId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'تسجيل معاملة',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. أزرار تبديل نوع المعاملة
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
                    Expanded(
                      child: _buildTypeToggle(
                        label: 'تسجيل دين',
                        icon: Icons.add_shopping_cart_rounded,
                        isSelected: isDebt,
                        activeColor: AppColors.danger,
                        onTap: () => setState(
                          () => _type = AppConstants.transactionTypeDebt,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildTypeToggle(
                        label: 'تسجيل دفعة',
                        icon: Icons.payments_rounded,
                        isSelected: !isDebt,
                        activeColor: AppColors.success,
                        onTap: () => setState(
                          () => _type = AppConstants.transactionTypePayment,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. بطاقة النموذج الرئيسية
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textSecondary.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // حقل اختيار العميل مع زر الإضافة السريعة
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: isValidCustomer
                                ? _selectedCustomerId
                                : null,
                            decoration: InputDecoration(
                              labelText: 'العميل *',
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            isExpanded: true,
                            hint: const Text('اختر العميل المعني'),
                            items: customers
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(
                                      c.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedCustomerId = v),
                            validator: (v) =>
                                v == null ? 'يرجى اختيار العميل' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: IconButton(
                            onPressed: _handleAddCustomer,
                            icon: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: AppColors.primary,
                            ),
                            tooltip: 'عميل جديد',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // حقل المبلغ البارز
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ThousandsSeparatorInputFormatter(),
                      ],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryThemeColor,
                      ),
                      decoration: InputDecoration(
                        labelText: 'المبلغ *',
                        prefixIcon: Icon(
                          Icons.attach_money_rounded,
                          color: primaryThemeColor,
                        ),

                        suffixText: 'ريال',
                        suffixStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'أدخل المبلغ المطلوب';
                        }
                        // إزالة الفواصل قبل التحقق
                        final cleanValue = v.replaceAll(',', '').trim();
                        final parsed = double.tryParse(cleanValue);

                        if (parsed == null || parsed <= 0) {
                          return 'أدخل مبلغاً صالحاً أكبر من صفر';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    Autocomplete<String>(
                      // هذه الدالة تتحكم في النص الذي سيظهر بعد النقر على منتج من القائمة
                      displayStringForOption: (option) {
                        final text = _descController.text;
                        final parts = text.split('-');

                        if (parts.isNotEmpty) {
                          parts[parts.length - 1] = ' $option - ';
                        } else {
                          return '$option - ';
                        }
                        String result = parts.join('-');
                        if (result.startsWith(' ')) {
                          result = result.substring(1);
                        }

                        return result;
                      },
                      // هذه الدالة تتحكم في البحث وعرض النتائج
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        final text = textEditingValue.text;
                        if (text.isEmpty) return const Iterable<String>.empty();

                        // نأخذ فقط آخر كلمة بعد علامة (-) للبحث عنها
                        final parts = text.split('-');
                        final query = parts.last.trim().toLowerCase();

                        if (query.isEmpty) {
                          return const Iterable<String>.empty();
                        }

                        final allProducts = [
                          ..._defaultProducts,
                          ..._storeCustomProducts,
                        ];
                        return allProducts.where(
                          (product) => product.toLowerCase().contains(query),
                        );
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                            controller.addListener(() {
                              _descController.text = controller.text;
                            });
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'البيان / المنتجات (اختياري)',
                                hintText: isDebt
                                    ? 'اكتب اسم المنتج أو اختر من القائمة...'
                                    : 'مثال: دفعة عبر الحوالة...',
                                helperText:
                                    'لفصل المنتجات يدوياً، انقر على زر ( + ) بين كل منتج والآخر',
                                prefixIcon: const Icon(Icons.notes_rounded),
                                suffixIcon: isDebt
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.add_box_outlined,
                                          color: AppColors.primary,
                                        ),
                                        tooltip: 'إضافة منتج آخر',
                                        onPressed: () {
                                          final text = controller.text;
                                          if (text.isNotEmpty &&
                                              !text.trim().endsWith('-')) {
                                            controller.text = '$text - ';
                                            controller.selection =
                                                TextSelection.fromPosition(
                                                  TextPosition(
                                                    offset:
                                                        controller.text.length,
                                                  ),
                                                );
                                          } else {
                                            showSnackbar(
                                              context,
                                              'الرجاء كتابة اسم المنتج قبل إضافة منتج آخر',
                                              type: SnackBarType.info,
                                            );
                                          }
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            );
                          },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              // تحديد عرض القائمة المنسدلة بناءً على مساحة الشاشة الحالية
                              width: MediaQuery.of(context).size.width - 40,
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String option = options.elementAt(
                                    index,
                                  );
                                  return ListTile(
                                    title: Text(option),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // التواريخ
                    Row(
                      children: [
                        Expanded(
                          child: DateField(
                            label: 'تاريخ المعاملة',
                            date: _date,
                            enabled: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DateField(
                            label: 'الاستحقاق (اختياري)',
                            date: _dueDate,
                            onTap: _pickDueDate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryThemeColor,
                  elevation: 4,
                  shadowColor: primaryThemeColor.withValues(alpha: 0.35),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isDebt ? 'حفظ الدين' : 'حفظ الدفعة',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ودجت زر التبديل المخصص
  Widget _buildTypeToggle({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // إزالة الفواصل السابقة للتعامل مع الرقم الصافي
    String cleanText = newValue.text.replaceAll(',', '');

    // منع إدخال أكثر من نقطة عشرية واحدة
    if (cleanText.split('.').length > 2) {
      return oldValue;
    }

    // فصل الرقم الصحيح عن الكسور العشرية (إن وجدت)
    List<String> parts = cleanText.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    String formattedInteger = '';
    if (integerPart.isNotEmpty) {
      // تنسيق الرقم الصحيح بإضافة فواصل الألوف
      formattedInteger = NumberFormat(
        '#,##0',
        'en_US',
      ).format(int.parse(integerPart));
    }

    String finalString = formattedInteger + decimalPart;

    // إعادة النص المنسق ووضع المؤشر في نهاية النص
    return TextEditingValue(
      text: finalString,
      selection: TextSelection.collapsed(offset: finalString.length),
    );
  }
}
