import 'package:flutter/material.dart';
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
      child: Column(
        children: [_buildSummaryRow(context, 'Subtotal', '5999 RSD'),
        const SizedBox(height: 8),
        _buildSummaryRow(context, 'Shipping', '130 RSD'),
        const SizedBox(height: 8),
         _buildSummaryRow(context, 'Tax', '5400 RSD'),
         const Padding(padding: EdgeInsets.symmetric(vertical: 12),
         child: Divider(),
         ),
         _buildSummaryRow(context, 'Total', '11529 RSD',isTotal: true),

        ],
      ),
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
