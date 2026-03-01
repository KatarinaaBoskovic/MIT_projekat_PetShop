import 'package:get/get.dart';
import 'package:petshop/services/address_firestore_service.dart';
import 'package:petshop/view/shipping_address/models/address.dart';

class AddressController extends GetxController {
  final AddressFirestoreService _addressService = AddressFirestoreService();

  // Observable variables
  final RxList<Address> _addresses = <Address>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters
  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;

  // Clear addresses (used when user logs out)
  void clearAddresses() {
    _addresses.clear();
    _hasError.value = false;
    _errorMessage.value = '';
    update(); // Notify listeners
  }

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  // Load all addresses from Firestore
  Future<void> loadAddresses() async {
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      final addresses = await _addressService.getAddresses();
      _addresses.assignAll(addresses);
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Failed to load addresses: $e';
    } finally {
      _isLoading.value = false;
      update(); // Notify listeners
    }
  }

  // Add a new address
  Future<bool> addAddress(Address address) async {
    _isLoading.value = true;
    update();

    try {
      final success = await _addressService.addAddress(address);
      if (success) {
        await loadAddresses(); // Refresh the list
        return true;
      }
      return false;
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Failed to add address: $e';
      update();
      return false;
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  // Update an existing address
  Future<bool> updateAddress(Address address) async {
    _isLoading.value = true;
    update();

    try {
      final success = await _addressService.updateAddress(address);
      if (success) {
        await loadAddresses(); // Refresh the list
        return true;
      }
      return false;
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Failed to update address: $e';
      update();
      return false;
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  // Delete an address
  Future<bool> deleteAddress(String addressId) async {
    _isLoading.value = true;
    update();

    try {
      final success = await _addressService.deleteAddress(addressId);
      if (success) {
        await loadAddresses();
        return true;
      }
      return false;
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Failed to delete address: $e';
      update();
      return false;
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  // Set an address as default
  Future<bool> setDefaultAddress(String addressId) async {
    _isLoading.value = true;
    update();

    try {
      final success = await _addressService.setDefaultAddress(addressId);
      if (success) {
        await loadAddresses();
        return true;
      }
      return false;
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Failed to set default address: $e';
      update();
      return false;
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  final Rxn<Address> selectedAddress = Rxn<Address>();

  void selectAddress(Address address) {
    selectedAddress.value = address;
    update();
  }
}
