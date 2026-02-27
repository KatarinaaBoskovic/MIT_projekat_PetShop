// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petshop/view/shipping_address/models/address.dart';

class AddressFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _addressesCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return _firestore.collection('users').doc(userId).collection('addresses');
  }

  // Get all addresses
  Future<List<Address>> getAddresses() async {
    try {
      // Ensure user is authenticated
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Error: user not authenticated');
        return [];
      }

      final snapshot = await _addressesCollection.get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Address(
          id: doc.id,
          label: data['label'] ?? '',
          fullAddress: data['fullAddress'] ?? '',
          city: data['city'] ?? '',
          state: data['state'] ?? '',
          zipCode: data['zipCode'] ?? '',
          isDefault: data['isDefault'] ?? false,
          type: _getAddressTypeFromString(data['type'] ?? 'home'),
        );
      }).toList();
    } catch (e) {
      print('Error getting addresses: $e');
      return [];
    }
  }

  // Add a new address
  Future<bool> addAddress(Address address) async {
    try {
      // Ensure user is authenticated
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Error: User not authenticated');
        return false;
      }

      // If this is the first address or marked as default, ensure it's the only default
      if (address.isDefault) {
        await _clearOtherDefaultAddresses();
      }
      await _addressesCollection.add({
        'label': address.label,
        'fullAddress': address.fullAddress,
        'city': address.city,
        'state': address.state,
        'zipCode': address.zipCode,
        'isDefault': address.isDefault,
        'type': address.typeString,
        'userId':
            userId, // Add userId to ensure data belongs to the correct user
      });

      return true;
    } catch (e) {
      print('Error adding address: $e');
      return false;
    }
  }

  // Update an address
  Future<bool> updateAddress(Address address) async {
    try {
      // Ensure user is authenticated
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Error: User not authenticated');
        return false;
      }

      // If marked as default, ensure it's the only default
      if (address.isDefault) {
        await _clearOtherDefaultAddresses(exceptId: address.id);
      }

      await _addressesCollection.doc(address.id).update({
        'label': address.label,
        'fullAddress': address.fullAddress,
        'city': address.city,
        'state': address.state,
        'zipCode': address.zipCode,
        'isDefault': address.isDefault,
        'type': address.typeString,
        'userId': userId, // Ensure userId is updated
      });

      return true;
    } catch (e) {
      print('Error updating address: $e');
      return false;
    }
  }

  // Delete an address
  Future<bool> deleteAddress(String addressId) async {
    try {
      // Ensure user is authenticated
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Error: User not authenticated');
        return false;
      }

      await _addressesCollection.doc(addressId).delete();
      return true;
    } catch (e) {
      print('Error deleting address: $e');
      return false;
    }
  }

  // Set an address as default
  Future<bool> setDefaultAddress(String addressId) async {
    try {
      // Ensure user is authenticated
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Error: User not authenticated');
        return false;
      }

      // Clear other default addresses
      await _clearOtherDefaultAddresses();

      // set this address as default
      await _addressesCollection.doc(addressId).update({
        'isDefault': true,
        'userId': userId, // Ensure userId is updated
      });
      return true;
    } catch (e) {
      print('Error setting default address: $e');
      return false;
    }
  }

  // Helper method to clear other default addresses
  Future<void> _clearOtherDefaultAddresses({String? exceptId}) async {
    final snapshot = await _addressesCollection
        .where('isDefault', isEqualTo: true)
        .get();

    for (var doc in snapshot.docs) {
      if (exceptId == null || doc.id != exceptId) {
        await doc.reference.update({'isDefault': false});
      }
    }
  }

  // Helper method to convert string to AddressType enum
  AddressType _getAddressTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return AddressType.home;
      case 'office':
        return AddressType.office;
      case 'other':
        return AddressType.other;
      default:
        return AddressType.home;
    }
  }
}
