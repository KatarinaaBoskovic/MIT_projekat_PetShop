// ignore_for_file: avoid_print
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:petshop/controllers/address_controller.dart';
import 'package:petshop/controllers/currency_controller.dart';
import 'package:petshop/services/firebase_auth_service.dart';
import 'package:petshop/services/firestore_service.dart';

enum PostLoginResult { user, admin, blocked, failed }

class AuthController extends GetxController {
  final _storage = GetStorage();

  final RxBool _isFirstTime = true.obs;
  final RxBool _isLoggedIn = false.obs;
  final Rx<User?> _user = Rx<User?>(null);
  final RxBool _isLoading = false.obs;
  final Rx<Map<String, dynamic>?> _userDocument = Rx<Map<String, dynamic>?>(
    null,
  );
  final RxBool avatarChanged = false.obs;

  final RxBool _isBlocked = false.obs;
  final RxString _role = 'user'.obs;
  final RxString authNotice = ''.obs;

  bool get isBlocked => _isBlocked.value;
  String get role => _role.value;
  bool get isAdmin => _role.value == 'admin';

  bool get isFirstTime => _isFirstTime.value;
  bool get isLoggedIn => _isLoggedIn.value;
  User? get user => _user.value;
  bool get isLoading => _isLoading.value;
  String? get userEmail => _user.value?.email;
  String? get userDisplayName => _user.value?.displayName;
  Map<String, dynamic>? get userDocument => _userDocument.value;
  String? get userName =>
      _userDocument.value?['name'] ?? _user.value?.displayName;
  String? get userPhone => _userDocument.value?['phoneNumber'];
  List<dynamic>? get userAddresses => _userDocument.value?['addresses'];
  Map<String, dynamic>? get userPreferences =>
      _userDocument.value?['preferences'];
  int get avatarId => (_userDocument.value?['avatarId'] as int?) ?? 0;
  final RxString userCurrencyRx = 'RSD'.obs;
  void clearBlockedFlag() => _isBlocked.value = false;
  final RxBool _blockedNotice = false.obs;
  bool get blockedNotice => _blockedNotice.value;

  void clearBlockedNotice() => _blockedNotice.value = false;

  String get userCurrency => userCurrencyRx.value;
  @override
  void onInit() {
    super.onInit();
    _loadInitialState();
    _listenToAuthChanges();
  }

  void _loadInitialState() {
    _isFirstTime.value = _storage.read('isFirstTime') ?? true;

    // Check Firebase auth state insted of local storage
    _user.value = FirebaseAuthService.currentUser;
    _isLoggedIn.value = FirebaseAuthService.isSignedIn;

    // Load user document if user is already signed in
    if (_user.value != null) {
      Future.microtask(() async {
        await _syncUserAfterLogin(_user.value!);
      });
    }
  }

  // Load user document from Firestore
  Future<bool> _loadUserDocument(String uid) async {
    try {
      final userDoc = await FirestoreService.getUserDocument(uid);

      if (userDoc == null) {
        _userDocument.value = null;
        _role.value = 'user';
        _isBlocked.value = false;
        return false;
      }

      _userDocument.value = userDoc;
      _role.value = (userDoc['role'] as String?) ?? 'user';
      _isBlocked.value = userDoc['blocked'] == true;

      final cur =
          (userDoc['preferences']?['currency'] as String?)?.toUpperCase() ??
          'RSD';
      userCurrencyRx.value = cur;

      if (Get.isRegistered<CurrencyController>()) {
        Get.find<CurrencyController>().setCurrency(cur);
      }

      return true;
    } catch (e) {
      print('Error loading user document: $e');
      _userDocument.value = null;
      _role.value = 'user';
      _isBlocked.value = false;
      return false;
    }
  }

