import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/calculator_result.dart';
import '../../../core/models/calculator_subject.dart';
import '../../../core/network/api_client.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/calculator_service.dart';

class AverageCalculatorScreen extends StatefulWidget {
  final bool standalone;
  const AverageCalculatorScreen({super.key, this.standalone = true});

  @override
  State<AverageCalculatorScreen> createState() =>
      _AverageCalculatorScreenState();
}

class _AverageCalculatorScreenState extends State<AverageCalculatorScreen> {
  List<CalculatorSubject> _subjects = [];
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, String?> _fieldErrors = {};
  final Map<int, double?> _marks = {};
  bool _loading = true;
  bool _calculating = false;
  CalculatorResult? _result;
  String? _error;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) { c.dispose(); }
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    setState(() { _loading = true; _error = null; });
    debugPrint('[Calculator] token: ${apiClient.currentToken?.substring(0, 20) ?? "NULL"}');
    try {
      final subjects = await calculatorService.getSubjects();
      debugPrint('[Calculator] loaded ${subjects.length} subjects');
      if (!mounted) return;
      for (final s in subjects) {
        _controllers[s.subjectId] = TextEditingController();
        _marks[s.subjectId] = null;
        _fieldErrors[s.subjectId] = null;
      }
      setState(() { _subjects = subjects; _loading = false; });
    } catch (e) {
      debugPrint('[Calculator] ERROR type: ${e.runtimeType}');
      debugPrint('[Calculator] ERROR: $e');
      if (!mounted) return;
      final isAuth = e is ApiException && (e.statusCode == 401 || e.statusCode == 403);
      if (isAuth) {
        await authService.clearToken();
        if (mounted) {
          Navigator.of(context, rootNavigator: true)
              .pushReplacementNamed(AppRoutes.login);
        }
        return;
      }
      final isConn = e.toString().contains('SocketException') ||
          e.toString().contains('Connection') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('XMLHttpRequest');
      String msg;
      if (isConn) {
        msg = 'تعذر الاتصال بالخادم، تحقق من اتصالك';
      } else if (e is ApiException) {
        msg = e.message.isNotEmpty ? e.message : 'حدث خطأ أثناء تحميل الحاسبة';
      } else {
        // TypeError or other — show actual message for debugging
        final raw = e.toString();
        msg = raw.contains('type') && raw.contains('is not a subtype')
            ? 'خطأ في تحليل البيانات — تواصل مع الدعم'
            : 'حدث خطأ أثناء تحميل الحاسبة';
      }
      setState(() { _error = msg; _loading = false; });
    }
  }

  // Normalize Arabic/French comma to dot
  double? _parseValue(String v) {
    final normalized = v.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  void _onFieldChanged(CalculatorSubject s, String v) {
    final val = _parseValue(v);
    String? err;
    if (v.trim().isEmpty) {
      err = null;
    } else if (val == null) {
      err = 'قيمة غير صالحة';
    } else if (val < 0) {
      err = 'لا يمكن أن تكون سالبة';
    } else if (val > s.maxMark) {
      err = 'الحد الأقصى ${s.maxMark.toInt()}';
    }
    setState(() {
      _marks[s.subjectId] = (err == null && v.trim().isNotEmpty) ? val : null;
      _fieldErrors[s.subjectId] = err;
    });
  }

  Future<void> _calculate() async {
    // Validate all fields
    bool hasError = false;
    for (final s in _subjects) {
      final ctrl = _controllers[s.subjectId]!;
      if (ctrl.text.trim().isEmpty) {
        setState(() => _fieldErrors[s.subjectId] = 'أدخل النقطة');
        hasError = true;
      }
    }
    if (hasError) return;
    if (_fieldErrors.values.any((e) => e != null)) return;

    final filledMarks = _subjects
        .map((s) => {'subject_id': s.subjectId, 'mark': _marks[s.subjectId]!})
        .toList();

    setState(() { _calculating = true; _result = null; });
    try {
      final result = await calculatorService.calculate(filledMarks);
      if (!mounted) return;
      setState(() { _result = result; _calculating = false; });
      // Scroll to result
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      });
    } catch (_) {
      if (mounted) setState(() => _calculating = false);
    }
  }

  void _reset() {
    for (final c in _controllers.values) { c.clear(); }
    setState(() {
      for (final id in _marks.keys) { _marks[id] = null; }
      for (final id in _fieldErrors.keys) { _fieldErrors[id] = null; }
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: widget.standalone
            ? AppBar(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                title: const Text('الحاسبة',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18)),
              )
            : null,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return _buildError();
    }
    if (_subjects.isEmpty) {
      return _buildEmpty();
    }
    return _buildContent();
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), shape: BoxShape.circle),
              child: const Icon(Icons.wifi_off_rounded, size: 32, color: Color(0xFFDC2626)),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadSubjects,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: const Color(0xFFF0F4FF), shape: BoxShape.circle),
              child: const Icon(Icons.calculate_outlined, size: 36, color: Color(0xFF8A96B8)),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد مواد للحاسبة لهذا المستوى حالياً',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: Color(0xFF64748B), height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final isPoints = _subjects.first.calculationType == 'points';
    final learningPathId = _subjects.first.learningPathId;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!widget.standalone)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text('الحاسبة',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  ),

                // ── Result card (top when available) ──
                if (_result != null) ...[
                  _ResultCard(result: _result!),
                  const SizedBox(height: 16),
                ],

                // ── Info header card ──
                _InfoCard(isPoints: isPoints, learningPathId: learningPathId),
                const SizedBox(height: 20),

                // ── Section title ──
                Row(
                  children: [
                    Container(width: 3, height: 18,
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 8),
                    const Text('أدخل نقاطك', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const Spacer(),
                    if (_result != null || _marks.values.any((v) => v != null))
                      TextButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('مسح النقاط', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Subject cards ──
                ..._subjects.map((s) => _SubjectCard(
                  subject: s,
                  controller: _controllers[s.subjectId]!,
                  errorText: _fieldErrors[s.subjectId],
                  isPoints: isPoints,
                  onChanged: (v) => _onFieldChanged(s, v),
                )),

                const SizedBox(height: 20),

                // ── Calculate button ──
                _CalcButton(
                  calculating: _calculating,
                  onPressed: _calculate,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Info header card
// ─────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final bool isPoints;
  final int learningPathId;
  const _InfoCard({required this.isPoints, required this.learningPathId});

  String get _subtitle {
    if (isPoints) return 'أدخل نقاطك · حد النجاح 85 / 200';
    if (learningPathId == 2) return 'راسب < 7 · متجاوز 7–8.5 · ناجح ≥ 8.5';
    return 'راسب < 8 · استدراك 8–10 · ناجح ≥ 10';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.calculate_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isPoints ? 'نظام كونكور — النقاط / 200'
                      : learningPathId == 2 ? 'نظام BEPC — المعدل / 20'
                      : 'نظام BAC — المعدل / 20',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 3),
                Text(
                  _subtitle,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Color(0xFF64748B)),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Subject input card
// ─────────────────────────────────────────────
class _SubjectCard extends StatelessWidget {
  final CalculatorSubject subject;
  final TextEditingController controller;
  final String? errorText;
  final bool isPoints;
  final ValueChanged<String> onChanged;

  const _SubjectCard({
    required this.subject,
    required this.controller,
    required this.errorText,
    required this.isPoints,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final maxInt = subject.maxMark.toInt();
    final hasError = errorText != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: hasError ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Subject info
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (subject.isRequired) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('إجباري', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        subject.subjectName,
                        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          '/ $maxInt',
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    if (!isPoints) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'م ${subject.coefficient % 1 == 0 ? subject.coefficient.toInt() : subject.coefficient}',
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Color(0xFF7C3AED), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
                if (hasError) ...[
                  const SizedBox(height: 3),
                  Text(errorText!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Color(0xFFEF4444))),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Input
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Color(0xFFCBD5E1)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                filled: true,
                fillColor: hasError ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: hasError ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: hasError ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: hasError ? const Color(0xFFEF4444) : AppColors.primary, width: 1.5),
                ),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Result card
// ─────────────────────────────────────────────
class _ResultCard extends StatelessWidget {
  final CalculatorResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final outcome = result.outcome;

    // Colors per outcome
    final Color bg;
    final Color borderColor;
    final Color textColor;
    final IconData iconData;

    switch (outcome) {
      case CalculatorOutcome.passed:
        bg = const Color(0xFFECFDF5);
        borderColor = const Color(0xFF86EFAC);
        textColor = const Color(0xFF15803D);
        iconData = Icons.check_circle_rounded;
      case CalculatorOutcome.retake:
        bg = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFDE68A);
        textColor = const Color(0xFFB45309);
        iconData = Icons.pending_rounded;
      case CalculatorOutcome.promoted:
        bg = const Color(0xFFEFF6FF);
        borderColor = const Color(0xFFBADAFD);
        textColor = const Color(0xFF1D4ED8);
        iconData = Icons.trending_up_rounded;
      case CalculatorOutcome.failed:
        bg = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFECACA);
        textColor = const Color(0xFFDC2626);
        iconData = Icons.cancel_rounded;
    }

    final displayValue = result.isPoints
        ? '${result.totalPoints.toStringAsFixed(result.totalPoints % 1 == 0 ? 0 : 1)} / ${result.maxTotal.toInt()}'
        : '${result.average.toStringAsFixed(2)} / 20';

    final label = result.isPoints ? 'مجموع نقاطك' : 'معدلك';

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [BoxShadow(color: textColor.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(iconData, size: 40, color: textColor),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: textColor.withValues(alpha: 0.8))),
          const SizedBox(height: 4),
          // LTR to prevent RTL from reversing "12.02 / 20" to "20 / 12.02"
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              displayValue,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 38, fontWeight: FontWeight.bold, color: textColor, height: 1.1),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result.status,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.message,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: textColor.withValues(alpha: 0.85)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            result.isPoints
                ? 'المجموع الكلي: ${result.maxTotal.toInt()} نقطة'
                : 'مجموع المعاملات: ${result.totalCoefficients.toStringAsFixed(0)}',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: textColor.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Calculate button
// ─────────────────────────────────────────────
class _CalcButton extends StatelessWidget {
  final bool calculating;
  final VoidCallback onPressed;
  const _CalcButton({required this.calculating, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: calculating
            ? null
            : const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1E88E5)]),
        color: calculating ? const Color(0xFFCFD8EC) : null,
        boxShadow: calculating
            ? []
            : [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton.icon(
        onPressed: calculating ? null : onPressed,
        icon: calculating
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.calculate_rounded, size: 20),
        label: Text(
          calculating ? 'جارٍ الحساب...' : 'احسب النتيجة',
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white54,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
