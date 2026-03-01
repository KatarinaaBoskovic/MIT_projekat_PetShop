import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { active, completed, cancelled }

class Order {
  final String id;
  final String status; // pending/processing/shipped/delivered/cancelled
  final double total;
  final DateTime? createdAt;

  const Order({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
  });

  factory Order.fromFirestore(Map<String, dynamic> data, String id) {
    final created = data['createdAt'];
    return Order(
      id: id,
      status: (data['status'] ?? 'pending').toString(),
      total: (data['total'] ?? 0).toDouble(),
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }

  OrderStatus get tabStatus {
    final s = status.toLowerCase();
    if (s == 'delivered') return OrderStatus.completed;
    if (s == 'cancelled') return OrderStatus.cancelled;
    return OrderStatus.active; // pending/processing/shipped
  }
}
