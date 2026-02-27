import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/currency_controller.dart';

class PriceText extends StatelessWidget {
  final double priceRsd;
  final TextStyle? style;
  final int? rsdDecimals; 

  const PriceText({
    super.key,
    required this.priceRsd,
    this.style,
    this.rsdDecimals,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CurrencyController>();

    return Obx(() {
      final cur = c.selectedCurrency.value;
      final converted = c.convertFromRsd(priceRsd, cur);
      return Text(c.format(converted, cur), style: style);
    });
  }
}
