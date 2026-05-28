import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/admin_api.dart';
import '../core/app_colors.dart';

enum UploadType { image, pdf, video, any }

class FileUploadField extends StatefulWidget {
  final String label;
  final UploadType uploadType;
  final String uploadCategory; // 'covers', 'files', 'images'
  final String initialUrl;
  final ValueChanged<String> onUploaded;

  const FileUploadField({
    super.key,
    required this.label,
    required this.uploadType,
    required this.uploadCategory,
    required this.onUploaded,
    this.initialUrl = '',
  });

  @override
  State<FileUploadField> createState() => _FileUploadFieldState();
}

class _FileUploadFieldState extends State<FileUploadField> {
  String _url = '';
  bool _uploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _url = widget.initialUrl;
  }

  List<String> get _allowedExtensions {
    switch (widget.uploadType) {
      case UploadType.image:
        return ['jpg', 'jpeg', 'png', 'webp'];
      case UploadType.pdf:
        return ['pdf'];
      case UploadType.video:
        return ['mp4', 'webm', 'mov'];
      case UploadType.any:
        return ['jpg', 'jpeg', 'png', 'webp', 'pdf', 'mp4', 'webm'];
    }
  }

  FileType get _fileType {
    switch (widget.uploadType) {
      case UploadType.image:
        return FileType.image;
      case UploadType.pdf:
      case UploadType.video:
      case UploadType.any:
        return FileType.custom;
    }
  }

  Future<void> _pick() async {
    setState(() { _error = null; });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: _fileType,
        allowedExtensions: _fileType == FileType.custom ? _allowedExtensions : null,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null) return;
      await _upload(file.bytes!, file.name);
    } catch (e) {
      if (mounted) setState(() => _error = 'فشل الاختيار: ${e.toString()}');
    }
  }

  Future<void> _upload(Uint8List bytes, String filename) async {
    setState(() { _uploading = true; _error = null; });
    try {
      final token = await adminApi.getToken();
      final uri = Uri.parse('http://localhost:8081/api/admin/uploads?type=${widget.uploadCategory}');
      final request = http.MultipartRequest('POST', uri);
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        final url = data['url'] as String;
        if (mounted) {
          setState(() { _url = url; _uploading = false; });
          widget.onUploaded(url);
        }
      } else {
        final err = jsonDecode(body)['error'] ?? 'خطأ في الرفع';
        if (mounted) setState(() { _error = err; _uploading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'خطأ: ${e.toString()}'; _uploading = false; });
    }
  }

  bool get _isImage {
    final lower = _url.toLowerCase();
    return lower.endsWith('.jpg') || lower.endsWith('.jpeg') ||
        lower.endsWith('.png') || lower.endsWith('.webp');
  }

  String _resolveUrl(String url) {
    if (url.startsWith('/')) return 'http://localhost:8081$url';
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AdminColors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AdminColors.border),
            borderRadius: BorderRadius.circular(8),
            color: AdminColors.background,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _uploading ? null : _pick,
                    icon: _uploading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(widget.uploadType == UploadType.image
                            ? Icons.image_outlined
                            : widget.uploadType == UploadType.video
                                ? Icons.videocam_outlined
                                : Icons.upload_file_outlined,
                            size: 16),
                    label: Text(_uploading ? 'جارٍ الرفع...' : 'اختيار ملف', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                  if (_url.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _url,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AdminColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, size: 16, color: AdminColors.error),
                      onPressed: () { setState(() => _url = ''); widget.onUploaded(''); },
                      tooltip: 'مسح',
                    ),
                  ],
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 6),
                Text(_error!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.error)),
              ],
              if (_url.isNotEmpty && _isImage) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    _resolveUrl(_url),
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => Container(
                      height: 60,
                      color: AdminColors.border,
                      child: const Center(child: Icon(Icons.broken_image_outlined, color: AdminColors.textSecondary)),
                    ),
                  ),
                ),
              ],
              if (_url.isNotEmpty && !_isImage) ...[
                const SizedBox(height: 6),
                const Row(children: [
                  Icon(Icons.check_circle, size: 14, color: AdminColors.success),
                  SizedBox(width: 4),
                  Text('تم الرفع بنجاح', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.success)),
                ]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
