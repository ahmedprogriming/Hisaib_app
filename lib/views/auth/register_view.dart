import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:management_debts_app/core/constants/app_constsnt.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/routes/app_routes.dart';
import 'package:management_debts_app/services/auth_service.dart';
import 'package:management_debts_app/widgets/custom_buttton.dart';
import 'package:management_debts_app/widgets/custom_showscanr.dart';
import 'package:management_debts_app/widgets/text_fileid.dart';

class RagisterPage extends StatefulWidget {
  const RagisterPage({super.key});

  static String id = 'RagesterPage';

  @override
  State<RagisterPage> createState() => _RagisterPageState();
}

class _RagisterPageState extends State<RagisterPage> {
  static const int _trialDays = 14;
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _currency = 'ريال يمني';
  bool _isLoading = false;
  String? _errorMessage;
 bool _obscurePassword = true;
  final _authService = AuthService();

  @override
  void dispose() {
    _storeNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _errorMessage = null);
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1) إنشاء حساب المصادقة
      final credential = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final storeId = credential.user!.uid;
      final now = DateTime.now();

      // 2) إنشاء مستند البقالة بنفس uid (هذا ما يجعل الفصل بين البقالات ممكناً)
      await FirebaseFirestore.instance
          .collection(AppConstants.storesCollection)
          .doc(storeId)
          .set({
            'name': _storeNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'currency': _currency,
            'createdAt': now,
            'subscriptionStartedAt': now,
            'subscriptionEndsAt': now.add(
              const Duration(days: /*_trialDays*/ 2),
            ),
            'isActive': true,
          });

      if (!mounted) return;

      // 3) عرض تنبيه بسيط بالفترة التجريبية قبل الانتقال
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('تم إنشاء حسابك'),
          content: Text(
            'بقالتك جاهزة! لديك اشتراك تجريبي مجاني لمدة $_trialDays يوماً.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _mapAuthError(e.code));
     showSnackbar(
       context,
           _errorMessage!,
        type: SnackBarType.error,
      );
      
    } catch (_) {
      setState(
        () => _errorMessage = 'تعذر إنشاء الحساب، تحقق من اتصالك بالإنترنت',
      );
      showSnackbar(
        context,
        _errorMessage!,
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'هذا البريد مستخدم من قبل، جرّب تسجيل الدخول';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'network-request-failed':
        return 'تحقق من اتصالك بالإنترنت';
      default:
        return 'تعذر إنشاء الحساب، حاول مرة أخرى';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // أيقونة / شعار
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.25),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'lib/asset/images/hisabi App.png',
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "بقالة جديدة",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff211A16),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // تصميم احترافي على شكل (Badge) متناسق مع ألوان التطبيق
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successBg, // خلفية خضراء باهتة
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // حواف دائرية بالكامل
                          border: BoxBorder.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize
                              .min, // هام جداً: يجعل الصف يأخذ مساحة محتواه فقط ليتم توسيطه
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.card_giftcard_outlined,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'تجربة مجانية $_trialDays يوماً بدون أي التزام',
                              style: const TextStyle(
                                color:
                                    AppColors.success, // نص بلون النجاح الداكن
                                fontSize: 13,
                                fontWeight: FontWeight
                                    .bold, // زيادة سمك الخط لإبراز العرض المجاني
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "أدخل بياناتك للانضمام لنظام إدارة الديون",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // بطاقة الإدخال البيضاء
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _storeNameController,
                              decoration: const InputDecoration(
                                labelText: 'اسم البقالة *',
                                prefixIcon: Icon(Icons.storefront_outlined),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'أدخل اسم البقالة'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textDirection: TextDirection.ltr,
                              decoration: const InputDecoration(
                                labelText: 'رقم الهاتف *',
                                hintText: '+967 780 775 168',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().length < 8)
                                  ? 'أدخل رقم هاتف صحيح'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              initialValue: _currency,
                              decoration: const InputDecoration(
                                labelText: 'العملة',
                                prefixIcon: Icon(Icons.payments_outlined),
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
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textDirection: TextDirection.ltr,
                              decoration: const InputDecoration(
                                labelText: 'البريد الإلكتروني *',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'أدخل البريد الإلكتروني';
                                if (!v.contains('@'))
                                  return 'صيغة البريد غير صحيحة';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration:  InputDecoration(
                                labelText: 'كلمة المرور *',
                                prefixIcon: Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'أدخل كلمة المرور';
                                if (v.length < 6)
                                  return 'كلمة المرور 6 أحرف على الأقل';
                                return null;
                              },
                              onFieldSubmitted: (_) => _handleRegister(),
                            ),

                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('إنشاء الحساب'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // رابط الانتقال لتسجيل الدخول
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'لديك حساب بالفعل؟',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            ),
                            child: Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
