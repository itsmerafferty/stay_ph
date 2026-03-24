import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tenant_inquiry_model.dart';

class InquiryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Create an inquiry (tenant applies for a listing)
  Future<String> createInquiry(
    String tenantId,
    String listingId, {
    String? message,
  }) async {
    try {
      final response =
          await _supabase
              .from('tenant_inquiries')
              .insert({
                'tenant_id': tenantId,
                'listing_id': listingId,
                'message': message,
                'status': 'pending',
              })
              .select()
              .single();

      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to create inquiry: $e');
    }
  }

  /// Get all inquiries for a landlord (from their listings)
  Future<List<TenantInquiry>> getLandlordInquiries(String landlordId) async {
    try {
      final response = await _supabase
          .from('tenant_inquiries')
          .select()
          .eq(
            'listing_id',
            '(select id from listings where landlord_id = $landlordId)',
          )
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TenantInquiry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback approach if the nested query doesn't work
      return _getLandlordInquiriesFallback(landlordId);
    }
  }

  /// Fallback method for getting landlord inquiries
  Future<List<TenantInquiry>> _getLandlordInquiriesFallback(
    String landlordId,
  ) async {
    try {
      // Get all listings for the landlord
      final listingsResponse = await _supabase
          .from('listings')
          .select('id')
          .eq('landlord_id', landlordId);

      final listingIds =
          (listingsResponse as List).map((l) => l['id'] as String).toList();

      if (listingIds.isEmpty) {
        return [];
      }

      // Get inquiries for those listings
      final inquiriesResponse = await _supabase
          .from('tenant_inquiries')
          .select()
          .inFilter('listing_id', listingIds)
          .order('created_at', ascending: false);

      return (inquiriesResponse as List)
          .map((json) => TenantInquiry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch landlord inquiries: $e');
    }
  }

  /// Get all inquiries for a tenant
  Future<List<TenantInquiry>> getTenantInquiries(String tenantId) async {
    try {
      final response = await _supabase
          .from('tenant_inquiries')
          .select()
          .eq('tenant_id', tenantId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TenantInquiry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tenant inquiries: $e');
    }
  }

  /// Get a single inquiry
  Future<TenantInquiry?> getInquiry(String inquiryId) async {
    try {
      final response =
          await _supabase
              .from('tenant_inquiries')
              .select()
              .eq('id', inquiryId)
              .maybeSingle();

      if (response == null) return null;
      return TenantInquiry.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch inquiry: $e');
    }
  }

  /// Update inquiry status (landlord action)
  Future<void> updateInquiryStatus(
    String inquiryId,
    InquiryStatus status,
  ) async {
    try {
      await _supabase
          .from('tenant_inquiries')
          .update({
            'status': status.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', inquiryId);
    } catch (e) {
      throw Exception('Failed to update inquiry: $e');
    }
  }

  /// Withdraw an inquiry (tenant action)
  Future<void> withdrawInquiry(String inquiryId) async {
    try {
      await _supabase
          .from('tenant_inquiries')
          .update({
            'status': 'withdrawn',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', inquiryId);
    } catch (e) {
      throw Exception('Failed to withdraw inquiry: $e');
    }
  }

  /// Get pending inquiries count for a landlord
  Future<int> getPendingInquiriesCount(String landlordId) async {
    try {
      final listingsResponse = await _supabase
          .from('listings')
          .select('id')
          .eq('landlord_id', landlordId);

      final listingIds =
          (listingsResponse as List).map((l) => l['id'] as String).toList();

      if (listingIds.isEmpty) {
        return 0;
      }

      final inquiriesResponse = await _supabase
          .from('tenant_inquiries')
          .select('id')
          .inFilter('listing_id', listingIds)
          .eq('status', 'pending');

      return (inquiriesResponse as List).length;
    } catch (e) {
      throw Exception('Failed to get pending inquiries count: $e');
    }
  }

  /// Check if a tenant has already inquired about a listing
  Future<bool> hasInquired(String tenantId, String listingId) async {
    try {
      final response =
          await _supabase
              .from('tenant_inquiries')
              .select()
              .eq('tenant_id', tenantId)
              .eq('listing_id', listingId)
              .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check inquiry status: $e');
    }
  }
}
