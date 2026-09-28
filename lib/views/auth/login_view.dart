import 'package:flutter/material.dart';
import 'package:management_debts_app/routes/app_routes.dart';
import 'package:management_debts_app/widgets/custom_buttton.dart';
import 'package:management_debts_app/widgets/text_fileid.dart';
import '../../../core/theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'LoginPage';
  const LoginPage({super.key});

  @override
  State createState() => _LoginPageState();
}

class _LoginPageState extends State {
  final _formKey = GlobalKey();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /*
  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read().login(
            _emailCtrl.text.trim(),
            _passwordCtrl.text.trim(),
          );
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. الشعار
                  Container(
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
                  const SizedBox(height: 24),

                  // 2. النصوص الترحيبية
                  const Text(
                    'حسابي',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ابدأ في إدارة ديون عملائك',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 3. القالب الاحترافي (البطاقة البيضاء)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface, // لون البطاقة الأبيض
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textSecondary.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextFiled(
                            controller: _emailCtrl,
                            hint: 'البريد الإلكتروني',
                            textDirection: TextDirection.ltr,
                            prefixIcon: Icons.email_outlined,

                            keyboardType: TextInputType.emailAddress,
                            validator: (val) => val == null || val.isEmpty
                                ? 'البريد الإلكتروني مطلوب'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          CustomTextFiled(
                            controller: _passwordCtrl,
                            hint: 'كلمة المرور',
                            prefixIcon: Icons.lock_outline,
                            textDirection: TextDirection.ltr,
                            obsecureText: true,
                            validator: (val) => val == null || val.isEmpty
                                ? 'كلمة المرور مطلوبة'
                                : null,
                          ),
                          const SizedBox(height: 32),

                          CustomButton(
                            namebutton: 'تسجيل الدخول',
                            //isLoading: isLoading,
                            onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.home,
                                ),
                          ),
                          const SizedBox(height: 24),

                          // الانتقال لإنشاء حساب
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'ليس لديك حساب؟',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.register,
                                ),
                                child: const Text(
                                  'إنشاء حساب جديد',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
