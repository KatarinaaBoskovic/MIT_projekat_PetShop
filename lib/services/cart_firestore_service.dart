// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petshop/models/cart_item.dart';
import 'package:petshop/models/product.dart';

class CartFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _cartCollection = 'cart_items';

  // Add product to cart
  static Future<bool> addToCart({
    required String userId,
    required Product product,
    int quantity = 1,
    String? selectedSize,
    String? selectedColor,
    Map<String, dynamic>? customizations,
  }) async {
    try {
      // check if product with same specifications already exists in cart
      final existingItem = await getCartItem(
        userId,
        product.id,
        selectedSize: selectedSize,
        selectedColor: selectedColor,
      );

      if (existingItem != null) {
        //update quantity of existing item
        return await updateCartItemQuantity(
          existingItem.id,
          existingItem.quantity + quantity,
        );
      }

      // Add new item to cart
      final cartItem = CartItem(
        id: '', // will be set by Firestore
        userId: userId,
        productId: product.id,
        product: product,
        quantity: quantity,
        addedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        selectedSize: selectedSize,
        selectedColor: selectedColor,
        customizations: customizations ?? {},
      );

      await _firestore.collection(_cartCollection).add(cartItem.toFirestore());
      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  // Update cart item quantity
  static Future<bool> updateCartItemQuantity(
    String cartItemId,
    int newQuantity,
  ) async {
    try {
      if (newQuantity <= 0) {
        return await removeCartItem(cartItemId);
      }

      await _firestore.collection(_cartCollection).doc(cartItemId).update({
        'quantity': newQuantity,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      print('Error updating cart item quantity: $e');
      return false;
    }
  }

  // Remove cart item
  static Future<bool> removeCartItem(String cartItemId) async {
    try {
      await _firestore.collection(_cartCollection).doc(cartItemId).delete();
      return true;
    } catch (e) {
      print('Error removing cart item: $e');
      return false;
    }
  }

  // Get user's cart items
  static Future<List<CartItem>> getUserCartItems(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_cartCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('addedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return CartItem.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching cart items: $e');
      return [];
    }
  }

  // Get cart items stream for real-time updates
  static Stream<List<CartItem>> getUserCartItemsStream(String userId) {
    return _firestore
        .collection(_cartCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CartItem.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  // Get specific cart item
  static Future<CartItem?> getCartItem(
    String userId,
    String productId, {
    String? selectedSize,
    String? selectedColor,
  }) async {
    try {
      var query = _firestore
          .collection(_cartCollection)
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: productId);

      if (selectedSize != null) {
        query = query.where('selectedSize', isEqualTo: selectedSize);
      }

      if (selectedColor != null) {
        query = query.where('selectedColor', isEqualTo: selectedColor);
      }

      final querySnapshot = await query.limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return CartItem.fromFirestore(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting cart item: $e');
      return null;
    }
  }

  // Clear user's entire cart
  static Future<bool> clearUserCart(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_cartCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();

      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  // Get cart item count for user
  static Future<int> getCartItemCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_cartCollection)
          .where('userId', isEqualTo: userId)
          .get();

      int totalItems = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        totalItems += (data['quantity'] ?? 1) as int;
      }

      return totalItems;
    } catch (e) {
      print('Error getting cart item count: $e');
      return 0;
    }
  }

  // Calculate cart totals
  static Future<Map<String, double>> getCartTotals(String userId) async {
    try {
      final cartItems = await getUserCartItems(userId);

      double subtotal = 0.0;
      double savings = 0.0;

      for (var item in cartItems) {
        subtotal += item.totalPrice;
        savings += item.savings;
      }

      const double shipping = 10.0; // Fixed shipping cost
      final double total = subtotal + shipping;

      return {
        'subtotal': subtotal,
        'savings': savings,
        'shipping': shipping,
        'total': total,
      };
    } catch (e) {
      print('Error calculating cart totals: $e');
      return {'subtotal': 0.0, 'savings': 0.0, 'shipping': 0.0, 'total': 0.0};
    }
  }
}
