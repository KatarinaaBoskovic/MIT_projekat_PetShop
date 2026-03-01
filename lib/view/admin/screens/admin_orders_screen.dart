import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:petshop/services/orders_firestore_service.dart';
import 'package:petshop/view/order_details/screens/order_details_screen.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  static const statuses = [
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd.MM.yyyy HH:mm');

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: OrdersFirestoreService.streamAllOrders(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No orders.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final d = docs[i];
            final o = d.data();
            
            final userId = (o['userId'] ?? '').toString();
            final userEmail = (o['userEmail'] ?? '').toString();
            final status = (o['status'] ?? 'pending').toString();
            final total = (o['total'] ?? 0).toDouble();

            DateTime? createdAt;
            final rawCreated = o['createdAt'];
            if (rawCreated is Timestamp) createdAt = rawCreated.toDate();

            return InkWell(
              onTap: () {
                Get.to(() => OrderDetailsScreen(orderId: d.id));
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order: ${d.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text('User: ${userEmail.isNotEmpty ? userEmail : userId}'),
                    if (createdAt != null)
                      Text('Created: ${df.format(createdAt)}'),
                    const SizedBox(height: 6),
                    Text('Total: ${total.toStringAsFixed(2)} RSD'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Status: '),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: statuses.contains(status) ? status : 'pending',
                          items: statuses
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                          onChanged: (newStatus) async {
                            if (newStatus == null) return;
                            await OrdersFirestoreService.updateOrderStatus(
                              d.id,
                              newStatus,
                            );
                            Get.snackbar('Updated', 'Status set to $newStatus');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
