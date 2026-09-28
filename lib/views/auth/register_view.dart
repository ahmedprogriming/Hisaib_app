import 'package:flutter/material.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/routes/app_routes.dart';
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

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final _storeNameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _currency = 'ريال يمني';

  bool isLoading = false;

  @override
  void dispose() {
    _storeNameController.dispose();
    emailController.dispose();
    _passwordCtrl.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /*
  Future<void> _handleRegister() async {
    if (!formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      showSnackbar(context, 'كلمتا المرور غير متطابقتين', type: SnackBarType.error);
      return;
    }

    setState(() => isLoading = true);

    try {
      await regesterUser(
        emailController.text.trim(),
        passwordController.text.trim(),
        nameController.text.trim(),
      );
      if (!mounted) return;
      BlocProvider.of<PatientsCubit>(context).getpatients();
      Navigator.pushReplacementNamed(
        context,
        DashboardPage.id,
        arguments: emailController.text.trim(),
      );
      // حفظ حالة "is_first_time" في SharedPreferences
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('is_first_time', false);
    } on FirebaseAuthException catch (ex) {
      if (ex.code == 'weak-password') {
        showSnackbar(context, 'كلمة المرور ضعيفة، يرجى اختيار كلمة مرور أقوى.', type: SnackBarType.error);
      } else if (ex.code == 'email-already-in-use') {
        showSnackbar(
          context,
          'هذا البريد الإلكتروني مسجل بالفعل، يرجى استخدام بريد آخر.',
          type: SnackBarType.error,
        );
      } else if (ex.code == 'invalid-email') {
        showSnackbar(context, 'البريد الإلكتروني غير صحيح، يرجى التأكد منه.', type: SnackBarType.error);
      } else {
        showSnackbar(context, ex.message ?? 'تعذر إكمال التسجيل', type: SnackBarType.error);
      }
    } catch (_) {
      showSnackbar(context, 'حدث خطأ، يرجى المحاولة مرة أخرى.', type: SnackBarType.error);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
  */

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
                  key: formKey,
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
                            CustomTextFiled(
                              hint: 'اسم البقالة',
                              controller: _storeNameController,
                              prefixIcon: Icons.storefront_outlined,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'أدخل اسم البقالة'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            CustomTextFiled(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textDirection: TextDirection.ltr,
                              prefixIcon: Icons.phone_android_outlined,
                              hint: 'رقم هاتف',
                              validator: (v) =>
                                  (v == null || v.trim().length < 8)
                                  ? 'أدخل رقم هاتف صحيح'
                                  : null,
                            ),

                            const SizedBox(height: 14),
                            CustomTextFiled(
                              hint: 'البريد الإلكتروني',
                              controller: emailController,
                                 textDirection: TextDirection.ltr,
                              prefixIcon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 14),
                            CustomTextFiled(
                              controller: _passwordCtrl,
                              hint: 'كلمة المرور',
                                 textDirection: TextDirection.ltr,
                              prefixIcon: Icons.lock_outline,
                              obsecureText: true,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'كلمة المرور مطلوبة'
                                  : null,
                            ),

                            const SizedBox(height: 24),

                            CustomButton(
                              namebutton: isLoading
                                  ? '...جاري إنشاء الحساب'
                                  : 'تسجيل الحساب',

                              onTap: isLoading
                                  ? null
                                  : () {
                                      Center(child: Text('Successfullu'));
                                    },
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