  Future<bool> _syncUserAfterLogin(User user) async {
    try {
      final email = user.email ?? '';
      final name = user.displayName ?? 'User';

      await FirestoreService.ensureUserDocument(
        uid: user.uid,
        email: email,
        name: name,
      );

      await _loadUserDocument(user.uid); // ovde se setuju _role i _isBlocked

      final blockedNow = _isBlocked.value == true;

      if (blockedNow) {
        await FirebaseAuthService.signOut();

        _user.value = null;
        _isLoggedIn.value = false;
        _userDocument.value = null;

        _isBlocked.value = true;
        _role.value = 'user';

        userCurrencyRx.value = 'RSD';
        if (Get.isRegistered<CurrencyController>()) {
          Get.find<CurrencyController>().setCurrency('RSD');
        }
      }

      return blockedNow;
    } catch (e) {
      print('Error syncing user after login: $e');
      return false;
    }
  }

  void _listenToAuthChanges() {
    FirebaseAuthService.authStateChanges.listen((User? user) async {
      _user.value = user;
      _isLoggedIn.value = user != null;

      if (user != null) {
        Map<String, dynamic>? doc;
        try {
          doc = await FirestoreService.getUserDocument(
            user.uid,
          ).timeout(const Duration(seconds: 5), onTimeout: () => null);
        } catch (e) {
          doc = null;
        }

        if (doc == null) {
          await FirebaseAuthService.signOut();

          _user.value = null;
          _isLoggedIn.value = false;
          _userDocument.value = null;
          _isBlocked.value = false;
          _role.value = 'user';

          if (Get.isRegistered<CurrencyController>()) {
            Get.find<CurrencyController>().setCurrency('RSD');
          }
          userCurrencyRx.value = 'RSD';

          if (Get.isRegistered<AddressController>()) {
            Get.find<AddressController>().loadAddresses();
          }

          return;
        }

        _userDocument.value = doc;
        _role.value = (doc['role'] as String?) ?? 'user';
        _isBlocked.value = doc['blocked'] == true;

        final cur =
            (doc['preferences']?['currency'] as String?)?.toUpperCase() ??
            'RSD';
        userCurrencyRx.value = cur;
        if (Get.isRegistered<CurrencyController>()) {
          Get.find<CurrencyController>().setCurrency(cur);
        }

        //  blokiran -> odmah odjavi + poruka + reset state
        if (_isBlocked.value == true) {
          authNotice.value =
              'Your account has been blocked. Contact support.'; // ✅ PRVO
          await FirebaseAuthService.signOut(); // ✅ ONDA signOut
          return;
        }

        if (Get.isRegistered<AddressController>()) {
          Get.find<AddressController>().loadAddresses();
        }
      } else {
        _userDocument.value = null;
        _isBlocked.value = false;
        _role.value = 'user';

        if (Get.isRegistered<CurrencyController>()) {
          Get.find<CurrencyController>().setCurrency('RSD');
        }
        userCurrencyRx.value = 'RSD';

        if (Get.isRegistered<AddressController>()) {
          Get.find<AddressController>().loadAddresses();
        }
      }
    });
  }

