import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/models/subscription.dart';
import '../../../core/services/subscription_service.dart';

const _kPaymentNumber = '36050044';

const _paymentMethods = [
  _PaymentMethod(name: 'Bankily',     icon: Icons.account_balance_wallet_outlined),
  _PaymentMethod(name: 'Masrvi',      icon: Icons.payment_outlined),
  _PaymentMethod(name: 'Bimbank',     icon: Icons.account_balance_outlined),
  _PaymentMethod(name: 'Sedad Bank',  icon: Icons.business_outlined),
  _PaymentMethod(name: 'Gaza Pay',    icon: Icons.savings_outlined),
];

class _PaymentMethod {
  final String name;
  final IconData icon;
  const _PaymentMethod({required this.name, required this.icon});
}

class RequestSubscriptionScreen extends StatefulWidget {
  const RequestSubscriptionScreen({super.key});
  @override
  State<RequestSubscriptionScreen> createState() => _RequestSubscriptionScreenState();
}

class _RequestSubscriptionScreenState extends State<RequestSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _noteController   = TextEditingController();

  List<SubscriptionPlanSimple> _plans = [];
  bool _loadingPlans = true;
  bool _submitting   = false;

  SubscriptionPlanSimple? _selectedPlan;
  String _paymentMethod = _paymentMethods.first.name;

  // receipt image — URL after upload (web: picked file URL / mobile: path)
  // For simplicity we store the URL from our upload endpoint
  String _receiptUrl = '';
  bool _uploadingReceipt = false;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    setState(() => _loadingPlans = true);
    final plans = await subscriptionService.getAvailablePlans();
    if (mounted) {
      setState(() {
        _plans = plans;
        if (plans.isNotEmpty) _selectedPlan = plans.first;
        _loadingPlans = false;
      });
    }
  }

  Future<void> _pickAndUploadReceipt() async {
    // Web: استخدام input file عبر html
    setState(() => _uploadingReceipt = true);
    try {
      final url = await subscriptionService.uploadReceiptImage();
      if (url.isNotEmpty && mounted) setState(() => _receiptUrl = url);
    } catch (e) {
      if (mounted) _showError('${tr('req.uploadFailed')}: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _uploadingReceipt = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPlan == null) { _showError(tr('req.selectPlan')); return; }
    if (_receiptUrl.isEmpty)   { _showError(tr('req.attachReceiptError')); return; }

    setState(() => _submitting = true);
    try {
      await subscriptionService.createRequest(
        planId: _selectedPlan!.id,
        phone: _phoneController.text.trim(),
        paymentMethod: _paymentMethod,
        receiptImageUrl: _receiptUrl,
        note: _noteController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            tr('req.sent'),
            style: const TextStyle(fontFamily: 'Cairo'),
            textAlign: TextAlign.start,
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
        ));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Cairo'), textAlign: TextAlign.start),
      backgroundColor: AppColors.error,
    ));
  }

  void _copyNumber() {
    Clipboard.setData(const ClipboardData(text: _kPaymentNumber));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(tr('req.numberCopied'), style: const TextStyle(fontFamily: 'Cairo')),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr('req.title'),
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: _loadingPlans
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. الاسم الكامل (عرض فقط) ──
                    _buildSection(
                      title: tr('req.planType'),
                      child: _plans.isEmpty
                          ? _emptyPlans()
                          : _planSelector(),
                    ),

                    const SizedBox(height: 16),

                    // ── 2. رقم الهاتف ──
                    _buildSection(
                      title: tr('req.phone'),
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textAlign: TextAlign.start,
                        decoration: _inputDec(tr('req.phoneHint')),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? tr('req.phoneRequired') : null,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── 3. حسابات الدفع ──
                    _buildSection(
                      title: tr('req.paymentAccounts'),
                      child: Column(
                        children: _paymentMethods.map((m) => _PaymentCard(
                          method: m,
                          isSelected: _paymentMethod == m.name,
                          accountNumber: _kPaymentNumber,
                          onTap: () => setState(() => _paymentMethod = m.name),
                          onCopy: _copyNumber,
                        )).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── 4. تعليمات ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(tr('req.paymentInstructions'),
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF0369A1))),
                              const SizedBox(width: 6),
                              const Icon(Icons.info_outline, color: Color(0xFF0369A1), size: 18),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tr('req.paymentBody'),
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: Color(0xFF0C4A6E),
                                height: 1.7),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _copyNumber,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF7DD3FC)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: [
                                    const Icon(Icons.copy, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(tr('req.copyNumber'),
                                        style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 13,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600)),
                                  ]),
                                  Text(_kPaymentNumber,
                                      style: const TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                          letterSpacing: 1.5)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── 5. رفع صورة الإيصال (إلزامي) ──
                    _buildSection(
                      title: tr('req.receipt'),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _uploadingReceipt ? null : _pickAndUploadReceipt,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: _receiptUrl.isEmpty
                                    ? AppColors.surface
                                    : AppColors.success.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _receiptUrl.isEmpty
                                      ? const Color(0xFFE2E8F0)
                                      : AppColors.success,
                                  width: _receiptUrl.isEmpty ? 1 : 1.5,
                                ),
                              ),
                              child: _uploadingReceipt
                                  ? const Center(child: SizedBox(
                                      width: 22, height: 22,
                                      child: CircularProgressIndicator(
                                          color: AppColors.primary, strokeWidth: 2.5)))
                                  : Column(
                                      children: [
                                        Icon(
                                          _receiptUrl.isEmpty
                                              ? Icons.upload_file_outlined
                                              : Icons.check_circle_outline,
                                          size: 32,
                                          color: _receiptUrl.isEmpty
                                              ? AppColors.textLight
                                              : AppColors.success,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _receiptUrl.isEmpty
                                              ? tr('req.attachReceipt')
                                              : tr('req.receiptUploaded'),
                                          style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 14,
                                              color: _receiptUrl.isEmpty
                                                  ? AppColors.textSecondary
                                                  : AppColors.success,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── 6. ملاحظة اختيارية ──
                    _buildSection(
                      title: tr('req.note'),
                      child: TextFormField(
                        controller: _noteController,
                        maxLines: 2,
                        textAlign: TextAlign.start,
                        decoration: _inputDec(tr('req.noteHint')),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── زر الإرسال ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_submitting || _plans.isEmpty) ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _submitting
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2.5))
                            : Text(tr('req.submit'),
                                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(title,
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
        ),
        child,
      ],
    );
  }

  Widget _planSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: _plans.asMap().entries.map((e) {
          final idx = e.key;
          final p = e.value;
          final selected = _selectedPlan?.id == p.id;
          return InkWell(
            onTap: () => setState(() => _selectedPlan = p),
            borderRadius: BorderRadius.circular(idx == 0 ? 12 : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary.withValues(alpha: 0.06) : null,
                borderRadius: BorderRadius.circular(12),
                border: idx > 0
                    ? const Border(top: BorderSide(color: Color(0xFFE2E8F0)))
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppColors.primary : const Color(0xFFCBD5E1),
                        width: selected ? 6 : 2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(p.name,
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                              color: selected ? AppColors.primary : AppColors.textPrimary)),
                      Text('MRU ${p.price.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: selected ? AppColors.primary : AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _emptyPlans() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(tr('req.noPlans'),
            style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
            textAlign: TextAlign.center),
      );

  InputDecoration _inputDec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      );
}

// ── كارت وسيلة الدفع ──
class _PaymentCard extends StatelessWidget {
  final _PaymentMethod method;
  final bool isSelected;
  final String accountNumber;
  final VoidCallback onTap;
  final VoidCallback onCopy;

  const _PaymentCard({
    required this.method,
    required this.isSelected,
    required this.accountNumber,
    required this.onTap,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // نسخ الرقم
            GestureDetector(
              onTap: onCopy,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('نسخ الرقم',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 8),
            // رقم الحساب
            Text(accountNumber,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const Spacer(),
            // اسم الطريقة
            Text(method.name,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary)),
            const SizedBox(width: 10),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
