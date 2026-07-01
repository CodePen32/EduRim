import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
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

/// Normalizes any stored file path/URL to a working, servable URL.
///
/// All internal media (videos, PDFs, covers) is served through the backend
/// proxy `/api/files/<key>` (the R2 bucket is private, so direct `r2.dev`
/// links return 401). This routes every internal form to that proxy:
///   - `/uploads/videos/x.mp4`            → `<base>/api/files/videos/x.mp4`
///   - `/uploads/<rest>`                  → `<base>/api/files/<rest>`
///   - `/api/files/<rest>`                → `<base>/api/files/<rest>`
///   - `https://pub-*.r2.dev/videos/x`    → `<base>/api/files/videos/x`
///   - `https://*.r2.cloudflarestorage…`  → `<base>/api/files/<key>`
/// External links (YouTube, other hosts) are returned unchanged.
String buildFileUrl(String? path) {
  if (path == null) return '';
  final value = path.trim();
  if (value.isEmpty) return '';

  // Absolute URLs
  if (value.startsWith('http://') || value.startsWith('https://')) {
    final lower = value.toLowerCase();
    // Private R2 hosts → route the object key through the backend proxy.
    if (lower.contains('r2.dev') || lower.contains('r2.cloudflarestorage.com')) {
      final key = _r2Key(value);
      if (key.isNotEmpty) return '$_baseUrl/api/files/$key';
      return value; // could not parse a key — leave as-is
    }
    // Any other absolute URL (YouTube, external CDN, …) — unchanged.
    return value;
  }

  // Relative internal paths → funnel through /api/files.
  if (value.startsWith('/uploads/')) {
    final rest = value.substring('/uploads/'.length);
    return '$_baseUrl/api/files/$rest';
  }
  if (value.startsWith('/api/files/')) {
    return '$_baseUrl$value';
  }
  if (value.startsWith('/')) {
    return '$_baseUrl$value';
  }
  return '$_baseUrl/$value';
}

/// Extracts the object key (path after the host) from an R2 URL.
/// e.g. https://pub-xxx.r2.dev/videos/1780.mp4 → videos/1780.mp4
String _r2Key(String url) {
  final u = Uri.tryParse(url);
  if (u == null) return '';
  var p = u.path;
  if (p.startsWith('/')) p = p.substring(1);
  // If the bucket name is part of the path (cloudflarestorage form), keep the
  // full remaining path — the proxy resolves keys relative to the bucket.
  return p;
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

  // Mobile/Desktop — url_launcher.
  // Note: canLaunchUrl is unreliable on Android 11+ (package visibility), so we
  // attempt to launch directly. Try the external app first (e.g. WhatsApp),
  // then fall back to the in-app/browser handler. Only report failure if all fail.
  final uri = Uri.tryParse(url);
  if (uri == null) {
    _showSnack(context, 'الرابط غير صالح');
    return;
  }
  for (final mode in const [LaunchMode.externalApplication, LaunchMode.platformDefault, LaunchMode.inAppBrowserView]) {
    try {
      final ok = await launchUrl(uri, mode: mode);
      if (ok) return;
    } catch (_) {
      // try next mode
    }
  }
  if (context != null && context.mounted) {
    _showSnack(context, 'تعذر فتح الرابط');
  }
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
