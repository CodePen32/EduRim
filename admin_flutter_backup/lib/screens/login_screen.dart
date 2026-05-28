import 'package:flutter/material.dart';
import '../core/admin_api.dart';
import '../core/app_colors.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await adminApi.post('/auth/login', {
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
      });
      await adminApi.saveToken(data['token']);
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AdminColors.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school_rounded, size: 48, color: AdminColors.primary),
              const SizedBox(height: 12),
              const Text('Edurim Admin', style: TextStyle(fontFamily: 'Cairo', fontSize: 24, fontWeight: FontWeight.bold, color: AdminColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('لوحة التحكم', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AdminColors.textSecondary)),
              const SizedBox(height: 32),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: AdminColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(_error!, style: const TextStyle(fontFamily: 'Cairo', color: AdminColors.error, fontSize: 13)),
                ),
              TextField(
                controller: _emailCtrl,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  labelStyle: TextStyle(fontFamily: 'Cairo'),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  labelStyle: TextStyle(fontFamily: 'Cairo'),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primary,
                    foregroundColor: AdminColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('تسجيل الدخول', style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
