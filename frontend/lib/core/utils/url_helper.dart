import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'url_helper_web.dart' if (dart.library.io) 'url_helper_stub.dart'
    as platform;

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
    platform.openInNewTab(url);
    return;
  }

  // Mobile/Desktop — url_launcher
  final uri = Uri.tryParse(url);
  if (uri == null) {
    _showSnack(context, 'الرابط غير صالح');
    return;
  }
  final canLaunch = await canLaunchUrl(uri);
  if (!canLaunch) {
    if (context != null && context.mounted) {
      _showSnack(context, 'تعذر فتح الرابط');
    }
    return;
  }
  await launchUrl(uri, mode: LaunchMode.externalApplication);
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
