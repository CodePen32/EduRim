import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/search_result.dart';
import '../../../core/services/search_service.dart';
import '../../../shared/widgets/app_header.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<SearchResult> _results = [];
  bool _loading = false;
  String? _error;
  bool _searched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) return;
    setState(() { _loading = true; _error = null; _searched = true; });
    try {
      final results = await searchService.search(q.trim());
      if (mounted) setState(() { _results = results; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'تعذر إجراء البحث'; _loading = false; });
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'subject': return Icons.book_outlined;
      case 'lesson': return Icons.play_lesson_outlined;
      case 'exercise': return Icons.quiz_outlined;
      case 'teacher': return Icons.person_outline;
      default: return Icons.search;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'subject': return 'مادة';
      case 'lesson': return 'درس';
      case 'exercise': return 'تمرين';
      case 'teacher': return 'أستاذ';
      default: return type;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'subject': return AppColors.primary;
      case 'lesson': return AppColors.success;
      case 'exercise': return AppColors.warning;
      case 'teacher': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'البحث'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              style: const TextStyle(fontFamily: 'Cairo'),
              decoration: InputDecoration(
                hintText: 'ابحث عن درس، مادة، أستاذ...',
                hintStyle: const TextStyle(fontFamily: 'Cairo'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() { _results = []; _searched = false; });
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.error)))
                    : !_searched
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search, size: 64, color: AppColors.textLight),
                                const SizedBox(height: 12),
                                const Text('ابدأ البحث للعثور على المحتوى', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
                              ],
                            ),
                          )
                        : _results.isEmpty
                            ? const Center(child: Text('لا توجد نتائج', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)))
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _results.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 8),
                                itemBuilder: (context, i) {
                                  final r = _results[i];
                                  final color = _typeColor(r.type);
                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.cardBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(_typeIcon(r.type), color: color, size: 22),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(r.title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14)),
                                              if (r.extra.isNotEmpty)
                                                Text(r.extra, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(_typeLabel(r.type), style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: color, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
          ),
        ],
      ),
    );
  }
}
