import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/suggestion_service.dart';
import '../widgets/info_widgets.dart';

class SuggestFeatureScreen extends StatefulWidget {
  const SuggestFeatureScreen({super.key});

  @override
  State<SuggestFeatureScreen> createState() => _SuggestFeatureScreenState();
}

class _SuggestFeatureScreenState extends State<SuggestFeatureScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _sent = false;
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    // Local validation (mirrors backend rules).
    if (title.length < 3) { _snack('العنوان يجب أن لا يقل عن 3 أحرف'); return; }
    if (desc.length < 10) { _snack('الوصف يجب أن لا يقل عن 10 أحرف'); return; }

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      await suggestionService.submit(title: title, description: desc);
      if (!mounted) return;
      setState(() { _sent = true; _submitting = false; });
      _titleCtrl.clear();
      _descCtrl.clear();
      _snack('تم إرسال اقتراحك بنجاح');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      if (e.statusCode == 401) {
        // Session expired / not logged in — follow the app's auth flow.
        await authService.clearToken();
        if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }
      _snack(e.message.isNotEmpty ? e.message : 'تعذر إرسال الاقتراح');
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _snack('تعذر إرسال الاقتراح. تحقق من اتصالك وحاول مجدداً.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InfoScaffold(
      appBarTitle: 'اقترح تطوير',
      children: [
        const InfoHero(icon: Icons.lightbulb_rounded, title: 'اقترح تطوير', subtitle: 'رأيك يساعدنا على تحسين المنصة'),
        const SizedBox(height: 18),
        if (_sent)
          InfoCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text('تم استلام اقتراحك', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.success)),
                      SizedBox(height: 4),
                      Text('شكراً لك! سنأخذ اقتراحك بعين الاعتبار.', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.right),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
                ),
              ],
            ),
          ),
        if (_sent) const SizedBox(height: 14),
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const InfoSectionTitle(icon: Icons.title_rounded, title: 'عنوان الاقتراح'),
              const SizedBox(height: 8),
              _Field(controller: _titleCtrl, hint: 'مثال: إضافة وضع ليلي', maxLines: 1),
              const SizedBox(height: 16),
              const InfoSectionTitle(icon: Icons.notes_rounded, title: 'الوصف'),
              const SizedBox(height: 8),
              _Field(controller: _descCtrl, hint: 'اشرح فكرتك بالتفصيل...', maxLines: 4),
              const SizedBox(height: 18),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(_submitting ? 'جارٍ الإرسال...' : 'إرسال الاقتراح', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                    disabledForegroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _Field({required this.controller, required this.hint, required this.maxLines});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}
