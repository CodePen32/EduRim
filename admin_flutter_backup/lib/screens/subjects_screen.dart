import 'package:flutter/material.dart';
import '../core/admin_api.dart';
import '../core/admin_scope.dart';
import '../core/app_colors.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/file_upload_field.dart';

class AdminSubjectsScreen extends StatefulWidget {
  const AdminSubjectsScreen({super.key});
  @override
  State<AdminSubjectsScreen> createState() => _AdminSubjectsScreenState();
}

class _AdminSubjectsScreenState extends State<AdminSubjectsScreen> {
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
      final data = await adminApi.get('/subjects?${adminScope.queryParams}');
      if (mounted) setState(() { _subjects = data['subjects'] ?? []; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showForm({Map<String, dynamic>? subject}) {
    final nameCtrl = TextEditingController(text: subject?['name_ar'] ?? '');
    final colorCtrl = TextEditingController(text: subject?['color'] ?? '#2563EB');
    String coverUrl = subject?['cover_image_url'] ?? '';

    // القيم من الـ scope الحالي
    final lpId = adminScope.learningPathId;
    int? bacId = adminScope.bacBranchId > 0 ? adminScope.bacBranchId : null;
    // عند التعديل نأخذ من الـ subject
    if (subject != null) {
      final rawBac = (subject['bac_branch_id'] as num?)?.toInt() ?? 0;
      bacId = rawBac > 0 ? rawBac : null;
    }

    final isBac = lpId == AdminScope.bacPathId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(subject == null ? 'إضافة مادة إلى: ${adminScope.label}' : 'تعديل مادة', style: const TextStyle(fontFamily: 'Cairo')),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AdminColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      const Icon(Icons.info_outline, color: AdminColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Text('المسار: ${adminScope.label}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AdminColors.primary)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  _Field(ctrl: nameCtrl, label: 'اسم المادة *'),
                  const SizedBox(height: 12),
                  _Field(ctrl: colorCtrl, label: 'اللون (#hex)'),
                  const SizedBox(height: 12),
                  FileUploadField(
                    label: 'صورة الغلاف',
                    uploadType: UploadType.image,
                    uploadCategory: 'covers',
                    initialUrl: coverUrl,
                    onUploaded: (url) => setS(() => coverUrl = url),
                  ),
                  if (isBac) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: bacId,
                      decoration: const InputDecoration(labelText: 'الشعبة *', labelStyle: TextStyle(fontFamily: 'Cairo'), border: OutlineInputBorder()),
                      hint: const Text('اختر الشعبة', style: TextStyle(fontFamily: 'Cairo')),
                      items: _bacBranches.map((b) => DropdownMenuItem<int>(
                        value: b['id'] as int,
                        child: Text(b['name'] as String, style: const TextStyle(fontFamily: 'Cairo')),
                      )).toList(),
                      onChanged: (v) => setS(() => bacId = v),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اسم المادة مطلوب', style: TextStyle(fontFamily: 'Cairo'))));
                  return;
                }
                if (isBac && bacId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يجب اختيار الشعبة', style: TextStyle(fontFamily: 'Cairo'))));
                  return;
                }
                Navigator.pop(ctx);
                try {
                  final body = <String, dynamic>{
                    'name_ar': nameCtrl.text.trim(),
                    'color': colorCtrl.text.trim(),
                    'learning_path_id': lpId,
                    'cover_image_url': coverUrl,
                    if (isBac && bacId != null) 'bac_branch_id': bacId,
                  };
                  if (subject == null) {
                    await adminApi.post('/subjects', body);
                  } else {
                    await adminApi.put('/subjects/${subject['id']}', body);
                  }
                  _load();
                } catch (e) {
                  if (mounted) {
                    final msg = e.toString().replaceFirst('Exception: ', '');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل: $msg', style: const TextStyle(fontFamily: 'Cairo'))));
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

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('تأكيد الحذف', style: TextStyle(fontFamily: 'Cairo')),
      content: const Text('هل تريد حذف هذه المادة؟', style: TextStyle(fontFamily: 'Cairo')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AdminColors.error), onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: Colors.white))),
      ],
    ));
    if (confirm == true) {
      try {
        await adminApi.delete('/subjects/$id');
        _load();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/subjects'),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _buildList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(color: AdminColors.white, border: Border(bottom: BorderSide(color: AdminColors.border))),
      child: Row(
        children: [
          const Spacer(),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('المواد الدراسية', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AdminColors.textPrimary)),
            Text(adminScope.label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.textSecondary)),
          ]),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showForm(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('إضافة مادة', style: TextStyle(fontFamily: 'Cairo')),
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_subjects.isEmpty) {
      return Center(child: Text('لا توجد مواد في ${adminScope.label}', style: const TextStyle(fontFamily: 'Cairo', color: AdminColors.textSecondary)));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: _subjects.map<Widget>((s) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AdminColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border)),
          child: Row(
            children: [
              _CoverThumb(url: s['cover_image_url'], icon: Icons.menu_book_outlined),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s['name_ar'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15, color: AdminColors.textPrimary)),
                Text(s['learning_path_name'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.textSecondary)),
              ])),
              IconButton(icon: const Icon(Icons.edit_outlined, color: AdminColors.primary), onPressed: () => _showForm(subject: Map<String, dynamic>.from(s))),
              IconButton(icon: const Icon(Icons.delete_outline, color: AdminColors.error), onPressed: () => _delete(s['id'])),
            ],
          ),
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
      width: 44, height: 44,
      decoration: BoxDecoration(color: AdminColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: urlStr.isNotEmpty
          ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(fullUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => Icon(icon, color: AdminColors.primary, size: 22)))
          : Icon(icon, color: AdminColors.primary, size: 22),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  const _Field({required this.ctrl, required this.label});
  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(fontFamily: 'Cairo'), border: const OutlineInputBorder()),
    style: const TextStyle(fontFamily: 'Cairo'),
  );
}
