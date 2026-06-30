import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/network/api_client.dart';
import 'core/services/auth_service.dart';
import 'core/services/offline_download_service.dart';
import 'core/services/push_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.logBaseUrl();
  if (!kIsWeb) {
    await Hive.initFlutter();
    await offlineDownloadService.init();
  }
  // تحميل token المحفوظ في apiClient قبل أي طلب
  await authService.loadSavedToken();

  // تشغيل الواجهة دائماً أولاً — لا شيء من Firebase/FCM يجب أن يمنع الإقلاع
  runApp(const EdurImApp());

  // تهيئة الإشعارات بعد runApp بشكل non-blocking وbest-effort.
  // أي فشل في Firebase/FCM يُتجاهَل ولا يكسر التطبيق.
  if (!kIsWeb) {
    () async {
      try {
        await pushService.init();
        if (apiClient.currentToken != null) {
          await pushService.registerToken();
        }
      } catch (_) {
        // تجاهل: التطبيق يعمل بدون إشعارات
      }
    }();
  }
}
