import 'package:flutter/material.dart';
import '../core/admin_api.dart';
import '../core/admin_scope.dart';
import '../core/app_colors.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/file_upload_field.dart';

class AdminLessonsScreen extends StatefulWidget {
  const AdminLessonsScreen({super.key});
  @override
  State<AdminLessonsScreen> createState() => _AdminLessonsScreenState();
}

class _AdminLessonsScreenState extends State<AdminLessonsScreen> {
  List<dynamic> _lessons = [];
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
        adminApi.get('/lessons?${adminScope.queryParams}'),
        adminApi.get('/subjects?${adminScope.queryParams}'),
      ]);
      if (mounted) {
        setState(() {
          _lessons = results[0]['lessons'] ?? [];
          _subjects = results[1]['subjects'] ?? [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // جلب أساتذة مادة معينة
  Future<List<dynamic>> _loadTeachersForSubject(int subjectId) async {
    try {
      final data = await adminApi.get('/teachers?subject_id=$subjectId');
      return data['teachers'] ?? [];
    } catch (_) {
      return [];
    }
  }

  void _showForm({Map<String, dynamic>? lesson}) {
    final titleCtrl = TextEditingController(text: lesson?['title'] ?? '');
    final descCtrl = TextEditingController(text: lesson?['description'] ?? '');
    final videoUrlCtrl = TextEditingController(text: lesson?['video_url'] ?? '');
    final summaryUrlCtrl = TextEditingController(text: lesson?['summary_url'] ?? '');
    final durCtrl = TextEditingController(text: lesson?['duration_minutes']?.toString() ?? '');
    bool isFree = lesson?['is_free'] ?? false;
    String coverUrl = lesson?['cover_image_url'] ?? '';
    String videoUrl = lesson?['video_url'] ?? '';
    String summaryUrl = lesson?['summary_url'] ?? '';

    final rawSubj = lesson?['subject_id'];
    int? selectedSubjectId = (rawSubj is int && rawSubj > 0) ? rawSubj : null;
    final rawTeacher = lesson?['teacher_id'];
    int? selectedTeacherId = (rawTeacher is int && rawTeacher > 0) ? rawTeacher : null;

    List<dynamic> teachersForSubject = [];
    bool loadingTeachers = false;

    if (_subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا توجد مواد في ${adminScope.label}. أضف مادة أولاً.', style: const TextStyle(fontFamily: 'Cairo'))),
      );
      return;
    }

    // تحميل أساتذة المادة الحالية إن وجدت
    Future<void> fetchTeachers(int? subjId, StateSetter setS) async {
      if (subjId == null) {
        setS(() { teachersForSubject = []; selectedTeacherId = null; });
        return;
      }
      setS(() { loadingTeachers = true; selectedTeacherId = null; });
      final list = await _loadTeachersForSubject(subjId);
      setS(() { teachersForSubject = list; loadingTeachers = false; });
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          // تحميل أساتذة المادة الأولية عند فتح النموذج للتعديل
          if (selectedSubjectId != null && teachersForSubject.isEmpty && !loadingTeachers) {
            Future.microtask(() => fetchTeachers(selectedSubjectId, setS));
          }

          return AlertDialog(
            title: Text(lesson == null ? 'إضافة درس' : 'تعديل درس', style: const TextStyle(fontFamily: 'Cairo')),
            content: SizedBox(
              width: 540,
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // مؤشر القسم
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

                  // العنوان
                  _LsTextField(titleCtrl, 'العنوان *'),
                  const SizedBox(height: 10),

                  // المادة
                  DropdownButtonFormField<int>(
                    initialValue: _subjects.any((s) => s['id'] == selectedSubjectId) ? selectedSubjectId : null,
                    decoration: const InputDecoration(labelText: 'المادة *', labelStyle: TextStyle(fontFamily: 'Cairo'), border: OutlineInputBorder()),
                    hint: const Text('اختر المادة', style: TextStyle(fontFamily: 'Cairo')),
                    items: _subjects.map<DropdownMenuItem<int>>((s) => DropdownMenuItem<int>(
                      value: s['id'] as int,
                      child: Text(s['name_ar'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                    )).toList(),
                    onChanged: (v) {
                      setS(() { selectedSubjectId = v; selectedTeacherId = null; teachersForSubject = []; });
                      fetchTeachers(v, setS);
                    },
                  ),
                  const SizedBox(height: 10),

                  // الأستاذ — Dropdown ديناميكي حسب المادة
                  if (loadingTeachers)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 8),
                        Text('جارٍ تحميل الأساتذة...', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AdminColors.textSecondary)),
                      ]),
                    )
                  else
                    DropdownButtonFormField<int?>(
                      initialValue: teachersForSubject.any((t) => t['id'] == selectedTeacherId) ? selectedTeacherId : null,
                      decoration: const InputDecoration(labelText: 'الأستاذ (اختياري)', labelStyle: TextStyle(fontFamily: 'Cairo'), border: OutlineInputBorder()),
                      hint: const Text('بدون أستاذ', style: TextStyle(fontFamily: 'Cairo')),
                      items: [
                        const DropdownMenuItem<int?>(value: null, child: Text('بدون أستاذ', style: TextStyle(fontFamily: 'Cairo'))),
                        ...teachersForSubject.map<DropdownMenuItem<int?>>((t) => DropdownMenuItem<int?>(
                          value: t['id'] as int,
                          child: Text(t['full_name'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                        )),
                      ],
                      onChanged: (v) => setS(() => selectedTeacherId = v),
                    ),
                  if (selectedSubjectId != null && !loadingTeachers && teachersForSubject.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: const Text('لا يوجد أساتذة لهذه المادة — سيُحفظ الدرس بدون أستاذ', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AdminColors.textSecondary)),
                    ),
                  const SizedBox(height: 10),

                  // الوصف
                  _LsTextField(descCtrl, 'الوصف (اختياري)'),
                  const SizedBox(height: 10),

                  // رفع الفيديو
                  FileUploadField(
                    label: 'ملف الفيديو (mp4, webm, mov)',
                    uploadType: UploadType.video,
                    uploadCategory: 'videos',
                    initialUrl: videoUrl,
                    onUploaded: (url) => setS(() {
                      videoUrl = url;
                      videoUrlCtrl.text = url;
                    }),
                  ),
                  const SizedBox(height: 6),
                  // أو رابط يوتيوب يدوي
                  _LsTextField(videoUrlCtrl, 'أو رابط فيديو خارجي (YouTube...)'),
                  const SizedBox(height: 10),

                  // رفع الملخص PDF
                  FileUploadField(
                    label: 'ملف الملخص (PDF)',
                    uploadType: UploadType.pdf,
                    uploadCategory: 'files',
                    initialUrl: summaryUrl,
                    onUploaded: (url) => setS(() {
                      summaryUrl = url;
                      summaryUrlCtrl.text = url;
                    }),
                  ),
                  const SizedBox(height: 6),
                  _LsTextField(summaryUrlCtrl, 'أو رابط الملخص يدوياً'),
                  const SizedBox(height: 10),

                  // المدة
                  _LsTextField(durCtrl, 'المدة (دقائق)'),
                  const SizedBox(height: 10),

                  // درس مجاني
                  Row(children: [
                    const Text('درس مجاني', style: TextStyle(fontFamily: 'Cairo')),
                    const Spacer(),
                    Switch(value: isFree, onChanged: (v) => setS(() => isFree = v), activeThumbColor: AdminColors.primary),
                  ]),
                  const SizedBox(height: 10),

                  // صورة الغلاف
                  FileUploadField(
                    label: 'صورة الغلاف',
                    uploadType: UploadType.image,
                    uploadCategory: 'covers',
                    initialUrl: coverUrl,
                    onUploaded: (url) => setS(() => coverUrl = url),
                  ),
                ]),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white),
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال العنوان', style: TextStyle(fontFamily: 'Cairo'))));
                    return;
                  }
                  if (selectedSubjectId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار المادة', style: TextStyle(fontFamily: 'Cairo'))));
                    return;
                  }
                  Navigator.pop(ctx);
                  // video_url: إذا رُفع ملف يُقدَّم على الرابط اليدوي
                  final finalVideoUrl = videoUrl.isNotEmpty ? videoUrl : videoUrlCtrl.text.trim();
                  final finalSummaryUrl = summaryUrl.isNotEmpty ? summaryUrl : summaryUrlCtrl.text.trim();
                  final body = <String, dynamic>{
                    'title': titleCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'video_url': finalVideoUrl,
                    'summary_url': finalSummaryUrl,
                    'duration_minutes': int.tryParse(durCtrl.text) ?? 0,
                    'is_free': isFree,
                    'subject_id': selectedSubjectId,
                    'teacher_id': selectedTeacherId ?? 0,
                    'cover_image_url': coverUrl,
                  };
                  try {
                    if (lesson == null) {
                      await adminApi.post('/lessons', body);
                    } else {
                      await adminApi.put('/lessons/${lesson['id']}', body);
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
          );
        },
      ),
    );
  }

  Future<void> _delete(int id) async {
    try {
      await adminApi.delete('/lessons/$id');
      _load();
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الحذف: $msg', style: const TextStyle(fontFamily: 'Cairo'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AdminColors.background,
    body: Row(children: [
      const AdminSidebar(currentRoute: '/lessons'),
      Expanded(child: Column(children: [
        _LsBar(title: 'الدروس', subtitle: adminScope.label, onAdd: () => _showForm()),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _buildList()),
      ])),
    ]),
  );

  Widget _buildList() {
    if (_lessons.isEmpty) {
      return Center(child: Text('لا توجد دروس في ${adminScope.label}', style: const TextStyle(fontFamily: 'Cairo', color: AdminColors.textSecondary)));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: _lessons.map<Widget>((l) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AdminColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border)),
          child: Row(children: [
            _CoverThumb(url: l['cover_image_url'], icon: Icons.play_lesson_outlined),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l['title'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14, color: AdminColors.textPrimary)),
              Text('${l['subject_name'] ?? ''} — ${l['is_free'] == true ? 'مجاني' : 'مدفوع'}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.textSecondary)),
            ])),
            if ((l['video_url'] as String? ?? '').isNotEmpty)
              const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.videocam_outlined, size: 16, color: AdminColors.primary)),
            if ((l['summary_url'] as String? ?? '').isNotEmpty)
              const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.description_outlined, size: 16, color: AdminColors.success)),
            IconButton(icon: const Icon(Icons.edit_outlined, color: AdminColors.primary), onPressed: () => _showForm(lesson: Map<String, dynamic>.from(l))),
            IconButton(icon: const Icon(Icons.delete_outline, color: AdminColors.error), onPressed: () => _delete(l['id'] as int)),
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

class _LsTextField extends StatelessWidget {
  final TextEditingController c;
  final String label;
  const _LsTextField(this.c, this.label);
  @override
  Widget build(BuildContext context) => TextField(
    controller: c,
    decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(fontFamily: 'Cairo'), border: const OutlineInputBorder()),
    style: const TextStyle(fontFamily: 'Cairo'),
  );
}

class _LsBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onAdd;
  const _LsBar({required this.title, required this.subtitle, required this.onAdd});
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
