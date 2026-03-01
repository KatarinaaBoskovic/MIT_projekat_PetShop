import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petshop/models/cart_item.dart';

class OrdersFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _firestore.collection('orders');

  static Future<String> createOrderFromCart({
    required String userId,
    required String userEmail,
    required List<CartItem> cartItems,
    required double subtotal,
    required double savings,
    required double shipping,
    required double total,
    Map<String, dynamic>? shippingAddress,
    String? note,
  }) async {
    final orderRef = _ordersRef.doc();

    final items = cartItems.map((c) {
      return {
        'productId': c.productId,
        'name': c.product.name,
        'price': c.product.price,
        'oldPrice': c.product.oldPrice,
        'image': c.product.primaryImage,
        'quantity': c.quantity,
        'selectedSize': c.selectedSize,
        'selectedColor': c.selectedColor,
        'customizations': c.customizations,
      };
    }).toList();

    await orderRef.set({
      'userId': userId,
      'userEmail': userEmail,
      'items': items,
      'subtotal': subtotal,
      'savings': savings,
      'shipping': shipping,
      'total': total,
      'status': 'pending',
      'shippingAddress': shippingAddress,
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return orderRef.id;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamMyOrders(
    String userId,
  ) {
    return _ordersRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamAllOrders() {
    return _ordersRef.orderBy('createdAt', descending: true).snapshots();
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    await _ordersRef.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
