enum RoomType {
  bedspace,
  room,
  apartment,
  studio;

  String get displayName {
    switch (this) {
      case RoomType.bedspace:
        return 'Bedspace';
      case RoomType.room:
        return 'Room';
      case RoomType.apartment:
        return 'Apartment';
      case RoomType.studio:
        return 'Studio';
    }
  }

  static RoomType fromString(String value) {
    return RoomType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => RoomType.room,
    );
  }
}

enum ListingStatus {
  active,
  rented,
  inactive;

  String get displayName {
    switch (this) {
      case ListingStatus.active:
        return 'Active';
      case ListingStatus.rented:
        return 'Rented';
      case ListingStatus.inactive:
        return 'Inactive';
    }
  }

  static ListingStatus fromString(String value) {
    return ListingStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ListingStatus.active,
    );
  }
}

class Listing {
  final String id;
  final String landlordId;
  final String address;
  final String city;
  final int price; // in PHP
  final RoomType roomType;
  final String? description;
  final List<String>? amenities;
  final ListingStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Listing({
    required this.id,
    required this.landlordId,
    required this.address,
    required this.city,
    required this.price,
    required this.roomType,
    this.description,
    this.amenities,
    this.status = ListingStatus.active,
    required this.createdAt,
    this.updatedAt,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] as String,
      landlordId: json['landlord_id'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      price: json['price'] as int,
      roomType: RoomType.fromString(json['room_type'] as String),
      description: json['description'] as String?,
      amenities:
          json['amenities'] != null
              ? (json['amenities'] as String).split(',')
              : null,
      status: ListingStatus.fromString(json['status'] as String? ?? 'active'),
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
      'landlord_id': landlordId,
      'address': address,
      'city': city,
      'price': price,
      'room_type': roomType.name,
      'description': description,
      'amenities': amenities?.join(','),
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Listing copyWith({
    String? id,
    String? landlordId,
    String? address,
    String? city,
    int? price,
    RoomType? roomType,
    String? description,
    List<String>? amenities,
    ListingStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Listing(
      id: id ?? this.id,
      landlordId: landlordId ?? this.landlordId,
      address: address ?? this.address,
      city: city ?? this.city,
      price: price ?? this.price,
      roomType: roomType ?? this.roomType,
      description: description ?? this.description,
      amenities: amenities ?? this.amenities,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
