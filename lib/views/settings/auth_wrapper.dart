import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:management_debts_app/services/firebase_sevice.dart';
import 'package:management_debts_app/views/auth/login_view.dart';
import 'package:management_debts_app/views/auth/subscription_expired_view.dart';
import 'package:management_debts_app/views/home/home_view.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {

    final user=context.watch<User?>();

    if(user == null) return const LoginPage();
    
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseSevice().watchStore(user.uid),
       builder: (context,snapshot)
       {
        if(snapshot.connectionState==ConnectionState.waiting && !snapshot.hasData)
        {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final data=snapshot.data?.data() as Map<String,dynamic>?;

        if(data == null) return const HomePage();

         final isActive = data['isActive'] ?? true;
        final subscriptionEndsAt = (data['subscriptionEndsAt'] as Timestamp?)?.toDate();
        final isExpired = subscriptionEndsAt != null && subscriptionEndsAt.isBefore(DateTime.now());

        if (!isActive) {
          return SubscriptionExpiredPage(
            subscriptionEndsAt: subscriptionEndsAt,
            isDeactivated: true,
          );
        }

        if (isExpired) {
          return SubscriptionExpiredPage(subscriptionEndsAt: subscriptionEndsAt);
        }

        return const HomePage();
       }
       );
  }
}