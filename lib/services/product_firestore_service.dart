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
          .where('isActive', isEqualTo: true)
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

  // ADMIN: Add product
  static Future<String?> addProduct(Product product) async {
    try {
      final data = product.toFirestore();

      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      data['isActive'] = data['isActive'] ?? true;

      // keywords za search
      data['searchKeywords'] = _buildSearchKeywords(
        name: (data['name'] ?? '').toString(),
        brand: (data['brand'] ?? '').toString(),
        category: (data['category'] ?? '').toString(),
      );

      final ref = await _firestore.collection(_productsCollection).add(data);
      return ref.id;
    } catch (e) {
      print('Error adding product: $e');
      return null;
    }
  }

  // ADMIN: Update product
  static Future<bool> updateProduct({
    required String productId,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();

      final name = (data['name'] ?? '').toString();
      final brand = (data['brand'] ?? '').toString();
      final category = (data['category'] ?? '').toString();
      if (data.containsKey('name') ||
          data.containsKey('brand') ||
          data.containsKey('category')) {
        data['searchKeywords'] = _buildSearchKeywords(
          name: name,
          brand: brand,
          category: category,
        );
      }

      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .set(data, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  // ADMIN: Soft delete (isActive=false)
  static Future<bool> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_productsCollection).doc(productId).set({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // ADMIN: Stream svih proizvoda (uključujući neaktivne)
  static Stream<List<Product>> getAllProductsAdminStream() {
    return _firestore
        .collection(_productsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Product.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  // helper: keywords za pretragu (prefixi)
  static List<String> _buildSearchKeywords({
    required String name,
    required String brand,
    required String category,
  }) {
    final combined = '${name.trim()} ${brand.trim()} ${category.trim()}'
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final keywords = <String>{};

    // napravi prefikse cele kombinacije
    for (int i = 1; i <= combined.length; i++) {
      keywords.add(combined.substring(0, i));
    }

    // prefiksi po rečima (da radi i "orijen" ili "food")
    for (final part in combined.split(' ')) {
      if (part.isEmpty) continue;
      for (int i = 1; i <= part.length; i++) {
        keywords.add(part.substring(0, i));
      }
    }

    return keywords.toList();
  }
}
