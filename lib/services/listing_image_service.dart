import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/listing_image_model.dart';

class ListingImageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all images for a listing
  Future<List<ListingImage>> getListingImages(String listingId) async {
    try {
      final response = await _supabase
          .from('listing_images')
          .select()
          .eq('listing_id', listingId)
          .order('display_order', ascending: true);

      return (response as List)
          .map((json) => ListingImage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch listing images: $e');
    }
  }

  /// Add an image URL to a listing (for now, just store URLs)
  /// In future, this can accept actual file upload
  Future<String> addImageUrl(
    String listingId,
    String imageUrl, {
    int displayOrder = 0,
  }) async {
    try {
      final response =
          await _supabase
              .from('listing_images')
              .insert({
                'listing_id': listingId,
                'image_url': imageUrl,
                'display_order': displayOrder,
              })
              .select()
              .single();

      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to add image: $e');
    }
  }

  /// Delete an image
  Future<void> deleteImage(String imageId) async {
    try {
      await _supabase.from('listing_images').delete().eq('id', imageId);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Update image display order
  Future<void> updateImageOrder(String imageId, int displayOrder) async {
    try {
      await _supabase
          .from('listing_images')
          .update({'display_order': displayOrder})
          .eq('id', imageId);
    } catch (e) {
      throw Exception('Failed to update image order: $e');
    }
  }

  /// Delete all images for a listing
  Future<void> deleteListingImages(String listingId) async {
    try {
      await _supabase
          .from('listing_images')
          .delete()
          .eq('listing_id', listingId);
    } catch (e) {
      throw Exception('Failed to delete listing images: $e');
    }
  }
}
