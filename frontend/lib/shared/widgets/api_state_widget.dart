import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('جاري التحميل...', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class ApiErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ApiErrorWidget({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApiBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) builder;
  final VoidCallback onRetry;

  const ApiBuilder({
    super.key,
    required this.future,
    required this.builder,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }
        if (snapshot.hasError) {
          final err = snapshot.error;
          if (err is ApiException && (err.statusCode == 401 || err.statusCode == 403)) {
            return ApiErrorWidget(message: 'انتهت الجلسة، يرجى تسجيل الدخول من جديد', onRetry: onRetry);
          }
          final msg = err.toString();
          if (msg.contains('SocketException') || msg.contains('Connection refused') || msg.contains('Connection')) {
            return ApiErrorWidget(message: 'تعذر الاتصال بالخادم', onRetry: onRetry);
          }
          return ApiErrorWidget(message: msg.replaceAll('Exception: ', '').replaceAll('ApiException(', '').split(':').last.trim(), onRetry: onRetry);
        }
        if (!snapshot.hasData) {
          return ApiErrorWidget(message: 'لا توجد بيانات', onRetry: onRetry);
        }
        return builder(snapshot.data as T);
      },
    );
  }
}
