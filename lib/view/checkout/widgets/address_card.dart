import 'package:flutter/material.dart';
import 'package:petshop/utils/app_textstyles.dart';
import 'package:petshop/view/shipping_address/models/address.dart'
    as my_address;

class AddressCard extends StatelessWidget {
  //obavezno polje za adresu
  final my_address.Address address;

  const AddressCard({
    super.key,
    required this.address, //Zahteva adresu pri kreiranju
  });

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
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      //Koristi labelu iz objekta (npr. Home, Work...)
                      address.label,
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyLarge,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      //Koristi stvarnu adresu iz baze
                      address.fullAddress,
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodySmall,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
