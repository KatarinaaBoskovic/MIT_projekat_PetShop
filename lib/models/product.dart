import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final String? subcategory;
  final double price;
  final double? oldPrice;
  final String currency;
  final String description;
  final List<String> images;
  final String primaryImage;
  final String? brand;
  final String? sku;
  final int stock;
  final bool isActive;
  final bool isFeatured;
  final bool isOnSale;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final Map<String, dynamic> specifications;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    required this.price,
    this.oldPrice,
    this.currency = 'RSD',
    required this.images,
    required this.primaryImage,
    required this.description,
    this.brand,
    this.sku,
    this.stock = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.isOnSale = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.tags = const [],
    this.specifications = const {},
    this.createdAt,
    this.updatedAt,
  });

  //Create products from firestore document
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      oldPrice: data['oldPrice']?.toDouble(),
      currency: data['currency'] ?? 'RSD',
      images: List<String>.from(data['images'] ?? []),
      primaryImage: data['primaryImage'] ?? data['images']?[0] ?? '',
      description: data['description'] ?? '',
      brand: data['brand'],
      sku: data['sku'],
      stock: data['stock'] ?? 0,
      isActive: data['isActive'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      isOnSale: data['isOnSale'] ?? false,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      specifications: Map<String, dynamic>.from(data['specifications'] ?? {}),
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }
  // Convert Product to Firestore document
Map<String, dynamic> toFirestore() {
  return {
    'name': name,
    'category': category,
    'subcategory': subcategory,
    'price': price,
    'oldPrice': oldPrice,
    'currency': currency,
    'images': images,
    'primaryImage': primaryImage,
    'brand': brand,
    'sku': sku,
    'stock': stock,
    'isActive': isActive,
    'isFeatured': isFeatured,
    'isOnSale': isOnSale,
    'rating': rating,
    'reviewCount': reviewCount,
    'tags': tags,
    'specifications': specifications,
    'description': description,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
// Backward compatibility getter for imageUrl
String get imageUrl => primaryImage;

// check if product has discount
bool get hasDiscount => oldPrice != null && oldPrice! > price;

// Calculate discount percentage
int get discountPercentage {
  if (!hasDiscount) return 0;
  return (((oldPrice! - price) / oldPrice!) * 100).round();
}

// Check if product is in stock
bool get isInStock => stock > 0;

// Get formatted price
String? get formattedOldPrice =>
    oldPrice != null ? '\$${oldPrice!.toStringAsFixed(2)}' : null;

}
//legacy dummy data for backwark compatibility
final List<Product> products = [
  const Product(
    id:'dummy-1',
    name: 'SNOOZA-Dog Bed',
    category: 'Equipment',
    price: 4500,
    oldPrice: 7300,
    images: ['assets/images/product.jpg'],
    primaryImage: 'assets/images/product.jpg',
    description:
        'Snooza Ortho Sofa is designed for older dogs who find it difficult to get in and out of their regular beds or baskets. The comfortable and durable Ortho Sofa has a secure orthopaedic support foam base that is stable and comfortable, as well as soft padding that provides a sense of comfort and calm for your pet.',
  ),
  const Product(
    id:'dummy-2',
    name: 'Essential Dog Hoodie',
    category: 'Clothes',
    price: 2300,
    oldPrice: 3700,
    images: ['assets/images/product3.jpg'],
    primaryImage: 'assets/images/product3.jpg',
    description:
        'Signature Spark Paws Butterstretch™ fabric. Very stretchy, durable, soft texture. Fluffy cozy fleece interior. Machine wash cold, line dry. 55% Cotton, 40% Polyester, 5% Spandex',
  ),
  const Product(
    id:'dummy-3',
    name: 'Zolux Wild Rope',
    category: 'Toys',
    price: 1030,
    oldPrice: 1700,
    images: ['assets/images/product2.jpg'],
    primaryImage: 'assets/images/product2.jpg',
    description: 'Made from beech wood and 100% cotton rope',
  ),
  const Product(
    id:'dummy-4',
    name: 'Orijen Puppy',
    category: 'Food',
    price: 13500,
    oldPrice: 15600,
    images: ['assets/images/products2.jpg'],
    primaryImage: 'assets/images/products2.jpg',
    description:
        'Orijen Puppy provides biologically appropriate nutrition for puppies, with an emphasis on a high protein content derived from fresh chicken, turkey, fish, and chicken offal.',
  ),

];
