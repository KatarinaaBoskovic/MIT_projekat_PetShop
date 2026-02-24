import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petshop/models/product.dart';

class WishlistItem {
  final String id;
  final String userId;
  final String productId;
  final Product product;
  final DateTime addedAt;
  final Map<String, dynamic> metadata;

  const WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.product,
    required this.addedAt,
    this.metadata = const {},
  });

  // Create WishlistItem from Firestore document
  factory WishlistItem.fromFirestore(Map<String, dynamic> data, String id) {
    return WishlistItem(
      id: id,
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      product: Product.fromFirestore(
        Map<String, dynamic>.from(data['product'] ?? {}),
        data['productId'] ?? '',
      ),
      addedAt: data['addedAt']?.toDate() ?? DateTime.now(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  // Convert WishlistItem to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'productId': productId,
      'product': product.toFirestore(),
      'addedAt': Timestamp.fromDate(addedAt),
      'metadata': metadata,
    };
  }

  @override
  String toString() => "WishlistItem(${product.name})";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
