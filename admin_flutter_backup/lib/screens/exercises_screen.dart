import 'package:flutter/material.dart';
import '../core/admin_api.dart';
import '../core/admin_scope.dart';
import '../core/app_colors.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/file_upload_field.dart';

class AdminExercisesScreen extends StatefulWidget {
  const AdminExercisesScreen({super.key});
  @override
  State<AdminExercisesScreen> createState() => _AdminExercisesScreenState();
}

class _AdminExercisesScreenState extends State<AdminExercisesScreen> {
  List<dynamic> _exercises = [];
  List<dynamic> _subjects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    adminScope.addListener(_onScopeChange);
    _load();
  }

  @override
  void dispose() {
    adminScope.removeListener(_onScopeChange);
    super.dispose();
  }

  void _onScopeChange() => _load();

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        adminApi.get('/exercises?${adminScope.queryParams}'),
        adminApi.get('/subjects?${adminScope.queryParams}'),
      ]);
      if (mounted) {
        setState(() {
          _exercises = results[0]['exercises'] ?? [];
          _subjects = results[1]['subjects'] ?? [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showForm({Map<String, dynamic>? ex}) {
    final titleCtrl = TextEditingController(text: ex?['title'] ?? '');
    final yearCtrl = TextEditingController(text: ex?['year']?.toString() ?? '');
    final vidCtrl = TextEditingController(text: ex?['video_solution_url'] ?? '');
    final diffRaw = ex?['difficulty'] as String? ?? 'متوسط';
    String difficulty = ['سهل', 'متوسط', 'صعب'].contains(diffRaw) ? diffRaw : 'متوسط';
    String examUrl = ex?['exercise_file_url'] ?? '';
    String solUrl = ex?['solution_file_url'] ?? '';
    String coverUrl = ex?['cover_image_url'] ?? '';

    final rawSubj = ex?['subject_id'];
    int? selectedSubjectId = (rawSubj is int && rawSubj > 0) ? rawSubj : null;

    if (_subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا توجد مواد في ${adminScope.label}. أضف مادة أولاً.', style: const TextStyle(fontFamily: 'Cairo'))),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(ex == null ? 'إضافة تمرين' : 'تعديل تمرين', style: const TextStyle(fontFamily: 'Cairo')),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AdminColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.info_outline, color: AdminColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Text('المسار: ${adminScope.label}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AdminColors.primary)),
                  ]),
                ),
                const SizedBox(height: 10),
                _ExTextField(titleCtrl, 'العنوان *'),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _subjects.any((s) => s['id'] == selectedSubjectId) ? selectedSubjectId : null,
                  decoration: const InputDecoration(labelText: 'المادة *', labelStyle: TextStyle(fontFamily: 'Cairo'), border: OutlineInputBorder()),
                  hint: const Text('اختر المادة', style: TextStyle(fontFamily: 'Cairo')),
                  items: _subjects.map<DropdownMenuItem<int>>((s) => DropdownMenuItem<int>(
                    value: s['id'] as int,
                    child: Text(s['name_ar'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                  )).toList(),
                  onChanged: (v) => setS(() => selectedSubjectId = v),
                ),
                const SizedBox(height: 10),
                _ExTextField(yearCtrl, 'السنة (اختياري)'),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: difficulty,
                  decoration: const InputDecoration(labelText: 'الصعوبة', labelStyle: TextStyle(fontFamily: 'Cairo'), border: OutlineInputBorder()),
                  items: ['سهل', 'متوسط', 'صعب'].map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                  onChanged: (v) => setS(() => difficulty = v!),
                ),
                const SizedBox(height: 10),
                FileUploadField(label: 'ملف التمرين (PDF)', uploadType: UploadType.pdf, uploadCategory: 'files', initialUrl: examUrl, onUploaded: (url) => setS(() => examUrl = url)),
                const SizedBox(height: 10),
                FileUploadField(label: 'ملف الحل (PDF)', uploadType: UploadType.pdf, uploadCategory: 'files', initialUrl: solUrl, onUploaded: (url) => setS(() => solUrl = url)),
                const SizedBox(height: 10),
                FileUploadField(label: 'ملف فيديو الحل (mp4, webm)', uploadType: UploadType.video, uploadCategory: 'videos', initialUrl: examUrl.isEmpty ? (ex?['video_solution_url'] ?? '') : '', onUploaded: (url) => setS(() => vidCtrl.text = url)),
                const SizedBox(height: 6),
                _ExTextField(vidCtrl, 'أو رابط فيديو خارجي (اختياري)'),
                const SizedBox(height: 10),
                FileUploadField(label: 'صورة الغلاف', uploadType: UploadType.image, uploadCategory: 'covers', initialUrl: coverUrl, onUploaded: (url) => setS(() => coverUrl = url)),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white),
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال عنوان التمرين', style: TextStyle(fontFamily: 'Cairo'))));
                  return;
                }
                if (selectedSubjectId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار المادة', style: TextStyle(fontFamily: 'Cairo'))));
                  return;
                }
                Navigator.pop(ctx);
                final body = <String, dynamic>{
                  'title': titleCtrl.text.trim(),
                  'subject_id': selectedSubjectId,
                  'year': int.tryParse(yearCtrl.text) ?? 0,
                  'difficulty': difficulty,
                  'exercise_file_url': examUrl,
                  'solution_file_url': solUrl,
                  'video_solution_url': vidCtrl.text.trim(),
                  'cover_image_url': coverUrl,
                };
                try {
                  if (ex == null) {
                    await adminApi.post('/exercises', body);
                  } else {
                    await adminApi.put('/exercises/${ex['id']}', body);
                  }
                  _load();
                } catch (e) {
                  if (mounted) {
                    final msg = e.toString().replaceFirst('Exception: ', '');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الحفظ: $msg', style: const TextStyle(fontFamily: 'Cairo'))));
                  }
                }
              },
              child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AdminColors.background,
    body: Row(children: [
      const AdminSidebar(currentRoute: '/exercises'),
      Expanded(child: Column(children: [
        _ExBar(title: 'التمارين', subtitle: adminScope.label, onAdd: () => _showForm()),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _buildList()),
      ])),
    ]),
  );

  Widget _buildList() {
    if (_exercises.isEmpty) {
      return Center(child: Text('لا توجد تمارين في ${adminScope.label}', style: const TextStyle(fontFamily: 'Cairo', color: AdminColors.textSecondary)));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: _exercises.map<Widget>((e) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AdminColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border)),
          child: Row(children: [
            _CoverThumb(url: e['cover_image_url'], icon: Icons.quiz_outlined),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e['title'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14, color: AdminColors.textPrimary)),
              Text('${e['subject_name'] ?? ''} — ${e['difficulty'] ?? ''} — ${e['year'] != null && e['year'] != 0 ? e['year'] : ''}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.textSecondary)),
            ])),
            IconButton(icon: const Icon(Icons.edit_outlined, color: AdminColors.primary), onPressed: () => _showForm(ex: Map<String, dynamic>.from(e))),
            IconButton(icon: const Icon(Icons.delete_outline, color: AdminColors.error), onPressed: () async {
              try { await adminApi.delete('/exercises/${e['id']}'); _load(); } catch (_) {}
            }),
          ]),
        )).toList(),
      ),
    );
  }
}

