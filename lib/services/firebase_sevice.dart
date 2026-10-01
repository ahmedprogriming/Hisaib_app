import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:management_debts_app/core/constants/app_constsnt.dart';

/// طبقة الوصول لـ Firestore — كل الاستعلامات هنا "مقيّدة" بـ storeId
/// حتى نضمن عزل بيانات كل بقالة عن الثانية (Multi-tenant isolation).
class FirebaseSevice {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// يجب استدعاؤها مرة وحدة عند بداية التطبيق (main.dart)
  static Future<void> enableOfflinePersistence() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  DocumentReference storeDoc(String storeId) =>
      _db.collection(AppConstants.storesCollection).doc(storeId);

  Stream<DocumentSnapshot> watchStore(String storeId) =>
      storeDoc(storeId).snapshots();
}
