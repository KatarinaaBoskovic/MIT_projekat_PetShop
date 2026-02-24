import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petshop/models/product.dart';

class CartItem {
  final String id;
  final String userId;
  final String productId;
  final Product product;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;
  final Map<String, dynamic> customizations;
  final DateTime addedAt;
  final DateTime updatedAt;

  const CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.product,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
    this.customizations = const {},
    required this.addedAt,
    required this.updatedAt,
  });

  // Create CartItem from Firestore document
  factory CartItem.fromFirestore(Map<String, dynamic> data, String id) {
    return CartItem(
      id: id,
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      product: Product.fromFirestore(
        Map<String, dynamic>.from(data['product'] ?? {}),
        data['productId'] ?? '',
      ),
      quantity: data['quantity'] ?? 1,
      addedAt: data['addedAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
      selectedSize: data['selectedSize'],
      selectedColor: data['selectedColor'],
      customizations: Map<String, dynamic>.from(data['customizations'] ?? {}),
    );
  }

  // Convert CartItem to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'productId': productId,
      'product': product.toFirestore(),
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'customizations': customizations,
      'addedAt': Timestamp.fromDate(addedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Calculate total price for this cart item
  double get totalPrice => product.price * quantity;

  // Calculate savings for this cart item
  double get savings {
    if (product.oldPrice != null && product.oldPrice! > product.price) {
      return (product.oldPrice! - product.price) * quantity;
    }
    return 0.0;
  }

  // Create a copy with updated fields
  CartItem copyWith({
    String? id,
    String? userId,
    String? productId,
    Product? product,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
    Map<String, dynamic>? customizations,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      customizations: customizations ?? this.customizations,
    );
  }

  @override
  String toString() => 'CartItem(${product.name}, qty: $quantity)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