class _CoverThumb extends StatelessWidget {
  final dynamic url;
  final IconData icon;
  const _CoverThumb({required this.url, required this.icon});
  @override
  Widget build(BuildContext context) {
    final urlStr = url as String? ?? '';
    final fullUrl = urlStr.startsWith('/') ? 'http://localhost:8081$urlStr' : urlStr;
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: AdminColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: urlStr.isNotEmpty
          ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(fullUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => Icon(icon, color: AdminColors.primary, size: 20)))
          : Icon(icon, color: AdminColors.primary, size: 20),
    );
  }
}

class _ExTextField extends StatelessWidget {
  final TextEditingController c;
  final String label;
  const _ExTextField(this.c, this.label);
  @override
  Widget build(BuildContext context) => TextField(
    controller: c,
    decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(fontFamily: 'Cairo'), border: const OutlineInputBorder()),
    style: const TextStyle(fontFamily: 'Cairo'),
  );
}

class _ExBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onAdd;
  const _ExBar({required this.title, required this.subtitle, required this.onAdd});
  @override
  Widget build(BuildContext context) => Container(
    height: 64,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: const BoxDecoration(color: AdminColors.white, border: Border(bottom: BorderSide(color: AdminColors.border))),
    child: Row(children: [
      const Spacer(),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AdminColors.textPrimary)),
        Text(subtitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.textSecondary)),
      ]),
      const Spacer(),
      ElevatedButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('إضافة', style: TextStyle(fontFamily: 'Cairo')),
        style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white),
      ),
    ]),
  );
}
