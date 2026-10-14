import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:management_debts_app/core/constants/app_constsnt.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/routes/app_routes.dart';
import 'package:management_debts_app/services/auth_service.dart';
import 'package:management_debts_app/services/firebase_sevice.dart';
import 'package:management_debts_app/views/auth/login_view.dart';
import 'package:management_debts_app/views/auth/offline_lock_view.dart';
import 'package:management_debts_app/views/auth/subscription_expired_view.dart';
import 'package:management_debts_app/views/main_shell.dart';
import 'package:management_debts_app/widgets/custom_showscanr.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    if (user == null) return const LoginPage();

    // key بالـ uid: لو تبدّل المستخدم تُبنى البوابة من جديد بدل إعادة استخدام حالة السابق
    return _SubscriptionGate(key: ValueKey(user.uid), user: user);
  }
}

class   _SubscriptionGate extends StatefulWidget {
  final User user;
  const _SubscriptionGate({super.key, required this.user});

  @override
  State<_SubscriptionGate> createState() => _SubscriptionGateState();
}

class _SubscriptionGateState extends State<_SubscriptionGate> {

  final _service = FirebaseSevice();
  StreamSubscription<DocumentSnapshot>? _sub;
  Timer? _graceTimer;

  DocumentSnapshot? _snap;
  bool _hasError = false;
  bool _checking = false;

  // مهلة قصيرة: أول snapshot غالباً يأتي من الكاش حتى لو الجهاز متصل، فلا نقفل
  // التطبيق فوراً — ننتظر ثوانٍ ليصل رد السيرفر، لو لم يصل نعتبره بدون اتصال فعلاً.
  bool _graceElapsed = false;

