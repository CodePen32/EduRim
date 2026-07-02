import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/models/subscription.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/subscription_service.dart';

class MySubscriptionScreen extends StatefulWidget {
  const MySubscriptionScreen({super.key});

  @override
  State<MySubscriptionScreen> createState() => _MySubscriptionScreenState();
}

class _MySubscriptionScreenState extends State<MySubscriptionScreen> {
  bool _loading = true;
  MySubscription? _subscription;
  List<SubscriptionRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      subscriptionService.getMySubscription(),
      subscriptionService.getMyRequests(),
    ]);
    if (mounted) {
      setState(() {
        _subscription = results[0] as MySubscription;
        _requests = results[1] as List<SubscriptionRequest>;
        _loading = false;
      });
    }
  }

  SubscriptionRequest? get _pendingRequest {
    try {
      return _requests.firstWhere((r) => r.isPending);
    } catch (_) {
      return null;
    }
  }

  SubscriptionRequest? get _lastRejectedRequest {
    try {
      return _requests.firstWhere((r) => r.isRejected);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          tr('mysub.title'),
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: _buildContent(),
              ),
            ),
    );
  }

  Widget _buildContent() {
    final sub = _subscription;

    // Active subscription
    if (sub != null && sub.hasSubscription && sub.isActive) {
      return _buildActiveSubscription(sub);
    }

    // Pending request
    final pending = _pendingRequest;
    if (pending != null) {
      return _buildPendingRequest(pending);
    }

    // Rejected request
    final rejected = _lastRejectedRequest;
    if (rejected != null) {
      return _buildRejectedRequest(rejected);
    }

    // No subscription, no pending request
    return _buildNoSubscription();
  }

  Widget _buildActiveSubscription(MySubscription sub) {
    final expiringSoon = sub.daysRemaining > 0 && sub.daysRemaining <= 5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // تنبيه انتهاء قريب
        if (expiringSoon) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    tr('mysub.expiringSoon'),
                    style: const TextStyle(
                        fontFamily: 'Cairo', fontSize: 13, color: Color(0xFF92400E), height: 1.5),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 22),
              ],
            ),
          ),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          tr('mysub.activeBadge'),
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.credit_card_rounded, color: Colors.white70, size: 32),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                sub.planName,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(tr('mysub.remaining'),
                          style: const TextStyle(
                              fontFamily: 'Cairo', color: Colors.white70, fontSize: 12)),
                      Text(
                        AppStrings.withArg('mysub.daysUnit', '${sub.daysRemaining}'),
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          tr('mysub.details'),
          style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        _InfoRow(icon: Icons.calendar_today_outlined, label: tr('mysub.startDate'), value: sub.startDate),
        const SizedBox(height: 8),
        _InfoRow(icon: Icons.event_outlined, label: tr('mysub.endDate'), value: sub.endDate),
        const SizedBox(height: 8),
        _InfoRow(
            icon: Icons.timer_outlined,
            label: tr('mysub.daysRemaining'),
            value: AppStrings.withArg('mysub.daysUnit', '${sub.daysRemaining}')),
        if (expiringSoon) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Navigator.pushNamed(context, AppRoutes.requestSubscription);
                _load();
              },
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
              label: Text(tr('mysub.renew'),
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: AppColors.primary)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPendingRequest(SubscriptionRequest req) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    tr('mysub.pending'),
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD97706)),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.hourglass_top_rounded, color: Color(0xFFD97706), size: 22),
                ],
              ),
              const SizedBox(height: 10),
              if (req.planName.isNotEmpty)
                Text(
                  AppStrings.withArg('mysub.plan', req.planName),
                  style: const TextStyle(
                      fontFamily: 'Cairo', fontSize: 14, color: Color(0xFF92400E)),
                  textAlign: TextAlign.start,
                ),
              const SizedBox(height: 6),
              Text(
                tr('mysub.pendingBody'),
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Color(0xFF92400E),
                    height: 1.6),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRejectedRequest(SubscriptionRequest req) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    tr('mysub.rejected'),
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626)),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 22),
                ],
              ),
              if (req.adminNote.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  AppStrings.withArg('mysub.rejectReason', req.adminNote),
                  style: const TextStyle(
                      fontFamily: 'Cairo', fontSize: 13, color: Color(0xFF991B1B)),
                  textAlign: TextAlign.start,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.requestSubscription);
              _load();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              tr('mysub.newRequest'),
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoSubscription() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.credit_card_off_outlined,
              color: AppColors.primary, size: 48),
        ),
        const SizedBox(height: 24),
        Text(
          tr('mysub.noActive'),
          style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Text(
          tr('mysub.noActiveBody'),
          style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.7),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.requestSubscription);
              _load();
            },
            icon: const Icon(Icons.add_card_rounded),
            label: Text(
              tr('mysub.request'),
              style: const TextStyle(
                  fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const Spacer(),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Icon(icon, color: AppColors.primary, size: 18),
        ],
      ),
    );
  }
}
