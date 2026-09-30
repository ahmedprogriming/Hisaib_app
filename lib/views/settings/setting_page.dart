import 'package:flutter/material.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';

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

  //final _firebaseService = FirebaseService();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSave(String storeId)
  {
    
  }

  void _handleBackup(String storeId)
  {

  }

  void _handleRestore(String storeId)
  {

  }
  
  void _handleLogout()
  {
    
  }
  @override
  Widget build(BuildContext context) {
     final storeId = 'context.watch<CustomersProvider>().storeId;';
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات'),),
      body: ListView(
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
          ),
    );
  }
}