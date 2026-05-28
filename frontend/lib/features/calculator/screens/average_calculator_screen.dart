import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/calculator_result.dart';
import '../../../core/models/calculator_subject.dart';
import '../../../core/network/api_client.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/calculator_service.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/primary_button.dart';

class AverageCalculatorScreen extends StatefulWidget {
  final bool standalone;
  const AverageCalculatorScreen({super.key, this.standalone = true});

  @override
  State<AverageCalculatorScreen> createState() => _AverageCalculatorScreenState();
}

class _AverageCalculatorScreenState extends State<AverageCalculatorScreen> {
  List<CalculatorSubject> _subjects = [];
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, double?> _marks = {};
  bool _loading = true;
  bool _calculating = false;
  CalculatorResult? _result;
  String? _error;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retry if previously failed — covers the case where token loads after widget builds
    if (_initialized && _error != null && _subjects.isEmpty) {
      _loadSubjects();
    }
    _initialized = true;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    setState(() { _loading = true; _error = null; });
    try {
      final subjects = await calculatorService.getSubjects();
      if (!mounted) return;
      for (final s in subjects) {
        _controllers[s.subjectId] = TextEditingController();
        _marks[s.subjectId] = null;
      }
      setState(() { _subjects = subjects; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      final isAuth = e is ApiException && (e.statusCode == 401 || e.statusCode == 403);
      if (isAuth) {
        await authService.clearToken();
        if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }
      final isConn = e.toString().contains('SocketException') || e.toString().contains('Connection');
      setState(() {
        if (isConn) {
          _error = 'تعذر الاتصال بالخادم';
        } else {
          _error = 'تعذر تحميل مواد الحاسبة لهذا المستوى';
        }
        _loading = false;
      });
    }
  }

  Future<void> _calculate() async {
    final filledMarks = <Map<String, dynamic>>[];
    for (final s in _subjects) {
      final mark = _marks[s.subjectId];
      if (mark == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('يرجى إدخال جميع النقاط قبل الحساب', style: TextStyle(fontFamily: 'Cairo')),
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }
      if (mark < 0 || mark > s.maxMark) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('نقطة ${s.subjectName} يجب أن تكون بين 0 و ${s.maxMark.toInt()}', style: const TextStyle(fontFamily: 'Cairo')),
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }
      filledMarks.add({'subject_id': s.subjectId, 'mark': mark});
    }

    if (filledMarks.isEmpty) return;

    setState(() { _calculating = true; _result = null; });
    try {
      final result = await calculatorService.calculate(filledMarks);
      if (mounted) setState(() { _result = result; _calculating = false; });
    } catch (_) {
      if (mounted) {
        setState(() => _calculating = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تعذر حساب المعدل', style: TextStyle(fontFamily: 'Cairo')),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  void _reset() {
    for (final c in _controllers.values) {
      c.clear();
    }
    setState(() {
      for (final id in _marks.keys) {
        _marks[id] = null;
      }
      _result = null;
    });
  }

  Color _resultColor(CalculatorResult r) {
    if (r.isPassing) return AppColors.success;
    if (!r.isPoints && r.average >= 8) return AppColors.warning;
    return AppColors.error;
  }

  String _resultDisplay(CalculatorResult r) {
    if (r.isPoints) {
      return '${r.totalPoints.toInt()} / ${r.maxTotal.toInt()}';
    }
    return r.average.toStringAsFixed(2);
  }

  String _resultLabel(CalculatorResult r) {
    if (r.isPoints) return 'مجموع نقاطك';
    return 'معدلك';
  }

  @override
  Widget build(BuildContext context) {
    final isPoints = _subjects.isNotEmpty && _subjects.first.calculationType == 'points';

    return Scaffold(
      appBar: widget.standalone ? const AppHeader(title: 'حاسبة المعدل') : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: _loadSubjects,
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
                        ),
                      ],
                    ),
                  ),
                )
              : _subjects.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calculate_outlined, size: 56, color: AppColors.textLight),
                            const SizedBox(height: 16),
                            const Text(
                              'لا توجد مواد للحاسبة لهذا المستوى حاليا',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, height: 1.6),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!widget.standalone)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text('حاسبة المعدل', style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold)),
                        ),

                      if (isPoints)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            'حساب الكونكور: مجموع النقاط / 200 — حد النجاح 85 نقطة',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.primary),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Result card
                      if (_result != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(_resultLabel(_result!), style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, color: Colors.white70)),
                              const SizedBox(height: 8),
                              Text(
                                _resultDisplay(_result!),
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: _resultColor(_result!),
                                ),
                              ),
                              if (!_result!.isPoints)
                                Text(
                                  'من 20',
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white60),
                                ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _resultColor(_result!).withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _result!.status,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: _result!.isPassing ? Colors.greenAccent : Colors.redAccent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _result!.message,
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.white),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _result!.isPoints
                                    ? 'من مجموع: ${_result!.maxTotal.toInt()} نقطة'
                                    : 'مجموع المعاملات: ${_result!.totalCoefficients.toStringAsFixed(0)}',
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white60),
                              ),
                            ],
                          ),
                        ),

                      const Text('أدخل نقاطك', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      ..._subjects.map((s) {
                        final maxInt = s.maxMark.toInt();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.subjectName,
                                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                    Row(
                                      children: [
                                        if (!isPoints)
                                          Text(
                                            'معامل: ${s.coefficient % 1 == 0 ? s.coefficient.toInt() : s.coefficient}',
                                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                        if (!isPoints) const SizedBox(width: 6),
                                        Text(
                                          'من $maxInt',
                                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                        if (s.isRequired) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('إجباري', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.primary)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _controllers[s.subjectId],
                                  textDirection: TextDirection.ltr,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    hintText: '/$maxInt',
                                    hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: AppColors.primary),
                                    ),
                                  ),
                                  onChanged: (v) {
                                    final grade = double.tryParse(v);
                                    setState(() => _marks[s.subjectId] = grade);
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: _calculating ? 'جارٍ الحساب...' : 'احسب المعدل',
                        icon: Icons.calculate_outlined,
                        onPressed: _calculating ? () {} : _calculate,
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _reset,
                        child: const Center(
                          child: Text('مسح الكل', style: TextStyle(fontFamily: 'Cairo', color: AppColors.error)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
