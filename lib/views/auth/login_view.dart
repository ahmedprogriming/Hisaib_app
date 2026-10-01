import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:management_debts_app/routes/app_routes.dart';
import 'package:management_debts_app/services/auth_service.dart';
import 'package:management_debts_app/widgets/custom_showscanr.dart';
import '../../../core/theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'LoginPage';
  const LoginPage({super.key});

  @override
  // تم التصحيح هنا بإضافة 
  State createState() => _LoginPageState(); 
}

// تم التصحيح هنا بإضافة 
class _LoginPageState extends State { 
  final _formKey =GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future _handleLogin() async {
    setState(() => _errorMessage = null);
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _mapAuthError(e.code));
      showSnackbar(
       context,
           _errorMessage!,
        type: SnackBarType.error,
      );
    } catch (e) {
      setState(() => _errorMessage = 'حدث خطأ غير متوقع، تحقق من اتصالك بالإنترنت');
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
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة';
      case 'user-not-found':
      case 'invalid-credential':
        return 'لا يوجد حساب بهذه البيانات';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'too-many-requests':
        return 'محاولات كثيرة، حاول لاحقاً';
      case 'network-request-failed':
        return 'تحقق من اتصالك بالإنترنت';
      default:
        return 'تعذر تسجيل الدخول، حاول مرة أخرى';
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // تم إضافة ودجت لعرض رسالة الخطأ هنا إن وجدت
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textDirection: TextDirection.ltr,
                            decoration: const InputDecoration(
                              labelText: 'البريد الإلكتروني',
                              prefixIcon: Icon(Icons.mail_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'أدخل البريد الإلكتروني';
                              }
                              if (!value.contains('@')) return 'صيغة البريد غير صحيحة';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'أدخل كلمة المرور';
                              if (value.length < 6) return 'كلمة المرور 6 أحرف على الأقل';
                              return null;
                            },
                            onFieldSubmitted: (_) => _handleLogin(),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('تسجيل الدخول', style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'ليس لديك بقالة مسجّلة؟',
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
                                  'أنشئ حساب بقالة جديدة',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
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