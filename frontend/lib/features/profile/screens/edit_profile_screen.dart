import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isLoading = false;
  bool _loadingUser = true;
  String _levelLabel = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await authService.me();
      if (mounted) {
        _nameController.text = user.fullName;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _cityController.text = user.city;
        setState(() {
          _levelLabel = _buildLevelLabel(user);
          _loadingUser = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingUser = false);
    }
  }

  String _buildLevelLabel(UserModel user) {
    final lpId = user.learningPathId;
    if (lpId == null) return 'غير محدد';
    switch (lpId) {
      case 1: return 'Concours';
      case 2: return 'BEPC';
      case 3:
        final bacId = user.bacBranchId;
        if (bacId == 1) return 'Bac C';
        if (bacId == 2) return 'Bac D';
        return 'Bac';
      default: return 'غير معروف';
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      // Note: phone and learning path are intentionally NOT sent — they are
      // fixed after registration (also enforced on the backend).
      await apiClient.put('/auth/profile', {
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'city': _cityController.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم حفظ التغييرات بنجاح', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message, style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تعذر حفظ التغييرات', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'تعديل الملف الشخصي'),
      body: _loadingUser
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: const Center(child: Icon(Icons.person, size: 48, color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_outline)),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailController,
                    textDirection: TextDirection.ltr,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email_outlined)),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'المدينة', prefixIcon: Icon(Icons.location_city_outlined)),
                  ),
                  const SizedBox(height: 24),

                  // رقم الهاتف — للعرض فقط، ثابت بعد التسجيل ولا يمكن تعديله
                  _ReadOnlyField(
                    icon: Icons.phone_outlined,
                    label: 'رقم الهاتف',
                    value: _phoneController.text.isEmpty ? 'غير محدد' : _phoneController.text,
                    ltrValue: true,
                  ),
                  const SizedBox(height: 12),

                  // المستوى الدراسي — للعرض فقط، لا يمكن تعديله
                  _ReadOnlyField(
                    icon: Icons.school_outlined,
                    label: 'المستوى الدراسي',
                    value: _levelLabel,
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(label: 'حفظ التغييرات', isLoading: _isLoading, onPressed: _save),
                ],
              ),
            ),
    );
  }
}

/// Read-only profile info (phone, learning level) — shown but never editable;
/// the lock icon signals it is fixed after registration.
class _ReadOnlyField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool ltrValue;

  const _ReadOnlyField({
    required this.icon,
    required this.label,
    required this.value,
    this.ltrValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  value,
                  textDirection: ltrValue ? TextDirection.ltr : null,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.lock_outline, color: AppColors.textLight, size: 18),
        ],
      ),
    );
  }
}
