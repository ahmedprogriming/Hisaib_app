import 'package:flutter/material.dart';
import 'package:management_debts_app/widgets/custom_buttton.dart';
import 'package:management_debts_app/widgets/text_fileid.dart';
import '../../../core/theme/app_colors.dart';


class LoginPage extends StatefulWidget {
  static const String id = 'LoginPage';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
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
      context.read<LoginPageCubit>().login(
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
      body: 
           SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // عرض الشعار المتناسق مع الحاوية
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'lib/asset/images/hisabi App.png',
                          width: 72,
                          height: 72,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'حسابي',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ابدا في ادارة ديون عملائك',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 36),

                      CustomTextFiled(
                        controller: _emailCtrl,
                        hint: 'البريد الاكتروني',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val == null || val.isEmpty ? 'البريد الاكتروني مطلوب' : null,
                      ),
                      const SizedBox(height: 16),

                      CustomTextFiled(
                        controller: _passwordCtrl,
                        hint: 'كلمة المرور',
                        prefixIcon: Icons.lock_outline,
                        obsecureText: true,
                        validator: (val) => val == null || val.isEmpty ? 'كلمة المرور مطلوبة' : null,
                      ),
                      const SizedBox(height: 28),

                      CustomButton(
                        namebutton: 'تسجيل الدخول',
                        //isLoading: isLoading,
                        onTap: (){},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        
    
    );
  }
}