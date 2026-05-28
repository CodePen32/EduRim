import 'package:flutter/material.dart';
import '../core/admin_api.dart';
import '../core/admin_scope.dart';
import '../core/app_colors.dart';
import '../widgets/admin_sidebar.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<dynamic> _users = [];
  bool _loading = true;
  int _total = 0;
  final _searchCtrl = TextEditingController();
  int _filterPath = 0;
  int _filterActive = -1; // -1=all, 1=active, 0=inactive

  @override
  void initState() {
    super.initState();
    adminScope.addListener(_onScopeChange);
    _load();
  }

  @override
  void dispose() {
    adminScope.removeListener(_onScopeChange);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScopeChange() => _load();

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      String path = '/users?limit=100&offset=0&${adminScope.queryParams}';
      if (_searchCtrl.text.isNotEmpty) path += '&search=${Uri.encodeComponent(_searchCtrl.text)}';
      if (_filterPath > 0) path += '&learning_path_id=$_filterPath';
      if (_filterActive >= 0) path += '&is_active=$_filterActive';
      final data = await adminApi.get(path);
      if (mounted) {
        setState(() {
          _users = data['users'] ?? [];
          _total = data['total'] ?? 0;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleActive(int id, bool current) async {
    try {
      final data = await adminApi.patch('/users/$id/toggle-active', {});
      if (mounted) {
        final msg = data['message'] as String? ?? '';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: !current ? AdminColors.success : AdminColors.error,
          behavior: SnackBarBehavior.floating,
        ));
        _load();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showDetails(Map<String, dynamic> user) async {
    showDialog(context: context, builder: (ctx) => _UserDetailDialog(userId: user['id'], onEdit: () { Navigator.pop(ctx); _showEditForm(user); }));
  }

  void _showEditForm(Map<String, dynamic> user) {
    final nameCtrl = TextEditingController(text: user['full_name'] ?? '');
    final emailCtrl = TextEditingController(text: user['email'] ?? '');
    final phoneCtrl = TextEditingController(text: user['phone'] ?? '');
    final cityCtrl = TextEditingController(text: user['city'] ?? '');
    final genderRaw = user['gender'] as String? ?? '';
    String gender = ['ذكر', 'أنثى'].contains(genderRaw) ? genderRaw : 'ذكر';
    final lpRaw = (user['learning_path_id'] as num?)?.toInt() ?? 0;
    int lpID = [0, 1, 2, 3].contains(lpRaw) ? lpRaw : 0;
    final bacRaw = (user['bac_branch_id'] as num?)?.toInt();
    int? bacID = [1, 2, 3, 4].contains(bacRaw) ? bacRaw : null;
    bool isActive = user['is_active'] ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
        title: Text('تعديل: ${user['full_name']}', style: const TextStyle(fontFamily: 'Cairo')),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            _TF(nameCtrl, 'الاسم الكامل'),
            const SizedBox(height: 10),
            _TF(emailCtrl, 'البريد الإلكتروني'),
            const SizedBox(height: 10),
            _TF(phoneCtrl, 'رقم الهاتف'),
            const SizedBox(height: 10),
            _TF(cityCtrl, 'المدينة'),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: gender,
              decoration: const InputDecoration(labelText: 'الجنس', labelStyle: TextStyle(fontFamily: 'Cairo'), border: OutlineInputBorder()),
              items: ['ذكر', 'أنثى'].map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
              onChanged: (v) => setS(() => gender = v!),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              initialValue: lpID,
              decoration: const InputDecoration(labelText: 'المسار الدراسي', labelStyle: TextStyle(fontFamily: 'Cairo'), border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 0, child: Text('غير محدد', style: TextStyle(fontFamily: 'Cairo'))),
                DropdownMenuItem(value: 1, child: Text('كونكور', style: TextStyle(fontFamily: 'Cairo'))),
                DropdownMenuItem(value: 2, child: Text('BEPC', style: TextStyle(fontFamily: 'Cairo'))),
                DropdownMenuItem(value: 3, child: Text('باكالوريا', style: TextStyle(fontFamily: 'Cairo'))),
              ],
              onChanged: (v) => setS(() { lpID = v!; if (v != 3) bacID = null; }),
            ),
            if (lpID == 3) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<int?>(
                initialValue: bacID,
                decoration: const InputDecoration(labelText: 'الشعبة', labelStyle: TextStyle(fontFamily: 'Cairo'), border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: null, child: Text('غير محددة', style: TextStyle(fontFamily: 'Cairo'))),
                  DropdownMenuItem(value: 1, child: Text('رياضيات', style: TextStyle(fontFamily: 'Cairo'))),
                  DropdownMenuItem(value: 2, child: Text('علوم طبيعية', style: TextStyle(fontFamily: 'Cairo'))),
                  DropdownMenuItem(value: 3, child: Text('آداب عصرية', style: TextStyle(fontFamily: 'Cairo'))),
                  DropdownMenuItem(value: 4, child: Text('آداب أصلية', style: TextStyle(fontFamily: 'Cairo'))),
                ],
                onChanged: (v) => setS(() => bacID = v),
              ),
            ],
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive ? AdminColors.success.withValues(alpha: 0.08) : AdminColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isActive ? AdminColors.success : AdminColors.error),
              ),
              child: Row(children: [
                Switch(value: isActive, onChanged: (v) => setS(() => isActive = v), activeTrackColor: AdminColors.success.withValues(alpha: 0.5), activeThumbColor: AdminColors.success),
                const SizedBox(width: 8),
                Text(isActive ? 'الحساب نشط' : 'الحساب معطّل', style: TextStyle(fontFamily: 'Cairo', color: isActive ? AdminColors.success : AdminColors.error, fontWeight: FontWeight.bold)),
              ]),
            ),
          ])),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final body = <String, dynamic>{
                'full_name': nameCtrl.text,
                'email': emailCtrl.text,
                'phone': phoneCtrl.text,
                'city': cityCtrl.text,
                'gender': gender,
                'is_active': isActive,
                if (lpID > 0) 'learning_path_id': lpID,
                'bac_branch_id': bacID,
              };
              try {
                await adminApi.put('/users/${user['id']}', body);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم التعديل بنجاح ✓', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AdminColors.success));
                  _load();
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      )),
    );
  }

  Color _pathColor(int? id) {
    switch (id) {
      case 1: return const Color(0xFF7C3AED);
      case 2: return AdminColors.primary;
      case 3: return AdminColors.success;
      default: return AdminColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/users'),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                _buildFilters(),
                Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _buildTable()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(color: AdminColors.white, border: Border(bottom: BorderSide(color: AdminColors.border))),
      child: Row(children: [
        const Spacer(),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('الطلاب', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AdminColors.textPrimary)),
          Text('${adminScope.label} — إجمالي: $_total طالب', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.textSecondary)),
        ]),
        const Spacer(),
        SizedBox(
          width: 240,
          child: TextField(
            controller: _searchCtrl,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'بحث بالاسم أو البريد أو الهاتف...',
              hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, size: 16), onPressed: () { _searchCtrl.clear(); _load(); })
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            onSubmitted: (_) => _load(),
            onChanged: (v) { if (v.isEmpty) _load(); },
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('تحديث', style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
          style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white),
        ),
      ]),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: const BoxDecoration(color: AdminColors.white, border: Border(bottom: BorderSide(color: AdminColors.border))),
      child: Row(children: [
        const Text('فلترة:', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AdminColors.textSecondary)),
        const SizedBox(width: 16),
        _FilterChip(label: 'الكل', selected: _filterPath == 0, onTap: () => setState(() { _filterPath = 0; _load(); })),
        const SizedBox(width: 8),
        _FilterChip(label: 'كونكور', selected: _filterPath == 1, color: const Color(0xFF7C3AED), onTap: () => setState(() { _filterPath = 1; _load(); })),
        const SizedBox(width: 8),
        _FilterChip(label: 'BEPC', selected: _filterPath == 2, color: AdminColors.primary, onTap: () => setState(() { _filterPath = 2; _load(); })),
        const SizedBox(width: 8),
        _FilterChip(label: 'BAC', selected: _filterPath == 3, color: AdminColors.success, onTap: () => setState(() { _filterPath = 3; _load(); })),
        const SizedBox(width: 24),
        const Text('|', style: TextStyle(color: AdminColors.border)),
        const SizedBox(width: 24),
        _FilterChip(label: 'الكل', selected: _filterActive == -1, onTap: () => setState(() { _filterActive = -1; _load(); })),
        const SizedBox(width: 8),
        _FilterChip(label: 'نشط', selected: _filterActive == 1, color: AdminColors.success, onTap: () => setState(() { _filterActive = 1; _load(); })),
        const SizedBox(width: 8),
        _FilterChip(label: 'معطّل', selected: _filterActive == 0, color: AdminColors.error, onTap: () => setState(() { _filterActive = 0; _load(); })),
      ]),
    );
  }

  Widget _buildTable() {
    if (_users.isEmpty) {
      return const Center(child: Text('لا يوجد طلاب', style: TextStyle(fontFamily: 'Cairo', color: AdminColors.textSecondary, fontSize: 16)));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: _users.map<Widget>((u) {
          final isActive = u['is_active'] == true;
          final lpID = u['learning_path_id'] as int?;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AdminColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isActive ? AdminColors.border : AdminColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              // Avatar
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _pathColor(lpID).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(child: Text(
                  (u['full_name'] as String? ?? '?').isNotEmpty ? (u['full_name'] as String)[0] : '?',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: _pathColor(lpID)),
                )),
              ),
              const SizedBox(width: 12),
              // Name + email
              Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(u['full_name'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14, color: AdminColors.textPrimary)),
                Text(u['email'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.textSecondary)),
              ])),
              // Phone
              Expanded(flex: 2, child: Text(u['phone'] ?? '—', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AdminColors.textSecondary), textDirection: TextDirection.ltr)),
              // Path
              Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (u['learning_path_name'] != null && (u['learning_path_name'] as String).isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: _pathColor(lpID).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(u['learning_path_name'] as String, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: _pathColor(lpID), fontWeight: FontWeight.bold)),
                  )
                else
                  const Text('—', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.textSecondary)),
                if (u['bac_branch_name'] != null && (u['bac_branch_name'] as String).isNotEmpty)
                  Text(u['bac_branch_name'] as String, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AdminColors.textSecondary)),
              ])),
              // City
              Expanded(flex: 2, child: Text(u['city'] ?? '—', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AdminColors.textSecondary))),
              // Date
              Expanded(flex: 2, child: Text(u['created_at'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AdminColors.textSecondary), textDirection: TextDirection.ltr)),
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? AdminColors.success.withValues(alpha: 0.1) : AdminColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(isActive ? 'نشط' : 'معطّل', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? AdminColors.success : AdminColors.error)),
              ),
              const SizedBox(width: 12),
              // Actions
              IconButton(icon: const Icon(Icons.visibility_outlined, color: AdminColors.primary, size: 20), tooltip: 'عرض', onPressed: () => _showDetails(Map<String,dynamic>.from(u))),
              IconButton(icon: const Icon(Icons.edit_outlined, color: AdminColors.warning, size: 20), tooltip: 'تعديل', onPressed: () => _showEditForm(Map<String,dynamic>.from(u))),
              IconButton(
                icon: Icon(isActive ? Icons.block : Icons.check_circle_outline, color: isActive ? AdminColors.error : AdminColors.success, size: 20),
                tooltip: isActive ? 'تعطيل' : 'تفعيل',
                onPressed: () => _toggleActive(u['id'], isActive),
              ),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

