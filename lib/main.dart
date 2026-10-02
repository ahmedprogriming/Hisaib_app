import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:management_debts_app/core/constants/app_constsnt.dart';
import 'package:management_debts_app/core/theme/app_theme.dart';
import 'package:management_debts_app/firebase_options.dart';
import 'package:management_debts_app/providers/customers_provider.dart';
import 'package:management_debts_app/routes/app_routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:management_debts_app/services/auth_service.dart';
import 'package:management_debts_app/services/firebase_sevice.dart';
import 'package:provider/provider.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // مهم جداً: تفعيل العمل بدون إنترنت قبل أي استخدام لـ Firestore
  await FirebaseSevice.enableOfflinePersistence();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
      final authService = AuthService();

    return MultiProvider(
      providers: [
         Provider<AuthService>.value(value: authService),

        // يتتبع تسجيل الدخول/الخروج لحظياً في كل التطبيق
        StreamProvider<User?>(
          create: (_) => authService.authStateChanges,
          initialData: authService.currentUser,
        ),
          ChangeNotifierProxyProvider<User?, CustomersProvider>(
          create: (_) => CustomersProvider(storeId: authService.currentStoreId ?? ''),
          update: (_, user, previous) {
            final storeId = user?.uid ?? '';
            if (previous != null && previous.storeId == storeId) return previous;
            return CustomersProvider(storeId: storeId);
          },
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
       title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          
        ),
    );
    
    
  }
}