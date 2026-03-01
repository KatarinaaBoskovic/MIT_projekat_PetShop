import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/auth_controller.dart';
import 'package:petshop/view/admin/admin_main_screen.dart';
import 'package:petshop/view/main_screen.dart';
import 'package:petshop/view/onboarding_screen.dart';
import 'package:petshop/view/singin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final AuthController auth;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    auth = Get.find<AuthController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _route();
    });
  }

  Future<void> _route() async {
    if (!mounted || _navigated) return;

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted || _navigated) return;

    // onboarding
    if (auth.isFirstTime) {
      _navigated = true;
      Get.offAll(() => const OnboardingScreen());
      return;
    }

    // ako NIJE ulogovan - login
    if (!auth.isLoggedIn) {
      _navigated = true;
      Get.offAll(() => const SinginScreen());

      final msg = auth.authNotice.value.trim();
      if (msg.isNotEmpty) {
        auth.authNotice.value = '';
        Future.delayed(const Duration(milliseconds: 250), () {
          Get.snackbar(
            'Account blocked',
            msg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        });
      }
      return;
    }

    //Ulogovan je- čeka da userDocument stigne
    final deadline = DateTime.now().add(const Duration(seconds: 3));

    while (!_navigated && mounted) {
      if (!auth.isLoggedIn) {
        _navigated = true;
        Get.offAll(() => const SinginScreen());

        final msg = auth.authNotice.value.trim();
        if (msg.isNotEmpty) {
          auth.authNotice.value = '';
          Future.delayed(const Duration(milliseconds: 250), () {
            Get.snackbar(
              'Account blocked',
              msg,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          });
        }
        return;
      }

      if (auth.userDocument != null) break;

      if (DateTime.now().isAfter(deadline)) {
        _navigated = true;
        Get.offAll(() => const SinginScreen());
        Get.snackbar(
          'Error',
          'Unable to load your account data. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      await Future.delayed(const Duration(milliseconds: 120));
    }

    if (!mounted || _navigated) return;

    //admin ili user
    _navigated = true;
    if (auth.isAdmin) {
      Get.offAll(() => const AdminMainScreen());
    } else {
      Get.offAll(() => const MainScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
              Theme.of(context).primaryColor.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: GridPattern(color: Colors.white),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1200),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.pets,
                            size: 48,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1200),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: const [
                        Text(
                          "PET",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 8,
                          ),
                        ),
                        Text(
                          "SHOP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                builder: (context, value, child) {
                  return Opacity(opacity: value, child: child);
                },
                child: Text(
                  'Happy tails, happy homes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GridPattern extends StatelessWidget {
  final Color color;
  const GridPattern({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: GridPainter(color: color));
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;
    const spacing = 20.0;
    for (var i = 0.0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (var i = 0.0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
