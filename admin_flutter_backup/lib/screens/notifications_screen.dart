import 'package:flutter/material.dart';
import '../core/admin_api.dart';
import '../core/admin_scope.dart';
import '../core/app_colors.dart';
import '../widgets/admin_sidebar.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});
  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  List<dynamic> _notifications = [];
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
      final data = await adminApi.get('/notifications?${adminScope.queryParams}');
      if (mounted) setState(() { _notifications = data['notifications'] ?? []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  void _showForm() {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    String type = 'info';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
        title: Text('إشعار لـ ${adminScope.label}', style: const TextStyle(fontFamily: 'Cairo')),
        content: SizedBox(
          width: 450,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AdminColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.info_outline, color: AdminColors.primary, size: 16),
                const SizedBox(width: 8),
                Text('سيُرسَل لطلاب قسم: ${adminScope.label}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.primary)),
              ]),
            ),
            const SizedBox(height: 12),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'العنوان', labelStyle: TextStyle(fontFamily: 'Cairo'), border: OutlineInputBorder()), style: const TextStyle(fontFamily: 'Cairo')),
            const SizedBox(height: 12),
            TextField(controller: msgCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'الرسالة', labelStyle: TextStyle(fontFamily: 'Cairo'), border: OutlineInputBorder()), style: const TextStyle(fontFamily: 'Cairo')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: type,
              decoration: const InputDecoration(labelText: 'النوع', labelStyle: TextStyle(fontFamily: 'Cairo'), border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'info', child: Text('معلومة', style: TextStyle(fontFamily: 'Cairo'))),
                DropdownMenuItem(value: 'warning', child: Text('تحذير', style: TextStyle(fontFamily: 'Cairo'))),
                DropdownMenuItem(value: 'success', child: Text('نجاح', style: TextStyle(fontFamily: 'Cairo'))),
              ],
              onChanged: (v) => setS(() => type = v!),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              if (titleCtrl.text.isEmpty || msgCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              try {
                final body = <String, dynamic>{
                  'title': titleCtrl.text,
                  'message': msgCtrl.text,
                  'type': type,
                  'learning_path_id': adminScope.learningPathId,
                };
                if (adminScope.bacBranchId > 0) {
                  body['bac_branch_id'] = adminScope.bacBranchId;
                }
                await adminApi.post('/notifications', body);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الإشعار بنجاح', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AdminColors.success));
                  _load();
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString(), style: const TextStyle(fontFamily: 'Cairo'))));
              }
            },
            child: const Text('إرسال', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      )),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'warning': return AdminColors.warning;
      case 'success': return AdminColors.success;
      default: return AdminColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AdminColors.background,
    body: Row(children: [
      const AdminSidebar(currentRoute: '/notifications'),
      Expanded(child: Column(children: [
        Container(
          height: 64, padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(color: AdminColors.white, border: Border(bottom: BorderSide(color: AdminColors.border))),
          child: Row(children: [
            const Spacer(),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('الإشعارات', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AdminColors.textPrimary)),
              Text(adminScope.label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.textSecondary)),
            ]),
            const Spacer(),
            ElevatedButton.icon(onPressed: _showForm, icon: const Icon(Icons.send_outlined, size: 18), label: const Text('إشعار جديد', style: TextStyle(fontFamily: 'Cairo')), style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white)),
          ]),
        ),
        Expanded(child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? Center(child: Text('لا توجد إشعارات في ${adminScope.label}', style: const TextStyle(fontFamily: 'Cairo', color: AdminColors.textSecondary)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(children: _notifications.map<Widget>((n) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AdminColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border)),
                      child: Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: _typeColor(n['type'] ?? 'info').withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.notifications_outlined, color: _typeColor(n['type'] ?? 'info'), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(n['title'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14, color: AdminColors.textPrimary)),
                          Text(n['message'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ])),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: (n['user_id'] == null ? AdminColors.warning : AdminColors.primary).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(n['user_id'] == null ? 'عام' : 'شخصي', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: n['user_id'] == null ? AdminColors.warning : AdminColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ]),
                    )).toList()),
                  )),
      ])),
    ]),
  );
}
