class Favorite {
  final String id;
  final String tenantId;
  final String listingId;
  final DateTime createdAt;

  const Favorite({
    required this.id,
    required this.tenantId,
    required this.listingId,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      listingId: json['listing_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'listing_id': listingId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
