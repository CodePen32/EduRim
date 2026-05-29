import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

// Dev:  flutter run  (no --dart-define needed → defaults to localhost)
// Prod: flutter build web --dart-define=FILES_BASE_URL=https://files.edurim.com
const String _baseUrl = String.fromEnvironment(
  'FILES_BASE_URL',
  defaultValue: 'http://localhost:8081',
);

String buildFileUrl(String? path) {
  if (path == null) return '';
  final value = path.trim();
  if (value.isEmpty) return '';
  if (value.startsWith('http://') || value.startsWith('https://')) return value;
  if (value.startsWith('/')) return '$_baseUrl$value';
  return '$_baseUrl/$value';
}

Future<void> openExternalUrl(String? rawUrl, {BuildContext? context}) async {
  final url = buildFileUrl(rawUrl);

  if (url.isEmpty) {
    _showSnack(context, 'الرابط غير متاح حالياً');
    return;
  }

  debugPrint('openExternalUrl: $url');

  if (kIsWeb) {
    web.window.open(url, '_blank');
    return;
  }

  // Mobile/Desktop — placeholder (url_launcher can be wired here)
  _showSnack(context, 'تعذر فتح الرابط');
}

void _showSnack(BuildContext? context, String msg) {
  if (context == null || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}
