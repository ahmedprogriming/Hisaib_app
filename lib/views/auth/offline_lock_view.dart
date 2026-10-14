import 'package:flutter/material.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';

/// تظهر لو مرّ على التطبيق وقت أطول من المسموح بدون اتصال بالإنترنت
/// (أو تبيّن أن تاريخ الجهاز أقدم من آخر مزامنة — أي تاريخ خاطئ أو متلاعَب به).
///
/// الهدف من صياغتها: تطمين التاجر أن بياناته محفوظة، وتوضيح أن الإجراء روتيني
/// للتأكد من الاشتراك فقط، وإرشاده لما يفعله بالضبط (وتحذيره من الحذف/الخروج).
class OfflineLockPage extends StatelessWidget {
  final int offlineDays;
  final int maxOfflineDays;
  final bool clockIssue; // التاريخ أقدم من آخر مزامنة
  final bool isChecking;
  final VoidCallback onRetry;

  const OfflineLockPage({
    super.key,
    required this.offlineDays,
    required this.maxOfflineDays,
    required this.onRetry,
    this.clockIssue = false,
    this.isChecking = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppColors.warningBg,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Icon(
                        clockIssue ? Icons.schedule_rounded : Icons.cloud_off_rounded,
                        size: 42,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    clockIssue ? 'تاريخ جهازك غير صحيح' : 'نحتاج اتصالاً بالإنترنت للحفاظ على بياناتك والتأكد من اشتراكك',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    clockIssue
                        ? 'تاريخ ووقت هذا الجهاز أقدم من آخر مرة اتصل فيها التطبيق بالإنترنت. '
                            'صحّح التاريخ والوقت من إعدادات الجهاز (أو فعّل "التاريخ والوقت التلقائي") ثم اتصل بالإنترنت.'
                        : 'مرّت $offlineDays أيام منذ آخر اتصال بالإنترنت، والحد المسموح للعمل بدون اتصال هو '
                            '$maxOfflineDays أيام. هذا إجراء روتيني للتأكد من حالة اشتراكك فقط.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.7, fontSize: 14),
                  ),
                  const SizedBox(height: 22),

                  // بطاقة التطمين
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified_user_rounded, color: AppColors.success),
                            SizedBox(width: 8),
                            Text(
                              'بياناتك في أمان',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        _Point('كل عملائك وديونك وعملياتك محفوظة بالكامل على هذا الجهاز ولن تُحذف.'),
                        _Point('أي عمليات سجّلتها بدون إنترنت ستُرفع تلقائياً فور الاتصال.'),
                        _Point('لا تحذف التطبيق ولا تسجّل الخروج قبل الاتصال، حتى لا تفقد عمليات لم تُرفع بعد.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // الخطوات
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ماذا تفعل الآن؟',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 10),
                        _Step('1', 'شغّل بيانات الجوال أو الواي فاي.'),
                        _Step('2', 'اضغط زر "تحقق من الاتصال الآن" أدناه.'),
                        _Step('3', 'يعود التطبيق للعمل تلقائياً خلال ثوانٍ.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  ElevatedButton.icon(
                    onPressed: isChecking ? null : onRetry,
                    icon: isChecking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.wifi_rounded),
                    label: Text(isChecking ? 'جارٍ التحقق...' : 'تحقق من الاتصال الآن'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  final String text;
  const _Point(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Icons.check_rounded, size: 16, color: AppColors.success),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String text;
  const _Step(this.number, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(number,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}
