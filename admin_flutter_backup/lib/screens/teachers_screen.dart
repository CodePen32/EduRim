import 'package:flutter/material.dart';
import '../core/admin_api.dart';
import '../core/admin_scope.dart';
import '../core/app_colors.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/file_upload_field.dart';

class AdminTeachersScreen extends StatefulWidget {
  const AdminTeachersScreen({super.key});
  @override
  State<AdminTeachersScreen> createState() => _AdminTeachersScreenState();
}

class _AdminTeachersScreenState extends State<AdminTeachersScreen> {
  List<dynamic> _teachers = [];
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
        adminApi.get('/teachers?${adminScope.queryParams}'),
        adminApi.get('/subjects?${adminScope.queryParams}'),
      ]);
      if (mounted) {
        setState(() {
          _teachers = results[0]['teachers'] ?? [];
          _subjects = results[1]['subjects'] ?? [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showForm({Map<String, dynamic>? teacher}) {
    final nameCtrl = TextEditingController(text: teacher?['full_name'] ?? '');
    final bioCtrl = TextEditingController(text: teacher?['bio'] ?? '');
    String avatarUrl = teacher?['avatar_url'] ?? '';

    final rawSubj = teacher?['subject_id'];
    int? selectedSubjectId = (rawSubj is int && rawSubj > 0) ? rawSubj : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
        title: Text(teacher == null ? 'إضافة أستاذ' : 'تعديل أستاذ', style: const TextStyle(fontFamily: 'Cairo')),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
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
            _TF(nameCtrl, 'الاسم الكامل *'),
            const SizedBox(height: 10),
            _TF(bioCtrl, 'نبذة تعريفية'),
            const SizedBox(height: 10),
            _subjects.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(8)),
                    child: const Text('لا توجد مواد لهذا المسار', style: TextStyle(fontFamily: 'Cairo', color: Colors.orange)),
                  )
                : DropdownButtonFormField<int?>(
                    value: _subjects.any((s) => s['id'] == selectedSubjectId) ? selectedSubjectId : null,
                    decoration: const InputDecoration(labelText: 'المادة (اختياري)', labelStyle: TextStyle(fontFamily: 'Cairo'), border: OutlineInputBorder()),
                    hint: const Text('بدون مادة', style: TextStyle(fontFamily: 'Cairo')),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('بدون مادة', style: TextStyle(fontFamily: 'Cairo'))),
                      ..._subjects.map<DropdownMenuItem<int?>>((s) => DropdownMenuItem<int?>(
                        value: s['id'] as int,
                        child: Text(s['name_ar'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                      )),
                    ],
                    onChanged: (v) => setS(() => selectedSubjectId = v),
                  ),
            const SizedBox(height: 10),
            FileUploadField(
              label: 'صورة الأستاذ',
              uploadType: UploadType.image,
              uploadCategory: 'covers',
              initialUrl: avatarUrl,
              onUploaded: (url) => setS(() => avatarUrl = url),
            ),
          ])),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اسم الأستاذ مطلوب', style: TextStyle(fontFamily: 'Cairo'))));
                return;
              }
              Navigator.pop(ctx);
              final body = <String, dynamic>{
                'full_name': nameCtrl.text.trim(),
                'bio': bioCtrl.text.trim(),
                'subject_id': selectedSubjectId ?? 0,
                'avatar_url': avatarUrl,
              };
              try {
                if (teacher == null) {
                  await adminApi.post('/teachers', body);
                } else {
                  await adminApi.put('/teachers/${teacher['id']}', body);
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
      )),
    );
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('تأكيد الحذف', style: TextStyle(fontFamily: 'Cairo')),
      content: const Text('هل تريد حذف هذا الأستاذ؟', style: TextStyle(fontFamily: 'Cairo')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AdminColors.error), onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: Colors.white))),
      ],
    ));
    if (confirm == true) {
      try {
        await adminApi.delete('/teachers/$id');
        _load();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AdminColors.background,
    body: Row(children: [
      const AdminSidebar(currentRoute: '/teachers'),
      Expanded(child: Column(children: [
        Container(
          height: 64, padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(color: AdminColors.white, border: Border(bottom: BorderSide(color: AdminColors.border))),
          child: Row(children: [
            const Spacer(),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('الأساتذة', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AdminColors.textPrimary)),
              Text(adminScope.label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.textSecondary)),
            ]),
            const Spacer(),
            ElevatedButton.icon(onPressed: () => _showForm(), icon: const Icon(Icons.add, size: 18), label: const Text('إضافة أستاذ', style: TextStyle(fontFamily: 'Cairo')), style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white)),
          ]),
        ),
        Expanded(child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _teachers.isEmpty
                ? Center(child: Text('لا يوجد أساتذة في ${adminScope.label}', style: const TextStyle(fontFamily: 'Cairo', color: AdminColors.textSecondary)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(children: _teachers.map<Widget>((t) {
                      final avatarUrl = t['avatar_url'] as String? ?? '';
                      final fullAvatarUrl = avatarUrl.startsWith('/') ? 'http://localhost:8081$avatarUrl' : avatarUrl;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AdminColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border)),
                        child: Row(children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(fullAvatarUrl) : null,
                            backgroundColor: AdminColors.primary.withValues(alpha: 0.15),
                            child: avatarUrl.isEmpty ? const Icon(Icons.person_outline, color: AdminColors.primary, size: 22) : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(t['full_name'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14, color: AdminColors.textPrimary)),
                            Text(t['subject_name'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.textSecondary)),
                          ])),
                          IconButton(icon: const Icon(Icons.edit_outlined, color: AdminColors.primary), onPressed: () => _showForm(teacher: Map<String, dynamic>.from(t))),
                          IconButton(icon: const Icon(Icons.delete_outline, color: AdminColors.error), onPressed: () => _delete(t['id'])),
                        ]),
                      );
                    }).toList()),
                  )),
      ])),
    ]),
  );
}

class _TF extends StatelessWidget {
  final TextEditingController c;
  final String l;
  const _TF(this.c, this.l);
  @override
  Widget build(BuildContext context) => TextField(
    controller: c,
    decoration: InputDecoration(labelText: l, labelStyle: const TextStyle(fontFamily: 'Cairo'), border: const OutlineInputBorder()),
    style: const TextStyle(fontFamily: 'Cairo'),
  );
}
