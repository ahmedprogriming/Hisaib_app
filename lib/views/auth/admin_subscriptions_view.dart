import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_debts_app/core/constants/app_constsnt.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/widgets/custom_showscanr.dart';

class AdminSubscriptionsPage extends StatefulWidget {
  const AdminSubscriptionsPage({super.key});

  @override
  State<AdminSubscriptionsPage> createState() => _AdminSubscriptionsPageState();
}

class _AdminSubscriptionsPageState extends State<AdminSubscriptionsPage> {

final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose( ) {
   _searchController.dispose();
    super.dispose();
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إدارة المتاجر والاشتراكات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. شريط البحث
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'ابحث باسم المتجر أو رقم الهاتف...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(AppConstants.storesCollection)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                 return const Center(child: Text('تعذر الاتصال بقاعدة البيانات'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
            
                // فلترة المتاجر بناءً على نص البحث (الاسم أو رقم الهاتف)
                final stores = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name']?.toString().toLowerCase() ?? '';
                  final phone = data['phone']?.toString().toLowerCase() ?? '';
                  return name.contains(_searchQuery) || phone.contains(_searchQuery);
                }).toList();
            
                if (stores.isEmpty) {
                return Center(
                    child: Text(
                      _searchQuery.isEmpty ? 'لا توجد أي متاجر مسجلة في النظام بعد' : 'لا توجد نتائج مطابقة للبحث',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
            
                return ListView.builder(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    final store = stores[index];
                    final data = store.data() as Map<String, dynamic>;
                    final storeName = data['name'] ?? 'متجر بدون اسم';
                    final storePhone = data['phone'] ?? 'لا يوجد رقم';
                    final isActive = data['isActive'] as bool? ?? true;
            
                    // جلب تاريخ انتهاء الاشتراك إن وجد
                    final Timestamp? endsAtTimestamp = data['subscriptionEndsAt'];
                    final DateTime? endsAt = endsAtTimestamp?.toDate();
                    final isExpired =
                        endsAt != null && endsAt.isBefore(DateTime.now());
            // تحديد حالة المتجر لونياً
                    Color statusColor;
                    String statusText;
                    if (!isActive) {
                      statusColor = AppColors.danger;
                      statusText = 'الحساب موقوف';
                    } else if (isExpired) {
                      statusColor = Colors.orange;
                      statusText = 'الاشتراك منتهي';
                    } else {
                      statusColor = AppColors.success;
                      statusText = 'نشط وفعال';
                    }
            
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(right: BorderSide(color: statusColor, width: 5)), // الشريط الجانبي الملون
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // رأس البطاقة: الاسم وزر التفعيل
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            storeName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                            child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Switch(
                                          value: isActive,
                                        
                                          onChanged: (bool value) {
                                            FirebaseFirestore.instance.collection(AppConstants.storesCollection).doc(store.id).update({'isActive': value});
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                                          tooltip: 'حذف المتجر',
                                          onPressed: () => _confirmDeleteStore(context, store.id, storeName),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                
                                // تفاصيل المتجر
                                Row(
                                  children: [
                                    const Icon(Icons.phone_android_rounded, size: 16, color: AppColors.textSecondary),
                                    const SizedBox(width: 8),
                                    Text(storePhone, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.event_busy_rounded, size: 16, color: isExpired ? Colors.orange : AppColors.textSecondary),
                                    const SizedBox(width: 8),
                                    Text(
                                      endsAt != null ? 'تاريخ الانتهاء: ${DateFormat('yyyy/MM/dd', 'ar').format(endsAt)}' : 'تاريخ الانتهاء: غير محدد (مجاني)',
                                      style: TextStyle(color: isExpired ? Colors.orange[800] : AppColors.textSecondary, fontSize: 14, fontWeight: isExpired ? FontWeight.bold : FontWeight.normal),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // أزرار التجديد
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () => _extendSubscription(context, store.id, 30),
                                          style: TextButton.styleFrom(foregroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(vertical: 12)),
                                          child: const Text('شـهر (30)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        ),
                                      ),
                                      Container(width: 1, height: 20, color: Colors.grey.withOpacity(0.3)), // خط فاصل
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () => _extendSubscription(context, store.id, 183),
                                          style: TextButton.styleFrom(foregroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(vertical: 12)),
                                          child: const Text('6 أشهـر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        ),
                                      ),
                                      Container(width: 1, height: 20, color: Colors.grey.withOpacity(0.3)),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () => _extendSubscription(context, store.id, 365),
                                          style: TextButton.styleFrom(foregroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(vertical: 12)),
                                          child: const Text('سنـة كاملة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // دالة تأكيد الحذف
  Future<void> _confirmDeleteStore(BuildContext context, String storeId, String storeName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.danger),
            SizedBox(width: 8),
            Text('حذف المتجر نهائياً'),
          ],
        ),
        content: Text('هل أنت متأكد من حذف المتجر "$storeName"؟\nسيتم مسح وثيقة المتجر من قاعدة البيانات.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم، احذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await FirebaseFirestore.instance.collection(AppConstants.storesCollection).doc(storeId).delete();
        if (mounted) {
          showSnackbar(context, 'تم حذف المتجر بنجاح', type: SnackBarType.success);
        }
      } catch (e) {
        if (mounted) {
          showSnackbar(context, 'حدث خطأ أثناء الحذف', type: SnackBarType.error);
        }
      }
    }
  }

  // دالة لتمديد الاشتراك
  Future<void> _extendSubscription(
    BuildContext context,
    String storeId,
    int days,
  ) async {
    final newEndDate = DateTime.now().add(Duration(days: days));

    await FirebaseFirestore.instance.collection('stores').doc(storeId).set({
      'subscriptionEndsAt': Timestamp.fromDate(newEndDate),
      'isActive': true, // تفعيل المتجر تلقائياً عند التجديد
    }, SetOptions(merge: true));

    if (context.mounted) {
      showSnackbar(
        context,
        'تم تجديد الاشتراك بنجاح لمدة $days يوم',
        type: SnackBarType.success,
      );
    }
  }
}
