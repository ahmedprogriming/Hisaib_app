import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/providers/customers_provider.dart';
import 'package:management_debts_app/routes/app_routes.dart';
import 'package:management_debts_app/services/auth_service.dart';
import 'package:management_debts_app/services/firebase_sevice.dart';
import 'package:management_debts_app/widgets/custom_showscanr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _debtLimitController = TextEditingController();
  String _currency = 'ريال يمني';
  double debetNow = 0;

  bool _isSaving = false;
  bool _isExporting = false;
  bool _isImporting = false;
  bool _loadedOnce =
      false; // نمنع إعادة تعبئة الحقول فوق تعديلات المستخدم الحالية

  final _firebaseService = FirebaseSevice();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave(String storeId) async {
    setState(() => _isSaving = true);
    try {
             // التحقق من وجود الإنترنت
        final hasInternet =
            await InternetConnection().hasInternetAccess;

        if (!mounted) return;

        if (!hasInternet) {
          showSnackbar(
            context,
            'لا يوجد اتصال بالإنترنت، تحقق من اتصالك ثم حاول مرة أخرى',
            type: SnackBarType.error,
          );
          return;
        }

      await _firebaseService.updateStore(
        storeId: storeId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        currency: _currency,
      );
      if (!mounted) return;
      showSnackbar(
        context,
        'تم حفظ بيانات البقالة',
        type: SnackBarType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showSnackbar(
        context,
        'تعذر الحفظ، تحقق من اتصالك بالإنترنت',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleBackup(String storeId) async {
    setState(() => _isExporting = true);
    try {
      final data = await _firebaseService.exportBackup(storeId);

      final jsonString = JsonEncoder.withIndent('  ', (obj) {
        if (obj is Timestamp) return obj.toDate().toIso8601String();
        return obj.toString();
      }).convert(data);

      final tempDir = await getTemporaryDirectory();
      final fileName =
          'hisabi-backup-${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);

      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'نسخة احتياطية من بيانات بقالتك',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showSnackbar(
        context,
        'تعذر إنشاء النسخة الاحتياطية',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _handleRestore(String storeId) async {
    // تحذير واضح قبل أي شيء — عملية الاستيراد لا يمكن التراجع عنها بسهولة
    final proceed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('استيراد نسخة احتياطية'),
        content: const Text(
          'سيتم إضافة كل العملاء والعمليات الموجودة في ملف النسخة الاحتياطية '
          'إلى بياناتك الحالية. العمليات المستوردة مسبقاً من قبل لن تتكرر '
          '(محمية تلقائياً)، لكن يُفضّل استخدام هذا فقط على بقالة فارغة أو '
          'نفس البقالة الأصلية لتفادي أي تعارض في البيانات.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('اختيار الملف والمتابعة'),
          ),
        ],
      ),
    );

    if (proceed != true || !mounted) return;

    final pickedFile = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (pickedFile?.path == null) return;

    setState(() => _isImporting = true);
    try {
      final file = File(pickedFile!.path!);
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      final stats = await _firebaseService.importBackup(
        storeId: storeId,
        backupData: data,
      );

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('اكتمل الاستيراد'),
          content: Text(
            'تم استرجاع ${stats.customersRestored} عميل و${stats.transactionsRestored} عملية.'
            '${stats.transactionsSkipped > 0 ? '\n(${stats.transactionsSkipped} عملية كانت مستوردة مسبقاً فتم تجاوزها)' : ''}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showSnackbar(
        context,
        'تعذر قراءة الملف — تأكد أنه ملف نسخة احتياطية صحيح',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await AuthService().signOut();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.splash, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final storeId = context.watch<CustomersProvider>().storeId;

    final isAdmin = AuthService().isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إعدادات المتجر',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firebaseService.watchStore(storeId),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          // نعبّي الحقول أول مرة فقط، حتى ما نمسح تعديل المستخدم
          // لو وصل تحديث جديد من الـ Stream وهو لسه يكتب.
          if (data != null && !_loadedOnce) {
            _nameController.text = data['name'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _currency = data['currency'] ?? 'ريال يمني';
            debetNow =
                double.tryParse(data['debtLimit']?.toString() ?? '') ?? 0.0;

            _debtLimitController.text = debetNow.toString();
            _loadedOnce = true;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // قسم معلومات المتجر
              _buildSectionHeader(
                'معلومات المتجر الأساسية',
                Icons.storefront_rounded,
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildTextField(
                      _nameController,
                      'اسم المتجر',
                      Icons.badge_outlined,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      _phoneController,
                      'رقم الهاتف',
                      Icons.phone_outlined,
                      isPhone: true,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _currency,
                      decoration: _inputDecoration(
                        'العملة',
                        Icons.monetization_on_outlined,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'ريال يمني',
                          child: Text('ريال يمني'),
                        ),
                        DropdownMenuItem(
                          value: 'ريال سعودي',
                          child: Text('ريال سعودي'),
                        ),
                        DropdownMenuItem(
                          value: 'دولار أمريكي',
                          child: Text('دولار أمريكي'),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _currency = v ?? _currency),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_isSaving || storeId.isEmpty)
                            ? null
                            : () => _handleSave(storeId),
                        style: _primaryButtonStyle(),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'حفظ التعديلات',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // قسم تنبيهات الديون
              _buildSectionHeader(
                'نظام تنبيهات الديون',
                Icons.notification_important_rounded,
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _debtLimitController,

                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration:
                          _inputDecoration(
                            'الحد الأقصى للدين (ريال)',
                            Icons.warning_amber_rounded,
                          ).copyWith(
                            helperText:
                                'سيصلك تنبيه إذا تجاوز دين أي عميل هذا المبلغ',
                            helperMaxLines: 2,
                          ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: storeId.isEmpty
                            ? null
                            : () async {
                                // التحقق من وجود الإنترنت
                                final hasInternet = await InternetConnection()
                                    .hasInternetAccess;

                                if (!mounted) return;

                                if (!hasInternet) {
                                  showSnackbar(
                                    context,
                                    'لا يوجد اتصال بالإنترنت، تحقق من اتصالك ثم حاول مرة أخرى',
                                    type: SnackBarType.error,
                                  );
                                  return;
                                }
                                final value = double.tryParse(
                                  _debtLimitController.text.trim(),
                                );
                                if (value == null || value < 0) {
                                  showSnackbar(
                                    context,
                                    'الرجاء إدخال مبلغ صحيح',
                                    type: SnackBarType.error,
                                  );
                                  return;
                                }
                                await _firebaseService.saveDebtLimit(
                                  storeId,
                                  value,
                                );
                                if (mounted) {
                                  showSnackbar(
                                    context,
                                    'تم ضبط الحد الأقصى بنجاح',
                                    type: SnackBarType.success,
                                  );
                                }
                              },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'تفعيل التنبيهات',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // قسم النسخ الاحتياطي
              _buildSectionHeader('النسخ الاحتياطي', Icons.cloud_sync_rounded),
              Container(
                decoration: _cardDecoration(),
                clipBehavior: Clip.antiAlias,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        title: 'تصدير نسخة احتياطية',
                        subtitle: 'حفظ جميع بيانات عملائك في ملف',
                        icon: Icons.cloud_upload_rounded,
                        iconColor: AppColors.primary,
                        isLoading: _isExporting,
                        onTap: _isExporting
                            ? null
                            : () => _handleBackup(storeId),
                      ),
                      const Divider(height: 1, indent: 60),
                      _buildSettingsTile(
                        title: 'استعادة نسخة احتياطية',
                        subtitle: 'استرجاع البيانات من ملف محفوظ سابقاً',
                        icon: Icons.cloud_download_rounded,
                        iconColor: AppColors.success,
                        isLoading: _isImporting,
                        onTap: _isImporting
                            ? null
                            : () => _handleRestore(storeId),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // لوحة تحكم الإدمن وتسجيل الخروج
              Container(
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    if (isAdmin) ...[
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: _buildSettingsTile(
                          title: 'إدارة الاشتراكات (Admin)',
                          subtitle: 'لوحة التحكم بصلاحيات المتاجر',
                          icon: Icons.admin_panel_settings_rounded,
                          iconColor: Colors.deepPurple,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.adminPanel,
                          ),
                        ),
                      ),
                      const Divider(height: 1, indent: 60),
                    ],
                    _buildSettingsTile(
                      title: 'تسجيل خروج',
                      subtitle: 'الخروج من الحساب الحالي بأمان',
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.danger,
                      onTap: _handleLogout,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.textSecondary.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPhone = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      textDirection: isPhone ? TextDirection.ltr : null,
      decoration: _inputDecoration(label, icon),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
      onTap: onTap,
    );
  }
}
