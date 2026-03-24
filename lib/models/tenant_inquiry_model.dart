enum InquiryStatus {
  pending,
  approved,
  rejected,
  withdrawn;

  String get displayName {
    switch (this) {
      case InquiryStatus.pending:
        return 'Pending';
      case InquiryStatus.approved:
        return 'Approved';
      case InquiryStatus.rejected:
        return 'Rejected';
      case InquiryStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  static InquiryStatus fromString(String value) {
    return InquiryStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => InquiryStatus.pending,
    );
  }
}

class TenantInquiry {
  final String id;
  final String tenantId;
  final String listingId;
  final String? message;
  final InquiryStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TenantInquiry({
    required this.id,
    required this.tenantId,
    required this.listingId,
    this.message,
    this.status = InquiryStatus.pending,
    required this.createdAt,
    this.updatedAt,
  });

  factory TenantInquiry.fromJson(Map<String, dynamic> json) {
    return TenantInquiry(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      listingId: json['listing_id'] as String,
      message: json['message'] as String?,
      status: InquiryStatus.fromString(json['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'listing_id': listingId,
      'message': message,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  TenantInquiry copyWith({
    String? id,
    String? tenantId,
    String? listingId,
    String? message,
    InquiryStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TenantInquiry(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      listingId: listingId ?? this.listingId,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
