import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/models/progress_stats.dart';
import '../../../core/services/progress_service.dart';
import '../../../shared/widgets/app_header.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  ProgressStats? _stats;
  List<SubjectProgress> _subjects = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final stats = await progressService.getStats();
      final subjects = await progressService.getBySubject();
      if (mounted) {
        setState(() {
          _stats = stats;
          _subjects = subjects;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _error = tr('profile.loadError'); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: tr('progress.title')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _load,
                        child: Text(tr('common.retry'), style: const TextStyle(fontFamily: 'Cairo', color: AppColors.primary)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Stats cards
                      Row(
                        children: [
                          Expanded(child: _StatCard(label: tr('progress.completedLessons'), value: '${_stats?.completedLessons ?? 0}', icon: Icons.check_circle_outline)),
                          const SizedBox(width: 12),
                          Expanded(child: _StatCard(label: tr('progress.avg'), value: '${(_stats?.averagePercentage ?? 0).toStringAsFixed(0)}%', icon: Icons.trending_up)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if ((_stats?.lastLessonTitle ?? '').isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.play_circle_outline, color: AppColors.primary, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tr('progress.lastLesson'), style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                                    Text(_stats!.lastLessonTitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(tr('progress.bySubject'), style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      if (_subjects.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(tr('progress.noData'), style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
                          ),
                        )
                      else
                        ..._subjects.map((sp) => _SubjectProgressCard(subject: sp)),
                    ],
                  ),
                ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _SubjectProgressCard extends StatelessWidget {
  final SubjectProgress subject;

  const _SubjectProgressCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject.subjectName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text('${subject.completedLessons}/${subject.totalLessons}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: subject.totalLessons > 0 ? subject.completedLessons / subject.totalLessons : 0,
              minHeight: 8,
              backgroundColor: AppColors.accentLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('${subject.percentage}%', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
