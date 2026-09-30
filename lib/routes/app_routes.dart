import 'package:flutter/material.dart';
import 'package:management_debts_app/views/addTransaction/addTransaction_view.dart';
import 'package:management_debts_app/views/auth/login_view.dart';
import 'package:management_debts_app/views/auth/register_view.dart';
import 'package:management_debts_app/views/customers/customer_Details_view.dart';
import 'package:management_debts_app/views/customers/customers_view.dart';
import 'package:management_debts_app/views/home/home_view.dart';
import 'package:management_debts_app/views/reports/reports_view.dart';
import 'package:management_debts_app/views/settings/setting_page.dart';

class AppRoutes {
    AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String home='/home';
  static const String addTransaction='/addTransaction';
  static const String customerDetails='/customerDetaild';
  static const String customers='/customer';
 static const String reports='/reports';
  static const String settings='/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings setting)
  {
    switch(setting.name)
    {
   case login:
   return MaterialPageRoute(builder: (_)=> const LoginPage());
   case register:
   return MaterialPageRoute(builder: (_)=> const RagisterPage());
   case home:
   return MaterialPageRoute(builder: (_)=> const HomePage());
    case addTransaction:
   return MaterialPageRoute(builder: (_)=> const AddtransactionPage());
    case customerDetails:
   return MaterialPageRoute(builder: (_)=> const CustomerDetailsPage(customerId: '1'));
   case customers:
   return MaterialPageRoute(builder: (_)=> const CustomersPage());
    case reports:
    return MaterialPageRoute(builder: (_)=> const CustomersPage());
    case settings:
   return MaterialPageRoute(builder: (_)=> const SettingPage());
    default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('الصفحة غير موجودة')),
          ),
        );
    }
  }
}
