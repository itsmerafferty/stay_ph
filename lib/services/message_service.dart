import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

class MessageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Send a message from sender to receiver
  Future<void> sendMessage(
    String senderId,
    String receiverId,
    String content,
  ) async {
    try {
      await _supabase.from('messages').insert({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'is_read': false,
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get all messages between two users (conversation)
  Future<List<Message>> getConversationMessages(
    String userId1,
    String userId2,
  ) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .or(
            'and(sender_id.eq.$userId1,receiver_id.eq.$userId2),and(sender_id.eq.$userId2,receiver_id.eq.$userId1)',
          )
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Message.fromJson(json as Map<String, dynamic>))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  /// Get unique conversations for a user (one entry per conversation partner)
  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    try {
      // Get all messages where user is sender or receiver
      final response = await _supabase
          .from('messages')
          .select('sender_id, receiver_id, content, created_at')
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .order('created_at', ascending: false);

      // Extract unique conversation partners
      final Map<String, Map<String, dynamic>> conversationsMap = {};

      for (var msg in response as List) {
        final otherUserId =
            msg['sender_id'] == userId ? msg['receiver_id'] : msg['sender_id'];
        if (!conversationsMap.containsKey(otherUserId)) {
          conversationsMap[otherUserId] = {
            'user_id': otherUserId,
            'last_message': msg['content'],
            'last_message_time': msg['created_at'],
          };
        }
      }

      return conversationsMap.values.toList();
    } catch (e) {
      throw Exception('Failed to fetch conversations: $e');
    }
  }

  /// Mark messages as read
  Future<void> markAsRead(String userId, String otherUserId) async {
    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('receiver_id', userId)
          .eq('sender_id', otherUserId);
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  /// Get unread message count for a user
  Future<int> getUnreadMessageCount(String userId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('id')
          .eq('receiver_id', userId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _supabase.from('messages').delete().eq('id', messageId);
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }
}
