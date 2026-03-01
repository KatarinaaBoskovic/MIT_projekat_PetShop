import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/auth_controller.dart';
import 'package:petshop/utils/app_textstyles.dart';
import 'package:petshop/view/my_orders/model/order.dart';
import 'package:petshop/view/my_orders/repository/order_repository.dart';
import 'package:petshop/view/my_orders/view/widgets/order_card.dart';
import 'package:petshop/view/order_details/screens/order_details_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  final OrderRepository _repository = OrderRepository();
  MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Get.find<AuthController>();
    final userId = auth.user?.uid;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          title: Text(
            'My Orders',
            style: AppTextStyle.withColor(
              AppTextStyle.h3,
              isDark ? Colors.white : Colors.black,
            ),
          ),
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: userId == null
            ? const Center(child: Text('Please sign in to view your orders.'))
            : StreamBuilder<List<Order>>(
                stream: _repository.streamMyOrders(userId),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }

                  final orders = snap.data ?? [];

                  final active = orders
                      .where((o) => o.tabStatus == OrderStatus.active)
                      .toList();
                  final completed = orders
                      .where((o) => o.tabStatus == OrderStatus.completed)
                      .toList();
                  final cancelled = orders
                      .where((o) => o.tabStatus == OrderStatus.cancelled)
                      .toList();

                  return TabBarView(
                    children: [
                      _buildOrderList(context, active),
                      _buildOrderList(context, completed),
                      _buildOrderList(context, cancelled),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) => OrderCard(
        order: orders[index],
        onViewDetails: () {
          Get.to(() => OrderDetailsScreen(orderId: orders[index].id));
        },
      ),
    );
  }
}
