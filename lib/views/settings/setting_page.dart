import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
  String _currency = 'ريال يمني';

  bool _isSaving = false;
  bool _isExporting = false;
  bool _isImporting = false;
  bool _loadedOnce = false; // نمنع إعادة تعبئة الحقول فوق تعديلات المستخدم الحالية

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
      await _firebaseService.updateStore(
        storeId: storeId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        currency: _currency,
      );
      if (!mounted) return;
          showSnackbar(context, 'تم حفظ بيانات البقالة',type:SnackBarType.success);
        
    } catch (e) {
      if (!mounted) return;
      showSnackbar(context, 'تعذر الحفظ، تحقق من اتصالك بالإنترنت', type: SnackBarType.error);
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
      final fileName = 'hisabi-backup-${DateTime.now().millisecondsSinceEpoch}.json';
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
      showSnackbar(context,'تعذر إنشاء النسخة الاحتياطية', type: SnackBarType.error);
     
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
          'سيتم إضافة كل الزبائن والعمليات الموجودة في ملف النسخة الاحتياطية '
          'إلى بياناتك الحالية. العمليات المستوردة مسبقاً من قبل لن تتكرر '
          '(محمية تلقائياً)، لكن يُفضّل استخدام هذا فقط على بقالة فارغة أو '
          'نفس البقالة الأصلية لتفادي أي تعارض في البيانات.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
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

      final stats = await _firebaseService.importBackup(storeId: storeId, backupData: data);

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('اكتمل الاستيراد'),
          content: Text(
            'تم استرجاع ${stats.customersRestored} زبون و${stats.transactionsRestored} عملية.'
            '${stats.transactionsSkipped > 0 ? '\n(${stats.transactionsSkipped} عملية كانت مستوردة مسبقاً فتم تجاوزها)' : ''}',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً')),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
       showSnackbar(context,'تعذر قراءة الملف — تأكد أنه ملف نسخة احتياطية صحيح', type: SnackBarType.error);
     
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
            child: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.danger)),
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
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات'),),
      body:StreamBuilder<DocumentSnapshot>(
        stream: _firebaseService.watchStore( storeId),
        builder: (context, snapshot) {
            final data = snapshot.data?.data() as Map<String, dynamic>?;
         // نعبّي الحقول أول مرة فقط، حتى ما نمسح تعديل المستخدم
          // لو وصل تحديث جديد من الـ Stream وهو لسه يكتب.
          if (data != null && !_loadedOnce) {
            _nameController.text = data['name'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _currency = data['currency'] ?? 'ريال يمني';
            _loadedOnce = true;
          }
        
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('بيانات البقالة',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم البقالة'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  helperText: 'يظهر في كشوف الحساب — يُفضل مع رمز الدولة',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _currency,
                decoration: const InputDecoration(labelText: 'العملة'),
                items: const [
                  DropdownMenuItem(value: 'ريال يمني', child: Text('ريال يمني')),
                  DropdownMenuItem(value: 'ريال سعودي', child: Text('ريال سعودي')),
                  DropdownMenuItem(value: 'دولار أمريكي', child: Text('دولار أمريكي')),
                ],
                onChanged: (v) => setState(() => _currency = v ?? _currency),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (_isSaving || storeId.isEmpty) ? null : () => _handleSave(storeId),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('حفظ البيانات'),
              ),

              const Divider(height: 40),

              ListTile(
                leading: const Icon(Icons.cloud_upload_outlined),
                title: const Text('تصدير نسخة احتياطية'),
                subtitle: const Text('احفظ بيانات بقالتك واسترجعها في أي وقت'),
                trailing: _isExporting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_left),
                onTap: _isExporting ? null : () => _handleBackup(storeId),
              ),
              ListTile(
                leading: const Icon(Icons.cloud_download_outlined),
                title: const Text('استيراد نسخة احتياطية'),
                subtitle: const Text('استرجاع بيانات من ملف نسخة احتياطية سابقة'),
                trailing: _isImporting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_left),
                onTap: _isImporting ? null : () => _handleRestore(storeId),
              ),

              const Divider(height: 40),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.danger),
                title: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.danger)),
                onTap: _handleLogout,
              ),
            ],
          );
        },
      ),
    );
  }
}