  @override
  void initState() {
    super.initState();
    _graceTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _graceElapsed = true);
    });
    _listen();
  }
 void _listen() {
    _sub?.cancel();
    _sub = _service.watchStore(widget.user.uid).listen(
      _onSnapshot,
      onError: (_) {
        if (mounted) setState(() => _hasError = true);
      },
    );
  }

   void _onSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>?;

    // نسجّل "آخر مزامنة" فقط حين تأتي البيانات من السيرفر فعلاً (مو من الكاش)
    // ولا يوجد تعديلات معلّقة، وكانت القيمة السابقة أقدم من ساعة (حتى لا نكتب كل مرة).
    if (data != null && !snap.metadata.isFromCache && !snap.metadata.hasPendingWrites) {
      final last = _asDate(data['lastSyncAt']);
      if (last == null || DateTime.now().difference(last) > const Duration(hours: 1)) {
        _service.markSynced(widget.user.uid).catchError((_) {}); // بدون await — آمن أوفلاين
      }
    }

    if (mounted) {
      setState(() {
        _snap = snap;
        _hasError = false;
      });
    }
  }
  /// زر "تحقق من الاتصال الآن": قراءة إجبارية من السيرفر؛ نجاحها يجعل الاستماع
  /// يستلم بيانات السيرفر ويُجدَّد lastSyncAt تلقائياً فتختفي شاشة القفل.
  Future<void> _checkNow() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      await _service.fetchStoreFromServer(widget.user.uid).timeout(const Duration(seconds: 10));
      if (mounted)
      {
showSnackbar(context, 'تم الاتصال بنجاح', type: SnackBarType.success);
   Navigator.pushNamed(context,AppRoutes.home);
      } 
    } catch (_) {
      if (mounted) {
        showSnackbar(context, 'ما زال لا يوجد اتصال بالإنترنت — حاول مرة أخرى', type: SnackBarType.info);
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

   @override
  void dispose() {
    _sub?.cancel();
    _graceTimer?.cancel();
    super.dispose();
  }

  static DateTime? _asDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }


  @override
  Widget build(BuildContext context) {
     // المشرف لا يُقفل أبداً (حتى لا يفقد الوصول للوحة التي يجدّد منها الاشتراكات)
    if (AuthService().isAdmin) return const MainShell();

    final snap = _snap;

     if (snap == null) {
      if (_hasError) {
        return _StatusScreen(
          icon: Icons.error_outline_rounded,
          title: 'تعذّر التحقق من حسابك',
          message: 'حدثت مشكلة أثناء قراءة بيانات حسابك. تأكد من اتصالك بالإنترنت ثم حاول مرة أخرى.',
          buttonLabel: 'إعادة المحاولة',
          onPressed: () {
            setState(() => _hasError = false);
            _listen();
          },
        );
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

     final meta = snap.metadata;
    final data = snap.data() as Map<String, dynamic>?;

    // ── حساب بلا مستند بقالة ──
    if (!snap.exists || data == null) {
      if (meta.isFromCache) {
        // من الكاش + غير موجود = غالباً لم يُحمَّل بعد (أول دخول على هذا الجهاز بدون إنترنت)،
        // وليس بالضرورة محذوفاً.
        return _StatusScreen(
          icon: Icons.cloud_off_rounded,
          title: 'نحتاج اتصالاً بالإنترنت',
          message: 'لتحميل بيانات حسابك على هذا الجهاز لأول مرة، اتصل بالإنترنت ثم أعد المحاولة.',
          buttonLabel: _checking ? 'جارٍ التحقق...' : 'تحقق من الاتصال الآن',
          onPressed: _checking ? null : _checkNow,
        );
      }
      // السيرفر أكّد أنه غير موجود: تسجيل لم يكتمل أو حُذف المتجر.
      // (كان الكود القديم يفتح التطبيق هنا — وهذا يتجاوز الاشتراك بالكامل)
      return _StatusScreen(
        icon: Icons.person_off_outlined,
        title: 'حسابك غير مكتمل أو تم حذفه',
        message: 'لا توجد بيانات بقالة مرتبطة بهذا الحساب. تواصل مع الدعم عبر واتساب: ${AppConstants.supportWhatsappNumber}',
        buttonLabel: 'تسجيل الخروج',
        onPressed: () => AuthService().signOut(),
      );
    }

     final isActive = data['isActive'] != false; // غير موجود = فعّال (مثل السلوك القديم)
    final endsAt = _asDate(data['subscriptionEndsAt']);
    final storeName = (data['name'] ?? '').toString();
    final storePhone = (data['phone'] ?? '').toString();
    final now = DateTime.now();

    if (!isActive) {
      return SubscriptionExpiredPage(
        isDeactivated: true,
        subscriptionEndsAt: endsAt,
        storeName: storeName,
        storePhone: storePhone,
      );
    }

    if (endsAt != null && now.isAfter(endsAt)) {
      return SubscriptionExpiredPage(
        subscriptionEndsAt: endsAt,
        storeName: storeName,
        storePhone: storePhone,
      );
    }

    // ── قفل المدة الطويلة بدون اتصال ──
    // lastSyncAt وقت السيرفر (موثوق)، و now وقت الجهاز. يعمل فقط حين تأتي البيانات من الكاش.
    final lastSync = _asDate(data['lastSyncAt']);
    if (meta.isFromCache && lastSync != null) {
      final offlineDays = now.difference(lastSync).inDays;
      final tooLongOffline = offlineDays > AppConstants.maxOfflineDays;
      // تاريخ الجهاز أقدم من آخر مزامنة بأكثر من يوم = أُرجع التاريخ للخلف (خطأ أو تلاعب)
      final clockBehind = now.isBefore(lastSync.subtract(const Duration(hours: 24)));

      if (tooLongOffline || clockBehind) {
        if (!_graceElapsed) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return OfflineLockPage(
          offlineDays: offlineDays < 0 ? 0 : offlineDays,
          maxOfflineDays: AppConstants.maxOfflineDays,
          clockIssue: clockBehind,
          isChecking: _checking,
          onRetry: _checkNow,
        );
      }
    }

    return const MainShell();

  }
}



/// شاشة رسالة بسيطة (بدون قفل اشتراك) لحالات: خطأ تحميل / حساب غير موجود / لم يُحمَّل بعد
class _StatusScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback? onPressed;

  const _StatusScreen({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 56, color: AppColors.warning),
                const SizedBox(height: 18),
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Text(message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.7)),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: onPressed, child: Text(buttonLabel)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
