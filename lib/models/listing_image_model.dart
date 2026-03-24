class ListingImage {
  final String id;
  final String listingId;
  final String imageUrl;
  final int displayOrder;
  final DateTime createdAt;

  const ListingImage({
    required this.id,
    required this.listingId,
    required this.imageUrl,
    this.displayOrder = 0,
    required this.createdAt,
  });

  factory ListingImage.fromJson(Map<String, dynamic> json) {
    return ListingImage(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      imageUrl: json['image_url'] as String,
      displayOrder: json['display_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listing_id': listingId,
      'image_url': imageUrl,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ListingImage copyWith({
    String? id,
    String? listingId,
    String? imageUrl,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return ListingImage(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      imageUrl: imageUrl ?? this.imageUrl,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
