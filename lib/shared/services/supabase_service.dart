import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

import '../models/simple_models.dart';

/// Service for Supabase database operations
///
/// This service encapsulates all database operations using Supabase.
/// It provides a clean interface for CRUD operations on all entities
/// and handles error logging and type conversion.
class SupabaseService {
  final SupabaseClient _supabase;
  final Logger _logger;

  SupabaseService({
    required SupabaseClient supabase,
    required Logger logger,
  })  : _supabase = supabase,
        _logger = logger;

  // Profile operations

  /// Get a user profile by ID
  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Profile.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Failed to get profile', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update a user profile
  Future<Profile> updateProfile(
      String userId, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Failed to update profile', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Create a new profile (called automatically via trigger)
  Future<Profile> createProfile({
    required String userId,
    String? username,
    String? displayName,
  }) async {
    try {
      final response = await _supabase
          .from('profiles')
          .insert({
            'id': userId,
            'username': username,
            'display_name': displayName,
          })
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Failed to create profile', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Item operations

  /// Get items with pagination and filtering
  Future<List<Item>> getItems({
    int limit = 20,
    int offset = 0,
    ItemCategory? category,
    String? geohash,
    String? search,
    String? userId,
  }) async {
    try {
      // Start with base query
      var queryBuilder = _supabase
          .from('items')
          .select('*');

      // Apply filters
      queryBuilder = queryBuilder.eq('status', 'approved');
      
      if (category != null) {
        queryBuilder = queryBuilder.eq('category', category.value);
      }

      if (geohash != null) {
        queryBuilder = queryBuilder.ilike('geohash', '$geohash%');
      }

      if (search != null && search.isNotEmpty) {
        // Use ilike for basic text search instead of textSearch
        queryBuilder = queryBuilder.or('title.ilike.%$search%,description.ilike.%$search%');
      }

      if (userId != null) {
        queryBuilder = queryBuilder.eq('user_id', userId);
      }

      // Apply ordering and pagination
      final response = await queryBuilder
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map<Item>((json) => Item.fromJson(json)).toList();
    } catch (e, stackTrace) {
      _logger.e('Failed to get items', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get a single item by ID
  Future<Item?> getItem(String itemId, {String? userId}) async {
    try {
      final response = await _supabase
          .from('items')
          .select('*')
          .eq('id', itemId)
          .eq('status', 'approved')
          .maybeSingle();
          
      if (response == null) return null;

      return Item.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Failed to get item', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Create a new item
  Future<Item> createItem(CreateItemRequest request, String userId) async {
    try {
      final itemData = request.toJson();
      itemData['user_id'] = userId;

      final response = await _supabase
          .from('items')
          .insert(itemData)
          .select('*')
          .single();

      return Item.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Failed to create item', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update an item
  Future<Item> updateItem(String itemId, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from('items')
          .update(updates)
          .eq('id', itemId)
          .select('*')
          .single();

      return Item.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Failed to update item', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Delete an item
  Future<void> deleteItem(String itemId) async {
    try {
      await _supabase.from('items').delete().eq('id', itemId);
    } catch (e, stackTrace) {
      _logger.e('Failed to delete item', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Comment operations

  /// Get comments for an item
  Future<List<Comment>> getComments(String itemId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('*')
          .eq('item_id', itemId)
          .order('created_at', ascending: true);

      return response.map<Comment>((json) => Comment.fromJson(json)).toList();
    } catch (e, stackTrace) {
      _logger.e('Failed to get comments', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Create a new comment
  Future<Comment> createComment(
      CreateCommentRequest request, String userId) async {
    try {
      final commentData = request.toJson();
      commentData['user_id'] = userId;

      final response = await _supabase
          .from('comments')
          .insert(commentData)
          .select('*')
          .single();

      return Comment.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Failed to create comment', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update a comment
  Future<Comment> updateComment(String commentId, String newContent) async {
    try {
      final response = await _supabase
          .from('comments')
          .update({'content': newContent})
          .eq('id', commentId)
          .select('*')
          .single();

      return Comment.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Failed to update comment', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId) async {
    try {
      await _supabase.from('comments').delete().eq('id', commentId);
    } catch (e, stackTrace) {
      _logger.e('Failed to delete comment', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Like operations

  /// Toggle like on an item
  Future<bool> toggleLike(String itemId, String userId) async {
    try {
      // Check if already liked
      final existingLike = await _supabase
          .from('likes')
          .select('id')
          .eq('item_id', itemId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingLike != null) {
        // Unlike
        await _supabase
            .from('likes')
            .delete()
            .eq('item_id', itemId)
            .eq('user_id', userId);
        return false;
      } else {
        // Like
        await _supabase.from('likes').insert({
          'item_id': itemId,
          'user_id': userId,
        });
        return true;
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to toggle like', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get like count for an item
  Future<int> getLikeCount(String itemId) async {
    try {
      final response = await _supabase
          .from('likes')
          .select('id')
          .eq('item_id', itemId);

      return response.length;
    } catch (e, stackTrace) {
      _logger.e('Failed to get like count', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Check if user has liked an item
  Future<bool> hasUserLiked(String itemId, String userId) async {
    try {
      final response = await _supabase
          .from('likes')
          .select('id')
          .eq('item_id', itemId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e, stackTrace) {
      _logger.e('Failed to check user like', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Search operations

  /// Search items with full-text search
  Future<List<Item>> searchItems(
    String query, {
    int limit = 20,
    int offset = 0,
    ItemCategory? category,
    String? geohash,
  }) async {
    try {
      var searchQueryBuilder = _supabase
          .from('items')
          .select('*')
          .eq('status', 'approved');
      
      // Use basic text search with OR conditions
      searchQueryBuilder = searchQueryBuilder
          .or('title.ilike.%$query%,description.ilike.%$query%');

      if (category != null) {
        searchQueryBuilder = searchQueryBuilder.eq('category', category.value);
      }

      if (geohash != null) {
        searchQueryBuilder = searchQueryBuilder.ilike('geohash', '$geohash%');
      }

      final response = await searchQueryBuilder
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return response.map<Item>((json) => Item.fromJson(json)).toList();
    } catch (e, stackTrace) {
      _logger.e('Failed to search items', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get items near a location (by geohash prefix)
  Future<List<Item>> getItemsNearLocation(
    String geohash, {
    int precision = 5,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final geohashPrefix = geohash.substring(0, precision);

      final response = await _supabase
          .from('items')
          .select('*')
          .eq('status', 'approved')
          .ilike('geohash', '$geohashPrefix%')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map<Item>((json) => Item.fromJson(json)).toList();
    } catch (e, stackTrace) {
      _logger.e('Failed to get items near location',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
