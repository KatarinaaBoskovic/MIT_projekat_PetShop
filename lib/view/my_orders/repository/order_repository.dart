import 'package:petshop/services/orders_firestore_service.dart';
import 'package:petshop/view/my_orders/model/order.dart';

class OrderRepository {
  Stream<List<Order>> streamMyOrders(String userId) {
    return OrdersFirestoreService.streamMyOrders(userId).map((snapshot) {
      return snapshot.docs
          .map((d) => Order.fromFirestore(d.data(), d.id))
          .toList();
    });
  }
}
