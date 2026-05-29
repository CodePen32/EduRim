import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String _selectedGender = 'ذكر';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await authService.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        gender: _selectedGender,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.selectLearningPath);
    } on ApiException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'تعذر الاتصال بالخادم، تحقق من الإنترنت');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'إنشاء حساب',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // ── Logo + tagline ──
                      Image.asset(
                        'assets/images/logo_edurim.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'مرحباً بك في EduRim',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'أنشئ حسابك للوصول إلى الدروس والتمارين',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFF64748B)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // ── Error banner ──
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFFDC2626)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── Form Card ──
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4)),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section: المعلومات الشخصية
                            _SectionLabel(label: 'المعلومات الشخصية'),
                            const SizedBox(height: 14),
                            _AppField(
                              controller: _nameController,
                              label: 'الاسم الكامل',
                              icon: Icons.person_outline_rounded,
                              validator: (v) => v!.trim().isEmpty ? 'أدخل اسمك الكامل' : null,
                            ),
                            const SizedBox(height: 12),
                            _AppField(
                              controller: _emailController,
                              label: 'البريد الإلكتروني',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textDirection: TextDirection.ltr,
                              validator: (v) {
                                if (v!.trim().isEmpty) return 'أدخل البريد الإلكتروني';
                                if (!v.contains('@') || !v.contains('.')) return 'بريد إلكتروني غير صحيح';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _AppField(
                              controller: _phoneController,
                              label: 'رقم الهاتف',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              textDirection: TextDirection.ltr,
                              validator: (v) => v!.trim().isEmpty ? 'أدخل رقم الهاتف' : null,
                            ),
                            const SizedBox(height: 16),

                            // Gender segmented
                            const Text('الجنس', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                            const SizedBox(height: 8),
                            _GenderSelector(
                              value: _selectedGender,
                              onChanged: (v) => setState(() => _selectedGender = v),
                            ),
                            const SizedBox(height: 20),

                            // Section: كلمة المرور
                            _SectionLabel(label: 'كلمة المرور'),
                            const SizedBox(height: 14),
                            _AppField(
                              controller: _passwordController,
                              label: 'كلمة المرور',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: const Color(0xFF94A3B8),
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (v) => (v?.length ?? 0) < 6 ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل' : null,
                            ),
                            const SizedBox(height: 12),
                            _AppField(
                              controller: _confirmController,
                              label: 'تأكيد كلمة المرور',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscureConfirm,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: const Color(0xFF94A3B8),
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                              validator: (v) {
                                if (v!.isEmpty) return 'أكد كلمة المرور';
                                if (v != _passwordController.text) return 'كلمتا المرور غير متطابقتين';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Submit button ──
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: _isLoading
                                ? null
                                : const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1E88E5)]),
                            color: _isLoading ? const Color(0xFFCFD8EC) : null,
                            boxShadow: _isLoading
                                ? []
                                : [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.transparent,
                              disabledForegroundColor: Colors.white54,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : const Text('إنشاء الحساب', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Login link ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('لديك حساب بالفعل؟', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFF64748B))),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
                            child: const Text('تسجيل الدخول', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section label ──
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 16, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }
}

// ── Reusable text field ──
class _AppField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextDirection? textDirection;

  const _AppField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textDirection: textDirection,
      validator: validator,
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFF94A3B8)),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        errorStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11),
      ),
    );
  }
}

// ── Gender segmented selector ──
class _GenderSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _GenderSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['ذكر', 'أنثى'].map((g) {
        final sel = value == g;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(g),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(left: g == 'ذكر' ? 6 : 0, right: g == 'أنثى' ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel ? AppColors.primary : const Color(0xFFE2E8F0),
                  width: sel ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    g == 'ذكر' ? Icons.male_rounded : Icons.female_rounded,
                    size: 18,
                    color: sel ? AppColors.primary : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    g,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      color: sel ? AppColors.primary : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
