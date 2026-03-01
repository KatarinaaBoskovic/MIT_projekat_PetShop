// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _usersCollection = 'users';

  // Create user document in Firestore
  static Future<bool> createUserDocument({
    required String uid,
    required String email,
    required String name,
  }) async {
    try {
      final userData = {
        'uid': uid,
        'email': email,
        'name': name,
        'displayName': name,

        'role': 'user',
        'blocked': false,

        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'profileImageUrl': null,
        'avatarId': null,
        'phoneNumber': null,
        'dateOfBirth': null,
        'gender': null,
        'addresses': [],
        'preferences': {
          'notifications': true,
          'emailUpdates': true,
          'darkMode': false,
          'currency': 'RSD',
        },
      };

      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .set(userData, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user document from firestore
  static Future<Map<String, dynamic>?> getUserDocument(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();

      if (doc.exists) {
        return doc.data()!;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user document
  static Future<bool> updateUserDocument({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection(_usersCollection).doc(uid).update(data);

      return true;
    } catch (e) {
      return false;
    }
  }

  //update user profile
  static Future<bool> updateUserProfile({
    required String uid,
    String? name,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    String? profileImageUrl,
    int? avatarId,
  }) async {
    try {
      // Check if user document exists first
      final docExists = await userDocumentExists(uid);

      if (!docExists) {
        // Create user document if it doesn't exist
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final createSuccess = await createUserDocument(
            uid: uid,
            email: user.email ?? '',
            name: name ?? user.displayName ?? 'User',
          );

          if (!createSuccess) {
            print('Failed to create user document');
            return false;
          }
        } else {
          print('No authenticated user found');
          return false;
        }
      }
      final Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) {
        updateData['name'] = name;
        updateData['displayName'] = name;
      }

      if (phoneNumber != null) {
        updateData['phoneNumber'] = phoneNumber;
      }

      if (dateOfBirth != null) {
        updateData['dateOfBirth'] = dateOfBirth;
      }

      if (gender != null) {
        updateData['gender'] = gender;
      }

      if (profileImageUrl != null) {
        updateData['profileImageUrl'] = profileImageUrl;
      }
      if (avatarId != null) {
        updateData['avatarId'] = avatarId;
      }

      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .set(updateData, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Add user address
  static Future<bool> addUserAddress({
    required String uid,
    required Map<String, dynamic> address,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'addresses': FieldValue.arrayUnion([address]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Update user preferences
  static Future<bool> updateUserPreferences({
    required String uid,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'preferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete user document (for account deletion)
  static Future<bool> deleteUserDocument(String uid) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if user document exists
  static Future<bool> userDocumentExists(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  //get user stream for real-time updates
  static Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(
    String uid,
  ) {
    return _firestore.collection(_usersCollection).doc(uid).snapshots();
  }

  static Future<bool> updateUserCurrency({
    required String uid,
    required String currency,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'preferences.currency': currency,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating currency: $e');
      return false;
    }
  }

  static Future<bool> ensureUserDocument({
    required String uid,
    required String email,
    required String name,
  }) async {
    try {
      final ref = _firestore.collection(_usersCollection).doc(uid);
      final snap = await ref.get();

      if (!snap.exists) {
        final userData = {
          'uid': uid,
          'email': email,
          'name': name,
          'displayName': name,
          'role': 'user',
          'blocked': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'addresses': [],
          'preferences': {
            'notifications': true,
            'emailUpdates': true,
            'darkMode': false,
            'currency': 'RSD',
          },
        };

        await ref.set(userData, SetOptions(merge: true));
      } else {
        final data = snap.data() ?? {};
        final patch = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (!data.containsKey('role')) patch['role'] = 'user';
        if (!data.containsKey('blocked')) patch['blocked'] = false;

        await ref.set(patch, SetOptions(merge: true));
      }

      return true;
    } catch (e) {
      print('ensureUserDocument error: $e');
      return false;
    }
  }

  static Future<bool> isUserBlocked(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      final data = doc.data();
      return data?['blocked'] == true;
    } catch (e) {
      print('isUserBlocked error: $e');
      return false;
    }
  }

  // Stream svih korisnika (admin)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUsersStream() {
    return _firestore
        .collection(_usersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Admin update korisnika: blocked/role (i sl.)
  static Future<bool> adminUpdateUser({
    required String uid,
    bool? blocked,
    String? role,
  }) async {
    try {
      final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
      if (blocked != null) data['blocked'] = blocked;
      if (role != null) data['role'] = role;

      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .set(data, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('adminUpdateUser error: $e');
      return false;
    }
  }
}
