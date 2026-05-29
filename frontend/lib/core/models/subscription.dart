class SubscriptionPlanSimple {
  final int id;
  final String name;
  final int durationDays;
  final double price;

  const SubscriptionPlanSimple({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
  });

  factory SubscriptionPlanSimple.fromJson(Map<String, dynamic> json) => SubscriptionPlanSimple(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        durationDays: (json['duration_days'] as num?)?.toInt() ?? 30,
        price: (json['price'] as num?)?.toDouble() ?? 0,
      );
}

class SubscriptionRequest {
  final int id;
  final int planId;
  final String phone;
  final String paymentMethod;
  final String receiptImageUrl;
  final String note;
  final String status; // pending, approved, rejected
  final String adminNote;
  final String planName;
  final String createdAt;

  const SubscriptionRequest({
    required this.id,
    required this.planId,
    required this.phone,
    required this.paymentMethod,
    required this.receiptImageUrl,
    required this.note,
    required this.status,
    required this.adminNote,
    required this.planName,
    required this.createdAt,
  });

  factory SubscriptionRequest.fromJson(Map<String, dynamic> json) => SubscriptionRequest(
        id: (json['id'] as num?)?.toInt() ?? 0,
        planId: (json['plan_id'] as num?)?.toInt() ?? 0,
        phone: json['phone'] as String? ?? '',
        paymentMethod: json['payment_method'] as String? ?? '',
        receiptImageUrl: json['receipt_image_url'] as String? ?? '',
        note: json['note'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        adminNote: json['admin_note'] as String? ?? '',
        planName: json['plan_name'] as String? ?? '',
        createdAt: json['created_at'] as String? ?? '',
      );

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}

class MySubscription {
  final bool hasSubscription;
  final bool isActive;
  final String planName;
  final String startDate;
  final String endDate;
  final int daysRemaining;

  const MySubscription({
    required this.hasSubscription,
    required this.isActive,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.daysRemaining,
  });

  factory MySubscription.fromJson(Map<String, dynamic> json) {
    return MySubscription(
      hasSubscription: json['has_subscription'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? false,
      planName: json['plan_name'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      daysRemaining: json['days_remaining'] as int? ?? 0,
    );
  }

  static MySubscription noSubscription() => const MySubscription(
    hasSubscription: false,
    isActive: false,
    planName: '',
    startDate: '',
    endDate: '',
    daysRemaining: 0,
  );
}
