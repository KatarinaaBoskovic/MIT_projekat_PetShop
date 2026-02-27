import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/cart_controller.dart';
import 'package:petshop/controllers/currency_controller.dart';
import 'package:petshop/utils/app_textstyles.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final cart = Get.find<CartController>();
        final currencyCtrl = Get.find<CurrencyController>();
        final currency = currencyCtrl.selectedCurrency.value;

        final subtotalRsd = cart.total.toDouble();

        const shippingRsd = 130.0;
        const taxRsd = 0.0;

        final totalRsd = subtotalRsd + shippingRsd + taxRsd;

        final subtotal = currencyCtrl.convertFromRsd(subtotalRsd, currency);
        final shipping = currencyCtrl.convertFromRsd(shippingRsd, currency);
        final tax = currencyCtrl.convertFromRsd(taxRsd, currency);
        final total = currencyCtrl.convertFromRsd(totalRsd, currency);

        return Column(
          children: [
            _buildSummaryRow(
              context,
              'Subtotal',
              currencyCtrl.format(subtotal, currency),
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              'Shipping',
              currencyCtrl.format(shipping, currency),
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              'Tax',
              currencyCtrl.format(tax, currency),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            _buildSummaryRow(
              context,
              'Total',
              currencyCtrl.format(total, currency),
              isTotal: true,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final textStyle = isTotal ? AppTextStyle.h3 : AppTextStyle.bodyLarge;

    final color = isTotal
        ? Theme.of(context).primaryColor
        : Theme.of(context).textTheme.bodyLarge!.color!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyle.withColor(textStyle, color)),
        Text(value, style: AppTextStyle.withColor(textStyle, color)),
      ],
    );
  }
}
