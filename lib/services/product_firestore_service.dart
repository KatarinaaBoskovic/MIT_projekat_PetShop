// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petshop/models/product.dart';

class ProductFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _productsCollection = 'products';

  // Get all products
  static Future<List<Product>> getAllProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection(_productsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Product.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }

  //Get products by category
  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection(_productsCollection)
          .where('isActive', isEqualTo: true)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Product.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching products by category: $e');
      rethrow;
    }
  }

  //Get featured products
  static Future<List<Product>> getFeaturedProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection(_productsCollection)
          .where('isActive', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs.map((doc) {
        return Product.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching featured products: $e');
      rethrow;
    }
  }

  //Get products on sale
  static Future<List<Product>> getSaleProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection(_productsCollection)
          .where('isActive', isEqualTo: true)
          .where('isOnSale', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Product.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching sale products: $e');
      rethrow;
    }
  }

  //Search products
  static Future<List<Product>> searchProducts(String searchTerm) async {
    try {
      final querySnapshot = await _firestore
          .collection(_productsCollection)
          .where('isOnSale', isEqualTo: true)
          .where('searchKeywords', arrayContains: searchTerm.toLowerCase())
          .get();

      return querySnapshot.docs.map((doc) {
        return Product.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error searching products: $e');
      rethrow;
    }
  }

  //Get product by ID
  static Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .get();
      if (doc.exists) {
        return Product.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching product by ID: $e');
      return null;
    }
  }

  //Get products stream for real-time updates
  static Stream<List<Product>> getProductsStream() {
    return _firestore
        .collection(_productsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Product.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  // Get products by price range
  static Future<List<Product>> getProductsByPriceRange({
    required double minPrice,
    required double maxPrice,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_productsCollection)
          .where('isActive', isEqualTo: true)
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice)
          .orderBy('price')
          .get();

      return querySnapshot.docs.map((doc) {
        return Product.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching products by price range: $e');
      rethrow;
    }
  }

  //Get all categories
  static Future<List<String>> getAllCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection(_productsCollection)
          .where('isActive', isEqualTo: true)
          .get();

      final categories = <String>{};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['category'] != null) {
          categories.add(data['category'] as String);
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }
}
