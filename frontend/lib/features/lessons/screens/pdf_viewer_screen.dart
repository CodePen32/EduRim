import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/url_helper.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _pdfUrl;
  String? _title;
  bool _argsLoaded = false;
  bool _loading = true;
  String? _error;
  Uint8List? _bytes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      _argsLoaded = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _title = args['title'] as String? ?? 'الملخص';
        final rawUrl = args['pdfUrl'] as String? ?? '';
        _pdfUrl = rawUrl.isNotEmpty ? buildFileUrl(rawUrl) : null;
      } else if (args is String) {
        _pdfUrl = buildFileUrl(args);
        _title = 'الملخص';
      }
      debugPrint('=== PdfViewerScreen ===');
      debugPrint('pdfUrl: $_pdfUrl');
      _loadPdf();
    }
  }

  Future<void> _loadPdf() async {
    if (_pdfUrl == null || _pdfUrl!.isEmpty) {
      if (mounted) setState(() { _loading = false; _error = 'الملخص غير متاح حالياً'; });
      return;
    }

    if (mounted) setState(() { _loading = true; _error = null; _bytes = null; });

    try {
      debugPrint('Fetching: $_pdfUrl');
      final response = await http.get(Uri.parse(_pdfUrl!));
      debugPrint('Status: ${response.statusCode}  Bytes: ${response.bodyBytes.length}  CT: ${response.headers['content-type']}');

      if (!mounted) return;

      if (response.statusCode != 200) {
        setState(() { _loading = false; _error = 'تعذر تحميل الملخص (رمز: ${response.statusCode})'; });
        return;
      }
      if (response.bodyBytes.isEmpty) {
        setState(() { _loading = false; _error = 'ملف PDF فارغ أو غير صالح'; });
        return;
      }

      setState(() { _loading = false; _bytes = response.bodyBytes; });
    } catch (e) {
      debugPrint('PDF fetch error: $e');
      if (mounted) setState(() { _loading = false; _error = 'تعذر جلب الملخص: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title ?? 'الملخص', style: const TextStyle(fontFamily: 'Cairo', fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        actions: [
          if (_pdfUrl != null && _pdfUrl!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'فتح في المتصفح',
              onPressed: () => openExternalUrl(_pdfUrl, context: context),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحميل الملخص...', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    if (_bytes != null) {
      return SfPdfViewer.memory(_bytes!);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              _error ?? 'الملخص غير متاح حالياً',
              style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_pdfUrl != null && _pdfUrl!.isNotEmpty) ...[
              ElevatedButton.icon(
                onPressed: _loadPdf,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => openExternalUrl(_pdfUrl, context: context),
                icon: const Icon(Icons.open_in_new),
                label: const Text('فتح في المتصفح', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