  Future<PostLoginResult> resolvePostLogin({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final completer = Completer<PostLoginResult>();

    late Worker w1;
    late Worker w2;

    void finish(PostLoginResult r) {
      if (!completer.isCompleted) completer.complete(r);
      w1.dispose();
      w2.dispose();
    }

    w1 = ever<Map<String, dynamic>?>(_userDocument, (doc) {
      if (doc == null) return;

      final blocked = doc['blocked'] == true;
      final role = (doc['role'] as String?) ?? 'user';

      if (blocked) return finish(PostLoginResult.blocked);
      if (role == 'admin') return finish(PostLoginResult.admin);
      return finish(PostLoginResult.user);
    });

    w2 = ever<bool>(_isLoggedIn, (logged) {
      if (!logged) finish(PostLoginResult.failed);
    });

    Future.delayed(timeout, () {
      if (!completer.isCompleted) finish(PostLoginResult.failed);
    });

    return completer.future;
  }

  void setFirstTimeDone() {
    _isFirstTime.value = false;
    _storage.write('isFirstTime', false);
  }

  // Sign up with email and password
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading.value = true;

    try {
      final result = await FirebaseAuthService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );

      // If signup is successful, load user document immediately
      if (result.success && result.user != null) {
        await _syncUserAfterLogin(result.user!);
      }

      return result;
    } finally {
      _isLoading.value = false;
    }
  }

  // Sign in with email and password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading.value = true;

    try {
      // Firebase auth
      final result = await FirebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!result.success || result.user == null) return result;

      final doc = await FirestoreService.getUserDocument(
        result.user!.uid,
      ).timeout(const Duration(seconds: 5), onTimeout: () => null);

      final blocked = doc?['blocked'] == true;

      if (blocked) {
        const msg = 'Your account has been blocked. Contact support.';
        authNotice.value = msg;
        await FirebaseAuthService.signOut();
        return AuthResult(success: false, user: null, message: msg);
      }

      _userDocument.value = doc;
      _role.value = (doc?['role'] as String?) ?? 'user';
      _isBlocked.value = false;

      return result;
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Login failed. Please try again.',
        user: null,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Send password reset email
  Future<AuthResult> sendPasswordResetEmail({required String email}) async {
    _isLoading.value = true;

    try {
      final result = await FirebaseAuthService.sendPasswordResetEmail(
        email: email,
      );

      return result;
    } finally {
      _isLoading.value = false;
    }
  }

  // Sign out
  Future<AuthResult> signOut() async {
    _isLoading.value = true;

    try {
      final result = await FirebaseAuthService.signOut();

      return result;
    } finally {
      _isLoading.value = false;
    }
  }

  // Update user profile in Firestore
  Future<bool> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    String? profileImageUrl,
  }) async {
    if (_user.value == null) return false;

    _isLoading.value = true;

    try {
      final success = await FirestoreService.updateUserProfile(
        uid: _user.value!.uid,
        name: name,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        gender: gender,
        profileImageUrl: profileImageUrl,
      );

      if (success) {
        // Reload user document to get updated data
        await _loadUserDocument(_user.value!.uid);
      }

      return success;
    } finally {
      _isLoading.value = false;
    }
  }

  // Add user address
  Future<bool> addUserAddress(Map<String, dynamic> address) async {
    if (_user.value == null) return false;

    _isLoading.value = true;

    try {
      final success = await FirestoreService.addUserAddress(
        uid: _user.value!.uid,
        address: address,
      );

      if (success) {
        // Reload user document to get updated data
        await _loadUserDocument(_user.value!.uid);
      }

      return success;
    } finally {
      _isLoading.value = false;
    }
  }

  // Update user preferences
  Future<bool> updateUserPreferences(Map<String, dynamic> preferences) async {
    if (_user.value == null) return false;

    _isLoading.value = true;

    try {
      final success = await FirestoreService.updateUserPreferences(
        uid: _user.value!.uid,
        preferences: preferences,
      );

      if (success) {
        // Reload user document to get updated data
        await _loadUserDocument(_user.value!.uid);
      }

      return success;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> setAvatarId(int id) async {
    if (_user.value == null) return false;

    _isLoading.value = true;
    try {
      final success = await FirestoreService.updateUserProfile(
        uid: _user.value!.uid,
        avatarId: id,
      );

      if (success) {
        avatarChanged.value = true;
        await _loadUserDocument(_user.value!.uid);
      }

      return success;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> setCurrency(String currency) async {
    if (_user.value == null) return false;

    _isLoading.value = true;
    try {
      final upper = currency.toUpperCase();

      final success = await FirestoreService.updateUserCurrency(
        uid: _user.value!.uid,
        currency: upper,
      );

      if (success) {
        userCurrencyRx.value = upper;
        if (Get.isRegistered<CurrencyController>()) {
          Get.find<CurrencyController>().setCurrency(upper);
        }
      }
      return success;
    } finally {
      _isLoading.value = false;
    }
  }
}
