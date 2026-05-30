import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import '../models/subscription.dart';
import '../network/api_client.dart';
import 'file_picker_web.dart' if (dart.library.io) 'file_picker_mobile.dart'
    as picker;

class SubscriptionService {
  Future<MySubscription> getMySubscription() async {
    try {
      final data = await apiClient.get('/me/subscription');
      final raw = data['data'];
      if (raw == null) return MySubscription.noSubscription();
      return MySubscription.fromJson(raw as Map<String, dynamic>);
    } catch (_) {
      return MySubscription.noSubscription();
    }
  }

  Future<List<SubscriptionRequest>> getMyRequests() async {
    try {
      final data = await apiClient.get('/me/subscription-requests');
      final raw = data['data'];
      final list = raw is List ? raw : <dynamic>[];
      return list
          .map((e) => SubscriptionRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> createRequest({
    required int planId,
    required String phone,
    required String paymentMethod,
    String receiptImageUrl = '',
    String note = '',
  }) async {
    await apiClient.post('/me/subscription-requests', {
      'plan_id': planId,
      'phone': phone,
      'payment_method': paymentMethod,
      'receipt_image_url': receiptImageUrl,
      'note': note,
    });
  }

  Future<List<SubscriptionPlanSimple>> getAvailablePlans() async {
    try {
      final data = await apiClient.get('/me/subscription-plans');
      final raw = data['data'];
      final list = raw is List ? raw : <dynamic>[];
      return list
          .map((e) => SubscriptionPlanSimple.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// يفتح file picker ويرفع الصورة للخادم — يُعيد URL المحفوظة
  Future<String> uploadReceiptImage() async {
    final picked = await picker.pickFileBytes();
    if (picked == null) throw Exception('لم يتم اختيار ملف');

    final bytes    = picked.$1;
    final filename = picked.$2;
    final mime     = picked.$3;

    final token = apiClient.currentToken ?? '';
    final uri = Uri.parse('${ApiClient.baseUrl}/me/uploads?type=images');

    debugPrint('[upload] url=$uri field=file filename=$filename mime=$mime size=${bytes.length} hasToken=${token.isNotEmpty}');

    final request = http.MultipartRequest('POST', uri);
    if (token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Send explicit contentType so backend sees the correct MIME
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
      contentType: _mediaType(mime),
    ));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    final json = jsonDecode(body) as Map<String, dynamic>;

    if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
      return json['url'] as String? ?? '';
    }
    throw Exception(json['error'] as String? ?? 'تعذر رفع الصورة');
  }
}

/// Converts a MIME string to a MediaType for http.MultipartFile
http.MediaType _mediaType(String mime) {
  final parts = mime.split('/');
  if (parts.length == 2) return http.MediaType(parts[0], parts[1]);
  return http.MediaType('image', 'jpeg');
}

final subscriptionService = SubscriptionService();
