import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/auth_controller.dart';
import 'package:petshop/controllers/navigation_controller.dart';
import 'package:petshop/services/firebase_auth_service.dart';
import 'package:petshop/utils/app_textstyles.dart';
import 'package:petshop/view/forgot_password_screen.dart';
import 'package:petshop/view/main_screen.dart';
import 'package:petshop/view/sign_up_screen.dart';
import 'package:petshop/view/widgets/custom_textfield.dart';
import 'package:petshop/view/admin/admin_main_screen.dart';

class SinginScreen extends StatefulWidget {
  const SinginScreen({super.key});

  @override
  State<SinginScreen> createState() => _SinginScreenState();
}

class _SinginScreenState extends State<SinginScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _blockedNoticeShown = false;
  final TextEditingController _passwordController = TextEditingController();
  Worker? _noticeWorker;
  @override
  void initState() {
    super.initState();

    final auth = Get.find<AuthController>();

    _noticeWorker = ever<String>(auth.authNotice, (msg) async {
      if (!mounted) return;
      if (msg.trim().isEmpty) return;

      auth.authNotice.value = '';
      _blockedNoticeShown = true;
      await _forceCloseDialog();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Get.closeAllSnackbars();
        Get.snackbar(
          'Account blocked',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    });
  }

  @override
  void dispose() {
    _noticeWorker?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Welcome Back!',
                style: AppTextStyle.withColor(
                  AppTextStyle.h1,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue shopping',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyLarge,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
              const SizedBox(height: 40),
              //email textfield
              CustomTextfield(
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              //password textfield
              CustomTextfield(
                label: 'Password',
                prefixIcon: Icons.lock_outline,
                keyboardType: TextInputType.visiblePassword,
                isPassword: true,
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              //forgot password textbutton
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.to(() => ForgotPasswordScreen()),
                  child: Text(
                    'Forgot Password?',
                    style: AppTextStyle.withColor(
                      AppTextStyle.buttonMedium,
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              //sign in button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Sign in',
                    style: AppTextStyle.withColor(
                      AppTextStyle.buttonMedium,
                      Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // continue as guest button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _continueAsGuest,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  child: Text(
                    'Continue as Guest',
                    style: AppTextStyle.withColor(
                      AppTextStyle.buttonMedium,
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              //siggup textbutton
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Dont have an account?",
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => SignUpScreen()),
                    child: Text(
                      'Sign Up',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _continueAsGuest() {
    final nav = Get.find<NavigationController>();
    nav.currentIndex.value = 0;

    Get.offAll(() => const MainScreen());
  }

  Future<void> _forceCloseDialog() async {
    for (int i = 0; i < 3; i++) {
      if (Get.isDialogOpen == true) {
        try {
          Get.back();
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 20));
      } else {
        break;
      }
    }
  }

  //sign in button onpressed
  void _handleSignIn() async {
    // Validacije
    if (_emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!GetUtils.isEmail(_emailController.text.trim())) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final AuthController authController = Get.find<AuthController>();

    // Otvori loading dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      //Pokušaj login
      final result = await authController.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Zatvori loading dialog
      await _forceCloseDialog();
      //  Ako login nije uspeo – pokaži poruku i prekini
      if (!result.success) {
        // Ako je worker već prikazao "blocked" poruku, ne prikazuj ništa ovde
        if (_blockedNoticeShown) {
          _blockedNoticeShown = false; // reset
          return;
        }

        // fallback da uvek vidi nešto
        final msg = result.message.trim().isEmpty
            ? 'Sign in failed. Please check your credentials or try again.'
            : result.message;

        Get.snackbar(
          'Error',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      //  Sačeka userDocument max 5s
      final started = DateTime.now();
      while (authController.isLoggedIn && authController.userDocument == null) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (DateTime.now().difference(started).inSeconds >= 5) break;
      }

      // Ako je user blokiran, AuthController će ga odjaviti, ostani na loginu
      if (!authController.isLoggedIn) return;

      // Ako nema userDocument-odjavi i ostani
      if (authController.userDocument == null) {
        await FirebaseAuthService.signOut();
        return;
      }

      //Navigacija
      final nav = Get.find<NavigationController>();
      nav.currentIndex.value = 0;

      if (authController.isAdmin) {
        Get.offAll(() => const AdminMainScreen());
      } else {
        Get.offAll(() => const MainScreen());
      }
    } catch (e) {
      //Ako pukne bilo šta, zatvori dialog i pokaži poruku
      await _forceCloseDialog();
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      //Dodatna sigurnost da dialog ne ostane zauvek
      await _forceCloseDialog();
    }
  }
}
