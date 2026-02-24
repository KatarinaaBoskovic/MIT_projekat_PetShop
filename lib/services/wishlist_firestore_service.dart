import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petshop/models/product.dart';
import 'package:petshop/models/wishlist_item.dart';

class WishlistFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _wishlistCollection = 'wishlist_items';

  // Add product to wishlist
  static Future<bool> addToWishlist({
    required String userId,
    required Product product,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Check if product is already in wishlist
      final existingItem = await getWishlistItem(userId, product.id);

      if (existingItem != null) {
        // Product already in wishlist
        return true;
      }

      // Add new item to wishlist
      final wishlistItem = WishlistItem(
        id: '',
        userId: userId,
        productId: product.id,
        product: product,
        addedAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      await _firestore
          .collection(_wishlistCollection)
          .add(wishlistItem.toFirestore());
      return true;
    } catch (e) {
      print('Error adding to wishlist: $e');
      return false;
    }
  }

  // Remove product from wishlist
  static Future<bool> removeFromWishlist(
    String userId,
    String productId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_wishlistCollection)
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: productId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();

        for (var doc in querySnapshot.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
      }

      return true;
    } catch (e) {
      print('Error removing from wishlist: $e');
      return false;
    }
  }

  // Get user's wishlist items
  static Future<List<WishlistItem>> getUserWishlistItems(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_wishlistCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('addedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return WishlistItem.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching wishlist items: $e');
      return [];
    }
  }

  // Get wishlist items stream for real-time updates
  static Stream<List<WishlistItem>> getUserWishlistItemsStream(String userId) {
    return _firestore
        .collection(_wishlistCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return WishlistItem.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  // Get specific wishlist item
  static Future<WishlistItem?> getWishlistItem(
    String userId,
    String productId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_wishlistCollection)
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return WishlistItem.fromFirestore(doc.data(), doc.id);
      }

      return null;
    } catch (e) {
      print('Error getting wishlist item: $e');
      return null;
    }
  }

  // Check if product is in wishlist
  static Future<bool> isProductInWishlist(
    String userId,
    String productId,
  ) async {
    try {
      final item = await getWishlistItem(userId, productId);
      return item != null;
    } catch (e) {
      print('Error checking wishlist: $e');
      return false;
    }
  }

  // Clear user's entire wishlist
  static Future<bool> clearUserWishlist(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_wishlistCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();

      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error clearing wishlist: $e');
      return false;
    }
  }

  // Get wishlist item count for user
  static Future<int> getWishlistItemCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_wishlistCollection)
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting wishlist item count: $e');
      return 0;
    }
  }

  // Toggle product in wishlist (add if not present, remove if present)
  static Future<bool> toggleWishlist(String userId, Product product) async {
    try {
      final isInWishlist = await isProductInWishlist(userId, product.id);

      if (isInWishlist) {
        return await removeFromWishlist(userId, product.id);
      } else {
        return await addToWishlist(userId: userId, product: product);
      }
    } catch (e) {
      print('Error toggling wishlist: $e');
      return false;
    }
  }
}
