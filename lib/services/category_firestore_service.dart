// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petshop/models/category.dart';

class CategoryFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _categoriesCollection = 'categories';

  // Get all active categories
  static Future<List<Category>> getAllCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection(_categoriesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .orderBy('displayName')
          .get();

      return querySnapshot.docs.map((doc) {
        return Category.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // Get category by ID
  static Future<Category?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore
          .collection(_categoriesCollection)
          .doc(categoryId)
          .get();

      if (doc.exists) {
        return Category.fromFirestore(doc.data()!, doc.id);
      }

      return null;
    } catch (e) {
      print('Error fetching category by ID: $e');
      return null;
    }
  }

  // Get category by name
  static Future<Category?> getCategoryByName(String categoryName) async {
    try {
      final querySnapshot = await _firestore
          .collection(_categoriesCollection)
          .where('name', isEqualTo: categoryName)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return Category.fromFirestore(doc.data(), doc.id);
      }

      return null;
    } catch (e) {
      print('Error fetching category by name: $e');
      return null;
    }
  }

  // Get categories stream for real-time updates
  static Stream<List<Category>> getCategoriesStream() {
    return _firestore
        .collection(_categoriesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .orderBy('displayName')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Category.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  // Create category
  static Future<bool> createCategory(Category category) async {
    try {
      final data = category.toFirestore();
      data['createdAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_categoriesCollection)
          .doc(category.id)
          .set(data);

      return true;
    } catch (e) {
      print('Error creating category: $e');
      return false;
    }
  }

  // Update category
  static Future<bool> updateCategory(
    String categoryId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_categoriesCollection)
          .doc(categoryId)
          .update(data);

      return true;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  // Delete category (soft delete by setting isActive to false)
  static Future<bool> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection(_categoriesCollection).doc(categoryId).update(
        {'isActive': false, 'updatedAt': FieldValue.serverTimestamp()},
      );

      return true;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  // Check if category exists
  static Future<bool> categoryExists(String categoryName) async {
    try {
      final querySnapshot = await _firestore
          .collection(_categoriesCollection)
          .where('name', isEqualTo: categoryName)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking category existence: $e');
      return false;
    }
  }
}
