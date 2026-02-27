// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Seed all data
  static Future<void> seedAllData() async {
    await seedProducts();
    await seedCategories();
  }

  //Add sample categories to Firestore
  static Future<void> seedCategories() async {
    final sampleCategories = [
      {
        'name': 'Food',
        'displayName': 'Food',
        'description': 'Dry and wet food for pets',
        'isActive': true,
        'sortOrder': 1,
        'subcategories': [
          'Dry Food',
          'Wet Food',
          'Treats',
          'Puppy Food',
          'Kitten Food',
        ],
        'metadata': {'color': '#4CAF50', 'icon': 'food'},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Care',
        'displayName': 'Care',
        'description': 'Pet care and grooming products',
        'isActive': true,
        'sortOrder': 2,
        'subcategories': [
          'Shampoo',
          'Brushes',
          'Nail Clippers',
          'Hygiene',
          'Dental Care',
        ],
        'metadata': {'color': '#FF9800', 'icon': 'care'},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Equipment',
        'displayName': 'Equipment',
        'description': 'Beds, cages and essential equipment',
        'isActive': true,
        'sortOrder': 3,
        'subcategories': ['Beds', 'Crates', 'Carriers', 'Bowls', 'Leashes'],
        'metadata': {'color': '#2196F3', 'icon': 'equipment'},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Clothes',
        'displayName': 'Clothes',
        'description': 'Clothing and apparel for pets',
        'isActive': true,
        'sortOrder': 4,
        'subcategories': [
          'Jackets',
          'Sweaters',
          'Raincoats',
          'Costumes',
          'Boots',
        ],
        'metadata': {'color': '#E91E63', 'icon': 'clothes'},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Toys',
        'displayName': 'Toys',
        'description': 'Fun toys for pets',
        'isActive': true,
        'sortOrder': 5,
        'subcategories': [
          'Chew Toys',
          'Rope Toys',
          'Balls',
          'Interactive Toys',
          'Plush Toys',
        ],
        'metadata': {'color': '#9C27B0', 'icon': 'toys'},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Health',
        'displayName': 'Health',
        'description': 'Health and wellness products',
        'isActive': true,
        'sortOrder': 6,
        'subcategories': [
          'Vitamins',
          'Supplements',
          'Flea & Tick',
          'First Aid',
          'Calming Products',
        ],
        'metadata': {'color': '#F44336', 'icon': 'health'},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];
    try {
      // Check if categories already exist
      final existingCategories = await _firestore
          .collection('categories')
          .limit(1)
          .get();

      if (existingCategories.docs.isEmpty) {
        // Add sample categories only if collection is empty
        for (var category in sampleCategories) {
          await _firestore.collection('categories').add(category);
        }
        print('Sample categories added to Firestore successfully!');
      } else {
        print('Categories already exist in Firestore. Skipping seed data.');
      }
    } catch (e) {
      print('Error seeding categories: $e');
    }
  }

  // Add sample products to Firestore
  static Future<void> seedProducts() async {
    final sampleProducts = [
      {
        'name': 'SNOOZA-Dog Bed',
        'description':
            'Snooza Ortho Sofa is designed for older dogs who find it difficult to get in and out of their regular beds or baskets. The comfortable and durable Ortho Sofa has a secure orthopaedic support foam base that is stable and comfortable, as well as soft padding that provides a sense of comfort and calm for your pet.',
        'category': 'Equipment',
        'subcategory': 'Beds',
        'price': 4500,
        'oldPrice': 7300,
        'currency': 'RSD',
        'images': ['assets/images/product.jpg'],
        'primaryImage': 'assets/images/product.jpg',
        'brand': 'Snooza',
        'sku': 'PS-SNZ-BED-001',
        'stock': 18,
        'isActive': true,
        'isFeatured': true,
        'isOnSale': true,
        'rating': 4.7,
        'reviewCount': 112,
        'tags': ['popular', 'orthopedic', 'comfort', 'senior-dog'],
        'specifications': {
          'petType': 'Dog',
          'material': 'Foam + Fabric',
          'size': 'M',
          'color': 'Neutral',
          'washableCover': true,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'searchKeywords': [
          'snooza',
          'dog',
          'bed',
          'ortho',
          'sofa',
          'orthopedic',
          'comfort',
        ],
      },
      {
        'name': 'Essential Dog Hoodie',
        'description':
            'Signature Spark Paws Butterstretch™ fabric. Very stretchy, durable, soft texture. Fluffy cozy fleece interior. Machine wash cold, line dry. 55% Cotton, 40% Polyester, 5% Spandex',
        'category': 'Clothes',
        'subcategory': 'Hoodies',
        'price': 2300,
        'oldPrice': 3700,
        'currency': 'RSD',
        'images': ['assets/images/product3.jpg'],
        'primaryImage': 'assets/images/product3.jpg',
        'brand': 'Spark Paws',
        'sku': 'PS-SP-hoodie-001',
        'stock': 25,
        'isActive': true,
        'isFeatured': true,
        'isOnSale': true,
        'rating': 4.5,
        'reviewCount': 86,
        'tags': ['warm', 'winter', 'stretch', 'soft', 'trending'],
        'specifications': {
          'petType': 'Dog',
          'material': '55% Cotton / 40% Polyester / 5% Spandex',
          'fit': 'Stretch',
          'care': 'Machine wash cold, line dry',
          'sizes': ['XS', 'S', 'M', 'L', 'XL'],
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'searchKeywords': [
          'hoodie',
          'dog',
          'spark',
          'paws',
          'warm',
          'fleece',
          'winter',
        ],
      },

      {
        'name': 'Zolux Wild Rope',
        'description': 'Made from beech wood and 100% cotton rope',
        'category': 'Toys',
        'subcategory': 'Rope Toys',
        'price': 1030,
        'oldPrice': 1700,
        'currency': 'RSD',
        'images': ['assets/images/product2.jpg'],
        'primaryImage': 'assets/images/product2.jpg',
        'brand': 'Zolux',
        'sku': 'PS-ZLX-ROPE-001',
        'stock': 40,
        'isActive': true,
        'isFeatured': false,
        'isOnSale': true,
        'rating': 4.3,
        'reviewCount': 59,
        'tags': ['durable', 'chew', 'training', 'playtime'],
        'specifications': {
          'petType': 'Dog',
          'material': 'Beech wood + 100% cotton rope',
          'toyType': 'Chew / Tug',
          'recommendedFor': 'Small–Medium dogs',
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'searchKeywords': [
          'zolux',
          'rope',
          'toy',
          'tug',
          'chew',
          'wood',
          'cotton',
        ],
      },
      {
        'name': 'Orijen Puppy',
        'description':
            'Orijen Puppy provides biologically appropriate nutrition for puppies, with an emphasis on a high protein content derived from fresh chicken, turkey, fish, and chicken offal.',
        'category': 'Food',
        'subcategory': 'Dry Food',
        'price': 13500,
        'oldPrice': 15600,
        'currency': 'RSD',
        'images': ['assets/images/products2.jpg'],
        'primaryImage': 'assets/images/products2.jpg',
        'brand': 'Orijen',
        'sku': 'PS-ORJ-PUPPY-001',
        'stock': 12,
        'isActive': true,
        'isFeatured': true,
        'isOnSale': true,
        'rating': 4.8,
        'reviewCount': 140,
        'tags': ['premium', 'high-protein', 'puppy', 'grain-free'],
        'specifications': {
          'petType': 'Dog',
          'lifeStage': 'Puppy',
          'foodType': 'Dry food',
          'proteinFocus': 'Chicken / Turkey / Fish',
          'weight': '2kg',
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'searchKeywords': [
          'orijen',
          'puppy',
          'food',
          'dry',
          'premium',
          'protein',
          'grain-free',
        ],
      },
    ];

    try {
      // Check if products already exist
      final existingProducts = await _firestore
          .collection('products')
          .limit(1)
          .get();

      if (existingProducts.docs.isEmpty) {
        // Add sample products only if collection is empty
        for (var product in sampleProducts) {
          await _firestore.collection('products').add(product);
        }

        print('Sample products added to Firestore successfully!');
      } else {
        print('Products already exist in Firestore. Skipping seed data.');
      }
    } catch (e) {
      print('Error seeding products: $e');
    }
  }
}
