import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:management_debts_app/services/firebase_sevice.dart';
import 'package:management_debts_app/providers/customers_provider.dart';
import 'package:management_debts_app/widgets/custom_showscanr.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final storeId = context.watch<CustomersProvider>().storeId;
    final service = FirebaseSevice();
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.watchDebtAlerts(storeId),
        builder: (context, snapshot) {
          if (snapshot.hasError)
          {
 return const Center(child: Text('تعذر تحميل الإشعارات'));
          }
           
          if (!snapshot.hasData)
          {
 return const Center(child: CircularProgressIndicator());
          }
           
          final docs = snapshot.data!.docs
              .where(
                (d) =>
                    !((d.data() as Map<String, dynamic>)['dismissed']
                            as bool? ??
                        false),
              )
              .toList();
          if (docs.isEmpty)
          {
  return const Center(child: Text('لا توجد إشعارات حالياً'));
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['customerName']?.toString() ?? 'عميل';
              final balance = (data['balance'] as num?)?.toDouble() ?? 0;
              final limit = (data['limit'] as num?)?.toDouble() ?? 0;
              final phone = data['customerPhone']?.toString() ?? '';
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'بلغ $name حد الدين',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('الرصيد: ${balance.toStringAsFixed(0)} ريال'),
                      Text('الحد المحدد: ${limit.toStringAsFixed(0)} ريال'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: () async {
                          
                              if (phone.isEmpty) {
                               
                                  showSnackbar(
                                    context,
                                    'لا يوجد رقم هاتف مسجل لهذا العميل',
                                    type: SnackBarType.info,
                                  );
                               
                                return;
                              }
                              final message = Uri.encodeComponent(
                                'مرحباً $name، نود تذكيرك بأن رصيدك المستحق هو ${balance.toStringAsFixed(0)} ريال.',
                              );
                              final uri = Uri.parse(
                                'https://wa.me/${phone.replaceAll(RegExp(r'[^0-9+]'), '')}?text=$message',
                              );
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            icon: const Icon(Icons.chat),
                            label: const Text('إرسال تذكير واتساب'),
                          ),
                          OutlinedButton(
                            onPressed: () =>
                                service.dismissDebtAlert(storeId, doc.id),
                            child: const Text('تجاهل'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
