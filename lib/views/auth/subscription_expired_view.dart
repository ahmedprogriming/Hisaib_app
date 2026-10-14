import 'package:flutter/material.dart';
import 'package:management_debts_app/core/constants/app_constsnt.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/routes/app_routes.dart';
import 'package:management_debts_app/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class SubscriptionExpiredPage extends StatelessWidget {
    final DateTime? subscriptionEndsAt;
  final bool isDeactivated;
final String? storeName;
  final String? storePhone;
  const SubscriptionExpiredPage({super.key,  this.isDeactivated=false, this.subscriptionEndsAt, this.storeName, this.storePhone});



  Future<void> _openWhatsapp() async {
  
    final name = storeName ?? 'النتجر غير معروف';
    final phoneNum = storePhone ?? 'رقم الهاتف غير متوفر';

final statusText = isDeactivated 
        ? 'تم تعطيل الحساب' 
        : 'انتهت فترة الاشتراك';
    final dateText = (subscriptionEndsAt != null && !isDeactivated)
        ? ' (تاريخ الانتهاء: ${DateFormat('yyyy/MM/dd').format(subscriptionEndsAt!)})'
        : '';

    final message = '''
السلام عليكم، أود تجديد الاشتراك / تفعيل الحساب في تطبيق إدارة الديون.
- المتجر: ${name.isNotEmpty ? name : 'غير محدد'}
- رقم المتجر: ${phoneNum.isNotEmpty ? phoneNum : 'غير محدد'}
- الحالة: $statusText$dateText
'''.trim();
    final phone = AppConstants.supportWhatsappNumber.replaceAll('+', '');
    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService().signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.splash, (r) => false);
  }
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Center(
        child: Padding(padding:const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
               alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    isDeactivated ? Icons.block_outlined : Icons.hourglass_bottom_outlined,
                    color: AppColors.danger,
                    size: 38,),
            ),
            const SizedBox(height: 24),
                Text(
                  isDeactivated ? 'تم تعطيل حسابك مؤقتاً' : 'انتهت فترة اشتراكك',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (subscriptionEndsAt != null && !isDeactivated)
                  Text(
                    'انتهى في ${DateFormat('d MMMM yyyy', 'ar').format(subscriptionEndsAt!)}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                const SizedBox(height: 12),
                const Text(
            'لاستئناف استخدام التطبيق وفتح البيانات، يُرجى التواصل مع فريق الدعم لتجديد أو تفعيل الاشتراك.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _openWhatsapp,
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('تواصل معنا عبر واتساب'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => _handleLogout(context),
                  child: const Text('تسجيل الخروج'),
                ),
          ],
        ),
        ),
      )),
    );
  }
}