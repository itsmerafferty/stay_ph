import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/favorite_model.dart';
import '../models/listing_model.dart';

class FavoriteService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Add a listing to favorites
  Future<void> addFavorite(String tenantId, String listingId) async {
    try {
      await _supabase.from('favorites').insert({
        'tenant_id': tenantId,
        'listing_id': listingId,
      });
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  /// Remove a listing from favorites
  Future<void> removeFavorite(String tenantId, String listingId) async {
    try {
      await _supabase
          .from('favorites')
          .delete()
          .eq('tenant_id', tenantId)
          .eq('listing_id', listingId);
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  /// Get all favorites for a tenant (returns full listing data)
  Future<List<Listing>> getFavorites(String tenantId) async {
    try {
      final response = await _supabase
          .from('favorites')
          .select('listing_id, listings(*)')
          .eq('tenant_id', tenantId)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final listingData = json['listings'] as Map<String, dynamic>;
        return Listing.fromJson(listingData);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch favorites: $e');
    }
  }

  /// Check if a listing is favorited by a tenant
  Future<bool> isFavorite(String tenantId, String listingId) async {
    try {
      final response =
          await _supabase
              .from('favorites')
              .select()
              .eq('tenant_id', tenantId)
              .eq('listing_id', listingId)
              .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check favorite status: $e');
    }
  }

  /// Get count of favorites for a tenant
  Future<int> getFavoritesCount(String tenantId) async {
    try {
      final response = await _supabase
          .from('favorites')
          .select('id')
          .eq('tenant_id', tenantId);

      return (response as List).length;
    } catch (e) {
      throw Exception('Failed to get favorites count: $e');
    }
  }

  /// Remove all favorites (bulk operation)
  Future<void> removeAllFavorites(String tenantId) async {
    try {
      await _supabase.from('favorites').delete().eq('tenant_id', tenantId);
    } catch (e) {
      throw Exception('Failed to remove all favorites: $e');
    }
  }
}
