import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/listing_model.dart';
import '../models/listing_image_model.dart';

class ListingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all active listings (featured/browse)
  Future<List<Listing>> getAllListings() async {
    try {
      final response = await _supabase
          .from('listings')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Listing.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch listings: $e');
    }
  }

  /// Search listings by filters
  Future<List<Listing>> searchListings({
    String? city,
    String? roomType,
    int? minPrice,
    int? maxPrice,
  }) async {
    try {
      var query = _supabase.from('listings').select().eq('status', 'active');

      if (city != null && city != 'All Cities') {
        query = query.eq('city', city);
      }

      if (roomType != null && roomType != 'All Types') {
        query = query.eq('room_type', roomType);
      }

      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }

      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => Listing.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search listings: $e');
    }
  }

  /// Get featured listings (can be based on recent, popular, etc.)
  Future<List<Listing>> getFeaturedListings({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('listings')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => Listing.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch featured listings: $e');
    }
  }

  /// Get a single listing by ID
  Future<Listing?> getListing(String listingId) async {
    try {
      final response =
          await _supabase
              .from('listings')
              .select()
              .eq('id', listingId)
              .maybeSingle();

      if (response == null) return null;
      return Listing.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch listing: $e');
    }
  }

  /// Get all listings for a landlord
  Future<List<Listing>> getLandlordListings(String landlordId) async {
    try {
      final response = await _supabase
          .from('listings')
          .select()
          .eq('landlord_id', landlordId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Listing.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch landlord listings: $e');
    }
  }

  /// Create a new listing
  Future<String> createListing({
    required String landlordId,
    required String address,
    required String city,
    required int price,
    required String roomType,
    String? description,
    List<String>? amenities,
  }) async {
    try {
      final response =
          await _supabase
              .from('listings')
              .insert({
                'landlord_id': landlordId,
                'address': address,
                'city': city,
                'price': price,
                'room_type': roomType,
                'description': description,
                'amenities': amenities?.join(','),
                'status': 'active',
              })
              .select()
              .single();

      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to create listing: $e');
    }
  }

  /// Update an existing listing
  Future<void> updateListing(
    String listingId, {
    String? address,
    String? city,
    int? price,
    String? roomType,
    String? description,
    List<String>? amenities,
    String? status,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (address != null) updateData['address'] = address;
      if (city != null) updateData['city'] = city;
      if (price != null) updateData['price'] = price;
      if (roomType != null) updateData['room_type'] = roomType;
      if (description != null) updateData['description'] = description;
      if (amenities != null) updateData['amenities'] = amenities.join(',');
      if (status != null) updateData['status'] = status;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('listings').update(updateData).eq('id', listingId);
    } catch (e) {
      throw Exception('Failed to update listing: $e');
    }
  }

  /// Delete a listing
  Future<void> deleteListing(String listingId) async {
    try {
      await _supabase.from('listings').delete().eq('id', listingId);
    } catch (e) {
      throw Exception('Failed to delete listing: $e');
    }
  }

  /// Get listings by city
  Future<List<Listing>> getListingsByCity(String city) async {
    try {
      final response = await _supabase
          .from('listings')
          .select()
          .eq('city', city)
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Listing.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch listings by city: $e');
    }
  }

  /// Get listings by room type
  Future<List<Listing>> getListingsByRoomType(String roomType) async {
    try {
      final response = await _supabase
          .from('listings')
          .select()
          .eq('room_type', roomType)
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Listing.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch listings by room type: $e');
    }
  }

  /// Get listings within price range
  Future<List<Listing>> getListingsByPriceRange(
    int minPrice,
    int maxPrice,
  ) async {
    try {
      final response = await _supabase
          .from('listings')
          .select()
          .gte('price', minPrice)
          .lte('price', maxPrice)
          .eq('status', 'active')
          .order('price', ascending: true);

      return (response as List)
          .map((json) => Listing.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch listings by price range: $e');
    }
  }
}
