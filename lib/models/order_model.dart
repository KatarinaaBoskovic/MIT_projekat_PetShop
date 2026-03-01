import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String name;
  final double price;
  final double? oldPrice;
  final int quantity;
  final String? imageUrl;
  final String? selectedSize;
  final String? selectedColor;
  final Map<String, dynamic> customizations;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    this.oldPrice,
    required this.quantity,
    this.imageUrl,
    this.selectedSize,
    this.selectedColor,
    this.customizations = const {},
  });

  Map<String, dynamic> toFirestore() => {
    'productId': productId,
    'name': name,
    'price': price,
    'oldPrice': oldPrice,
    'quantity': quantity,
    'imageUrl': imageUrl,
    'selectedSize': selectedSize,
    'selectedColor': selectedColor,
    'customizations': customizations,
  };

  factory OrderItem.fromFirestore(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      oldPrice: data['oldPrice'] == null ? null : (data['oldPrice']).toDouble(),
      quantity: data['quantity'] ?? 1,
      imageUrl: data['imageUrl'],
      selectedSize: data['selectedSize'],
      selectedColor: data['selectedColor'],
      customizations: Map<String, dynamic>.from(data['customizations'] ?? {}),
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double savings;
  final double shipping;
  final double total;
  final String status; // pending/processing/shipped/delivered/cancelled
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.savings,
    required this.shipping,
    required this.total,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'items': items.map((e) => e.toFirestore()).toList(),
    'subtotal': subtotal,
    'savings': savings,
    'shipping': shipping,
    'total': total,
    'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
  };

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    final rawItems = (data['items'] as List?) ?? [];
    return OrderModel(
      id: id,
      userId: data['userId'] ?? '',
      items: rawItems
          .map((e) => OrderItem.fromFirestore(Map<String, dynamic>.from(e)))
          .toList(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      savings: (data['savings'] ?? 0).toDouble(),
      shipping: (data['shipping'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
