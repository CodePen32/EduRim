import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/models/past_exam.dart';
import '../../../core/services/past_exam_service.dart';
import '../../../core/utils/url_helper.dart';
import '../../../shared/widgets/app_header.dart';

class PastExamsScreen extends StatefulWidget {
  const PastExamsScreen({super.key});
  @override
  State<PastExamsScreen> createState() => _PastExamsScreenState();
}

class _PastExamsScreenState extends State<PastExamsScreen> {
  List<PastExam> _exams = [];
  bool _loading = true;
  int? _subjectId;
  String _subjectName = '';
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _didLoad = true;
      _subjectName = tr('exams.title');
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _subjectId = args['subject_id'] as int?;
        _subjectName = args['subject_name'] as String? ?? _subjectName;
      }
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final List<PastExam> exams;
      if (_subjectId != null) {
        exams = await pastExamService.getBySubject(_subjectId!);
      } else {
        exams = await pastExamService.getPastExams();
      }
      if (mounted) setState(() { _exams = exams; _loading = false; });
    } catch (_) {
      if (mounted) { setState(() => _loading = false); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: _subjectName),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _exams.isEmpty
              ? Center(
                  child: Text(
                    tr('exams.none'),
                    style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _exams.length,
                  itemBuilder: (context, i) => _ExamCard(exam: _exams[i]),
                ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final PastExam exam;
  const _ExamCard({required this.exam});

  String _resolveUrl(String url) => buildFileUrl(url);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (exam.hasCover)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                _resolveUrl(exam.coverImageUrl),
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context2, err, stack) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${exam.year}',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(exam.subjectName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 8),
                Text(exam.title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                if (exam.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    exam.description,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 14),
                Row(children: [
                  if (exam.hasExam)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => openExternalUrl(_resolveUrl(exam.examFileUrl), context: context),
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                        label: Text(tr('exams.viewTopic'), style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  if (exam.hasExam && exam.hasSolution) const SizedBox(width: 10),
                  if (exam.hasSolution)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => openExternalUrl(_resolveUrl(exam.solutionFileUrl), context: context),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: Text(tr('exams.viewSolution'), style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          side: const BorderSide(color: AppColors.success),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  if (!exam.hasExam && !exam.hasSolution)
                    Text(tr('exams.filesUnavailable'), style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
