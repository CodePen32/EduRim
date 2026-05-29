import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

import '../models/subscription.dart';
import '../network/api_client.dart';

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
    if (!kIsWeb) throw Exception('رفع الصور غير مدعوم على هذه المنصة');

    // 1. اختر الملف
    final picked = await _pickFileBytesWeb();
    if (picked == null) throw Exception('لم يتم اختيار ملف');

    // 2. ارفعه للخادم
    final token = apiClient.currentToken ?? '';
    final uri = Uri.parse('${ApiClient.baseUrl}/me/uploads?type=images');

    final request = http.MultipartRequest('POST', uri);
    if (token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      picked.$1,
      filename: picked.$2,
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

final subscriptionService = SubscriptionService();

/// فتح file picker على الويب وإرجاع (bytes, filename)
Future<(Uint8List, String)?> _pickFileBytesWeb() async {
  final completer = Completer<(Uint8List, String)?>();

  final input = web.document.createElement('input') as web.HTMLInputElement;
  input.type = 'file';
  input.accept = 'image/*';

  // عند اختيار ملف
  input.onchange = ((web.Event _) {
    final files = input.files;
    if (files == null || files.length == 0) {
      completer.complete(null);
      return;
    }
    final file = files.item(0)!;
    final filename = file.name;

    final reader = web.FileReader();

    // عند انتهاء القراءة
    reader.onloadend = ((web.Event _) {
      final result = reader.result;
      if (result == null) {
        completer.completeError(Exception('تعذر قراءة الملف'));
        return;
      }
      // result هو JSArrayBuffer — نحوله لـ Uint8List
      final jsBuffer = result as JSArrayBuffer;
      final uint8 = jsBuffer.toDart.asUint8List();
      completer.complete((uint8, filename));
    }).toJS;

    reader.onerror = ((web.Event _) {
      completer.completeError(Exception('خطأ في قراءة الملف'));
    }).toJS;

    reader.readAsArrayBuffer(file);
  }).toJS;

  input.click();
  return completer.future;
}
