import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/address_controller.dart';
import 'package:petshop/utils/app_textstyles.dart';
import 'package:petshop/view/shipping_address/models/address.dart';
import 'package:petshop/view/shipping_address/widgets/address_card.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final _controller = Get.find<AddressController>();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          'Shipping Address',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddAddressBottomSheet(context),
            icon: Icon(
              Icons.add_circle_outline,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: GetBuilder<AddressController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${controller.errorMessage}',
                    style: AppTextStyle.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadAddresses(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No addresses found', style: AppTextStyle.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddAddressBottomSheet(context),
                    child: const Text('Add Address'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.addresses.length,
            itemBuilder: (context, index) => _buildAddressCard(context, index),
          );
        },
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, int index) {
    final address = _controller.addresses[index];
    return AddressCard(
      address: address,
      onDelete: () => _showDeleteConfirmation(context, address.id),
      onEdit: () => _showEditAddressBottomSheet(context, address),
      onSetDefault: () async {
        final success = await _controller.setDefaultAddress(address.id);
        if (success) {
          Get.snackbar('Success', 'Default address updated');
        } else {
          Get.snackbar('Error', 'Failed to update default address');
        }
      },
    );
  }

  void _showAddAddressBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Text controllers for form fields
    final labelController = TextEditingController();
    final fullAddressController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final zipCodeController = TextEditingController();

    // Address type selection
    final selectedType = AddressType.home.obs;

    // Set as default checkbox
    final isDefault = (_controller.addresses.isEmpty).obs;

    Get.bottomSheet(
  AnimatedPadding(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOut,
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
    ),
    child: DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Address',
                      style: AppTextStyle.withColor(
                        AppTextStyle.h3,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: labelController,
                  decoration: InputDecoration(
                    labelText: 'Label (e.g., Home, Office)',
                    prefixIcon: const Icon(Icons.label_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Text('Address Type', style: AppTextStyle.bodyMedium),
                const SizedBox(height: 8),

                Obx(
                  () => Row(
                    children: [
                      _buildAddressTypeChip(
                        context,
                        'Home',
                        AddressType.home,
                        selectedType.value,
                        () => selectedType.value = AddressType.home,
                      ),
                      const SizedBox(width: 8),
                      _buildAddressTypeChip(
                        context,
                        'Office',
                        AddressType.office,
                        selectedType.value,
                        () => selectedType.value = AddressType.office,
                      ),
                      const SizedBox(width: 8),
                      _buildAddressTypeChip(
                        context,
                        'Other',
                        AddressType.other,
                        selectedType.value,
                        () => selectedType.value = AddressType.other,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Obx(
                  () => CheckboxListTile(
                    title: const Text('Set as default address'),
                    value: isDefault.value,
                    onChanged: (value) => isDefault.value = value ?? false,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: fullAddressController,
                  decoration: InputDecoration(
                    labelText: 'Full Address',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'City',
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: stateController,
                        decoration: InputDecoration(
                          labelText: 'State',
                          prefixIcon: const Icon(Icons.map_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: zipCodeController,
                        decoration: InputDecoration(
                          labelText: 'ZIP Code',
                          prefixIcon: const Icon(Icons.pin_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: () {
                    final isLoading = RxBool(false);

                    return ElevatedButton(
                      onPressed: () {
                        if (labelController.text.isEmpty ||
                            fullAddressController.text.isEmpty ||
                            cityController.text.isEmpty ||
                            stateController.text.isEmpty ||
                            zipCodeController.text.isEmpty) {
                          Get.snackbar('Error', 'Please fill all fields');
                          return;
                        }

                        final newAddress = Address(
                          id: '',
                          label: labelController.text,
                          fullAddress: fullAddressController.text,
                          city: cityController.text,
                          state: stateController.text,
                          zipCode: zipCodeController.text,
                          isDefault: isDefault.value,
                          type: selectedType.value,
                        );

                        isLoading.value = true;

                        _controller.addAddress(newAddress).then((success) {
                          isLoading.value = false;

                          if (success) {
                            Get.back();
                            Get.snackbar('Success', 'Address added successfully');
                          } else {
                            Get.snackbar('Error', 'Failed to add address');
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Obx(
                        () => isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save Address',
                                style: AppTextStyle.withColor(
                                  AppTextStyle.buttonMedium,
                                  Colors.white,
                                ),
                              ),
                      ),
                    );
                  }(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    ),
  ),
  isScrollControlled: true,
);
  }

  Widget _buildAddressTypeChip(
    BuildContext context,
    String label,
    AddressType type,
    AddressType selectedType,
    VoidCallback onTap,
  ) {
    final isSelected = type == selectedType;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyle.withColor(
            AppTextStyle.bodyMedium,
            isSelected
                ? Colors.white
                : Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
      ),
    );
  }

  void _showEditAddressBottomSheet(BuildContext context, Address address) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Text controllers for form fields
    final labelController = TextEditingController(text: address.label);
    final fullAddressController = TextEditingController(
      text: address.fullAddress,
    );
    final cityController = TextEditingController(text: address.city);
    final stateController = TextEditingController(text: address.state);
    final zipCodeController = TextEditingController(text: address.zipCode);

    // Address type selection
    final selectedType = address.type.obs;

    // Set as default checkbox
    final isDefault = address.isDefault.obs;
    Get.bottomSheet(
  AnimatedPadding(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOut,
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
    ),
    child: DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ OVO JE TVOJ ISTI SADRŽAJ, NIŠTA DRUGO NE MENJAŠ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Address',
                      style: AppTextStyle.withColor(
                        AppTextStyle.h3,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: labelController,
                  decoration: InputDecoration(
                    labelText: 'Label (e.g., Home, Office)',
                    prefixIcon: const Icon(Icons.label_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Address Type', style: AppTextStyle.bodyMedium),
                const SizedBox(height: 8),
                Obx(
                  () => Row(
                    children: [
                      _buildAddressTypeChip(
                        context,
                        'Home',
                        AddressType.home,
                        selectedType.value,
                        () => selectedType.value = AddressType.home,
                      ),
                      const SizedBox(width: 8),
                      _buildAddressTypeChip(
                        context,
                        'Office',
                        AddressType.office,
                        selectedType.value,
                        () => selectedType.value = AddressType.office,
                      ),
                      const SizedBox(width: 8),
                      _buildAddressTypeChip(
                        context,
                        'Other',
                        AddressType.other,
                        selectedType.value,
                        () => selectedType.value = AddressType.other,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => CheckboxListTile(
                    title: Text(
                      'Set as default address',
                      style: AppTextStyle.bodyMedium,
                    ),
                    value: isDefault.value,
                    onChanged: (value) => isDefault.value = value ?? false,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: fullAddressController,
                  decoration: InputDecoration(
                    labelText: 'Full Address',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'City',
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: stateController,
                        decoration: InputDecoration(
                          labelText: 'State',
                          prefixIcon: const Icon(Icons.map_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: zipCodeController,
                        decoration: InputDecoration(
                          labelText: 'ZIP Code',
                          prefixIcon: const Icon(Icons.pin_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: () {
                    final isLoading = RxBool(false);

                    return ElevatedButton(
                      onPressed: () {
                        if (labelController.text.isEmpty ||
                            fullAddressController.text.isEmpty ||
                            cityController.text.isEmpty ||
                            stateController.text.isEmpty ||
                            zipCodeController.text.isEmpty) {
                          Get.snackbar('Error', 'Please fill all fields');
                          return;
                        }

                        final updatedAddress = Address(
                          id: address.id,
                          label: labelController.text,
                          fullAddress: fullAddressController.text,
                          city: cityController.text,
                          state: stateController.text,
                          zipCode: zipCodeController.text,
                          isDefault: isDefault.value,
                          type: selectedType.value,
                        );

                        isLoading.value = true;

                        _controller.updateAddress(updatedAddress).then((success) {
                          isLoading.value = false;

                          if (success) {
                            Get.back();
                            Get.snackbar('Success', 'Address updated successfully');
                          } else {
                            Get.snackbar('Error', 'Failed to update address');
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Obx(
                        () => isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Update Address',
                                style: AppTextStyle.withColor(
                                  AppTextStyle.buttonMedium,
                                  Colors.white,
                                ),
                              ),
                      ),
                    );
                  }(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    ),
  ),
  isScrollControlled: true,
);
  }

  void _showDeleteConfirmation(BuildContext context, String addressId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete Address',
              style: AppTextStyle.withColor(
                AppTextStyle.h3,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to delete this address?',
              textAlign: TextAlign.center,
              style: AppTextStyle.withColor(
                AppTextStyle.bodyMedium,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                () {
                  //Create loading state otside onPressed
                  final isLoading = RxBool(false);

                  return Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Set loading to true
                        isLoading.value = true;

                        _controller.deleteAddress(addressId).then((success) {
                          // set loading to false
                          isLoading.value = false;

                          Get.back(); // close dialog

                          if (success) {
                            Get.snackbar(
                              'Success',
                              'Address deleted successfully',
                            );
                          } else {
                            Get.snackbar('Error', 'Failed to delete address');
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Obx(
                        () => isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Delete',
                                style: AppTextStyle.withColor(
                                  AppTextStyle.buttonMedium,
                                  Colors.white,
                                ),
                              ),
                      ),
                    ),
                  );
                }(),
              ],
            ),
          ],
        ),
      ),
      barrierColor: Colors.black54,
    );
  }

  
}