// ---- User Detail Dialog ----
class _UserDetailDialog extends StatefulWidget {
  final int userId;
  final VoidCallback onEdit;
  const _UserDetailDialog({required this.userId, required this.onEdit});
  @override
  State<_UserDetailDialog> createState() => _UserDetailDialogState();
}

class _UserDetailDialogState extends State<_UserDetailDialog> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await adminApi.get('/users/${widget.userId}');
      if (mounted) setState(() { _user = data['user']; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_user?['full_name'] ?? 'تفاصيل الطالب', style: const TextStyle(fontFamily: 'Cairo')),
      content: SizedBox(
        width: 420,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _user == null
                ? const Text('تعذر تحميل البيانات', style: TextStyle(fontFamily: 'Cairo'))
                : Column(mainAxisSize: MainAxisSize.min, children: [
                    _DetailRow(label: 'البريد', value: _user!['email'] ?? ''),
                    _DetailRow(label: 'الهاتف', value: _user!['phone'] ?? ''),
                    _DetailRow(label: 'المدينة', value: _user!['city'] ?? ''),
                    _DetailRow(label: 'المسار', value: _user!['learning_path_name'] ?? '—'),
                    if ((_user!['bac_branch_name'] as String? ?? '').isNotEmpty)
                      _DetailRow(label: 'الشعبة', value: _user!['bac_branch_name'] as String),
                    _DetailRow(label: 'تاريخ التسجيل', value: _user!['created_at'] ?? ''),
                    const Divider(height: 24),
                    const Text('إحصائيات التعلم', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(children: [
                      _StatBox(label: 'الدروس المكتملة', value: '${_user!['completed_lessons'] ?? 0}', color: AdminColors.success),
                      const SizedBox(width: 12),
                      _StatBox(label: 'متوسط التقدم', value: '${((_user!['average_progress'] as num?)?.toStringAsFixed(1)) ?? '0'}%', color: AdminColors.primary),
                    ]),
                    if ((_user!['last_lesson_title'] as String? ?? '').isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AdminColors.background, borderRadius: BorderRadius.circular(8)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('آخر درس:', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.textSecondary)),
                          Text(_user!['last_lesson_title'] as String, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                        ]),
                      ),
                    ],
                  ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق', style: TextStyle(fontFamily: 'Cairo'))),
        ElevatedButton.icon(
          onPressed: widget.onEdit,
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('تعديل', style: TextStyle(fontFamily: 'Cairo')),
          style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 110, child: Text('$label:', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AdminColors.textSecondary))),
      Expanded(child: Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: AdminColors.textPrimary))),
    ]),
  );
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.2))),
    child: Column(children: [
      Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AdminColors.textSecondary), textAlign: TextAlign.center),
    ]),
  ));
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, this.color = AdminColors.primary, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? color : AdminColors.border),
      ),
      child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? color : AdminColors.textSecondary)),
    ),
  );
}

class _TF extends StatelessWidget {
  final TextEditingController c;
  final String l;
  const _TF(this.c, this.l);
  @override
  Widget build(BuildContext context) => TextField(controller: c, decoration: InputDecoration(labelText: l, labelStyle: const TextStyle(fontFamily: 'Cairo'), border: const OutlineInputBorder()), style: const TextStyle(fontFamily: 'Cairo'));
}
