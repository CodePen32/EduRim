import 'package:flutter/material.dart';
import '../core/admin_api.dart';
import '../core/admin_scope.dart';
import '../core/app_colors.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/file_upload_field.dart';

class AdminPastExamsScreen extends StatefulWidget {
  const AdminPastExamsScreen({super.key});
  @override
  State<AdminPastExamsScreen> createState() => _AdminPastExamsScreenState();
}

class _AdminPastExamsScreenState extends State<AdminPastExamsScreen> {
  List<dynamic> _exams = [];
  List<dynamic> _subjects = [];
  bool _loading = true;

  static const _bacBranches = [
    {'id': 1, 'name': 'Bac C'},
    {'id': 2, 'name': 'Bac D'},
  ];

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
        adminApi.get('/past-exams?${adminScope.queryParams}'),
        adminApi.get('/subjects?${adminScope.queryParams}'),
      ]);
      if (mounted) {
        setState(() {
          _exams = results[0]['past_exams'] ?? [];
          _subjects = results[1]['subjects'] ?? [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showForm({Map<String, dynamic>? exam}) {
    final titleCtrl = TextEditingController(text: exam?['title'] ?? '');
    final yearCtrl = TextEditingController(text: exam?['year']?.toString() ?? '');
    final descCtrl = TextEditingController(text: exam?['description'] ?? '');
    String examUrl = exam?['exam_file_url'] ?? '';
    String solUrl = exam?['solution_file_url'] ?? '';
    String coverUrl = exam?['cover_image_url'] ?? '';

    // القيم من الـ scope الحالي
    final lpId = adminScope.learningPathId;
    final isBac = lpId == AdminScope.bacPathId;
    int? bacId = adminScope.bacBranchId > 0 ? adminScope.bacBranchId : null;

    final rawSubj = exam?['subject_id'];
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
        builder: (ctx, setS) {
          return AlertDialog(
            title: Text(exam == null ? 'إضافة موضوع امتحان' : 'تعديل موضوع', style: const TextStyle(fontFamily: 'Cairo')),
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
                  _PeTextField(titleCtrl, 'العنوان *'),
                  const SizedBox(height: 10),
                  _PeTextField(yearCtrl, 'السنة *'),
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
                  if (isBac) ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int?>(
                      value: bacId,
                      decoration: const InputDecoration(labelText: 'الشعبة', labelStyle: TextStyle(fontFamily: 'Cairo'), border: OutlineInputBorder()),
                      hint: const Text('كل الشعب', style: TextStyle(fontFamily: 'Cairo')),
                      items: [
                        const DropdownMenuItem<int?>(value: null, child: Text('كل الشعب', style: TextStyle(fontFamily: 'Cairo'))),
                        ..._bacBranches.map((b) => DropdownMenuItem<int?>(
                          value: b['id'] as int,
                          child: Text(b['name'] as String, style: const TextStyle(fontFamily: 'Cairo')),
                        )),
                      ],
                      onChanged: (v) => setS(() => bacId = v),
                    ),
                  ],
                  const SizedBox(height: 10),
                  _PeTextField(descCtrl, 'الوصف (اختياري)'),
                  const SizedBox(height: 10),
                  FileUploadField(label: 'ملف الموضوع (PDF)', uploadType: UploadType.pdf, uploadCategory: 'files', initialUrl: examUrl, onUploaded: (url) => setS(() => examUrl = url)),
                  const SizedBox(height: 10),
                  FileUploadField(label: 'ملف الحل (PDF)', uploadType: UploadType.pdf, uploadCategory: 'files', initialUrl: solUrl, onUploaded: (url) => setS(() => solUrl = url)),
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال العنوان', style: TextStyle(fontFamily: 'Cairo'))));
                    return;
                  }
                  final year = int.tryParse(yearCtrl.text.trim());
                  if (year == null || year < 1900 || year > 2100) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال سنة صحيحة', style: TextStyle(fontFamily: 'Cairo'))));
                    return;
                  }
                  if (selectedSubjectId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار المادة', style: TextStyle(fontFamily: 'Cairo'))));
                    return;
                  }
                  Navigator.pop(ctx);
                  final body = <String, dynamic>{
                    'title': titleCtrl.text.trim(),
                    'year': year,
                    'subject_id': selectedSubjectId,
                    'description': descCtrl.text.trim(),
                    'exam_file_url': examUrl,
                    'solution_file_url': solUrl,
                    'cover_image_url': coverUrl,
                    'learning_path_id': lpId,
                    'bac_branch_id': isBac ? bacId : null,
                  };
                  try {
                    if (exam == null) {
                      await adminApi.post('/past-exams', body);
                    } else {
                      await adminApi.put('/past-exams/${exam['id']}', body);
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
      await adminApi.delete('/past-exams/$id');
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
      const AdminSidebar(currentRoute: '/past-exams'),
      Expanded(child: Column(children: [
        _PeBar(title: 'مواضيع الامتحانات السابقة', subtitle: adminScope.label, onAdd: () => _showForm()),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _buildList()),
      ])),
    ]),
  );

  Widget _buildList() {
    if (_exams.isEmpty) {
      return Center(child: Text('لا توجد مواضيع في ${adminScope.label}', style: const TextStyle(fontFamily: 'Cairo', color: AdminColors.textSecondary)));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: _exams.map<Widget>((e) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AdminColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border)),
          child: Row(children: [
            _CoverThumb(url: e['cover_image_url'], icon: Icons.history_edu_outlined),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e['title'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14, color: AdminColors.textPrimary)),
              Text('${e['subject_name'] ?? ''} — ${e['year'] ?? ''}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.textSecondary)),
            ])),
            IconButton(icon: const Icon(Icons.edit_outlined, color: AdminColors.primary), onPressed: () => _showForm(exam: Map<String, dynamic>.from(e))),
            IconButton(icon: const Icon(Icons.delete_outline, color: AdminColors.error), onPressed: () => _delete(e['id'] as int)),
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

class _PeTextField extends StatelessWidget {
  final TextEditingController c;
  final String label;
  const _PeTextField(this.c, this.label);
  @override
  Widget build(BuildContext context) => TextField(
    controller: c,
    decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(fontFamily: 'Cairo'), border: const OutlineInputBorder()),
    style: const TextStyle(fontFamily: 'Cairo'),
  );
}

class _PeBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onAdd;
  const _PeBar({required this.title, required this.subtitle, required this.onAdd});
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
