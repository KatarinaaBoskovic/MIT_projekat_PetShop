import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:petshop/controllers/currency_controller.dart';
import 'package:petshop/utils/app_image.dart';
import 'package:petshop/utils/app_textstyles.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyCtrl = Get.find<CurrencyController>();
    final currency = currencyCtrl.selectedCurrency.value;
    final df = DateFormat('dd.MM.yyyy • HH:mm');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'Order Details',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Order not found.'));
          }

          final data = snap.data!.data()!;
          final status = (data['status'] ?? 'pending').toString();
          final userEmail = (data['userEmail'] ?? '').toString();
          final userId = (data['userId'] ?? '').toString();

          final subtotalRsd = (data['subtotal'] ?? 0).toDouble();
          final shippingRsd = (data['shipping'] ?? 0).toDouble();
          final totalRsd = (data['total'] ?? 0).toDouble();

          final createdAtRaw = data['createdAt'];
          DateTime? createdAt;
          if (createdAtRaw is Timestamp) createdAt = createdAtRaw.toDate();

          final itemsRaw = (data['items'] as List?) ?? const [];
          final items = itemsRaw
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

          String money(double rsd) {
            final converted = currencyCtrl.convertFromRsd(rsd, currency);
            return currencyCtrl.format(converted, currency);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #$orderId',
                      style: AppTextStyle.withColor(
                        AppTextStyle.h3,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Status: ${_prettyStatus(status)}',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyMedium,
                        isDark ? Colors.grey[400]! : Colors.grey[700]!,
                      ),
                    ),
                    if (createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Created: ${df.format(createdAt)}',
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodyMedium,
                          isDark ? Colors.grey[400]! : Colors.grey[700]!,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'User: ${userEmail.isNotEmpty ? userEmail : userId}',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodySmall,
                        isDark ? Colors.grey[400]! : Colors.grey[700]!,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Items
              Text(
                'Items',
                style: AppTextStyle.withColor(
                  AppTextStyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 10),

              ...items.map((it) {
                final name = (it['name'] ?? '').toString();
                final qty = (it['quantity'] ?? 1) as int;
                final price = (it['price'] ?? 0).toDouble();
                final image = _pickImage(
                  it['image'] ??
                      it['imageUrl'] ??
                      it['primaryImage'] ??
                      it['images'],
                );
                final selectedSize = it['selectedSize']?.toString();
                final selectedColor = it['selectedColor']?.toString();

                final lineTotal = price * qty;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      // image (optional)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 62,
                          height: 62,
                          child: AppImage(
                            image,
                            width: 62,
                            height: 62,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isEmpty ? 'Item' : name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.withColor(
                                AppTextStyle.bodyLarge,
                                Theme.of(context).textTheme.bodyLarge!.color!,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Qty: $qty • ${money(price)}',
                              style: AppTextStyle.withColor(
                                AppTextStyle.bodyMedium,
                                isDark ? Colors.grey[400]! : Colors.grey[600]!,
                              ),
                            ),
                            if ((selectedSize != null &&
                                    selectedSize.isNotEmpty) ||
                                (selectedColor != null &&
                                    selectedColor.isNotEmpty)) ...[
                              const SizedBox(height: 4),
                              Text(
                                [
                                  if (selectedSize != null &&
                                      selectedSize.isNotEmpty)
                                    'Size: $selectedSize',
                                  if (selectedColor != null &&
                                      selectedColor.isNotEmpty)
                                    'Color: $selectedColor',
                                ].join(' • '),
                                style: AppTextStyle.withColor(
                                  AppTextStyle.bodySmall,
                                  isDark
                                      ? Colors.grey[400]!
                                      : Colors.grey[600]!,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        money(lineTotal),
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodyLarge,
                          Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),

              // Totals
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _row(context, 'Subtotal', money(subtotalRsd)),
                    const SizedBox(height: 8),
                    _row(context, 'Shipping', money(shippingRsd)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    _row(context, 'Total', money(totalRsd), isTotal: true),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _prettyStatus(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return s;
    }
  }

  String _pickImage(dynamic v) {
    if (v == null) return '';

    // ako je lista 
    if (v is List && v.isNotEmpty) {
      return (v.first ?? '').toString().trim();
    }

    // ako je string
    if (v is String) return v.trim();

    // fallback
    return v.toString().trim();
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final style = isTotal ? AppTextStyle.h3 : AppTextStyle.bodyLarge;
    final color = isTotal
        ? Theme.of(context).primaryColor
        : Theme.of(context).textTheme.bodyLarge!.color!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyle.withColor(style, color)),
        Text(value, style: AppTextStyle.withColor(style, color)),
      ],
    );
  }
}
