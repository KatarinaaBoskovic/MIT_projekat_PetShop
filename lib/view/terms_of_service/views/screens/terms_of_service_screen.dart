import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/utils/app_textstyles.dart';
import 'package:petshop/view/privacy_policy/views/widgets/info_section.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'Terms of Service',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(screenSize.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoSection(
                title: 'Welcome to PetShop',
                content:
                    'By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.',
              ),
              InfoSection(
                title: 'Account Registration',
                content:
                    'You are responsible for maintaining accurate account information and keeping your login credentials secure. Any activity performed through your account is your responsibility.',
              ),
              InfoSection(
                title: 'User Responsibilities',
                content:
                    'You agree to use the app lawfully and respectfully. Misuse, fraudulent activity, or attempts to disrupt app functionality are strictly prohibited.',
              ),
              InfoSection(
                title: 'Privacy Policy',
                content:
                    'Your privacy is important to us. Our Privacy Policy explains how your data is collected, used, and protected when using the app.',
              ),
              InfoSection(
                title: 'Intellectual Property',
                content:
                    'All content within the app, including design, logos, and materials, is the property of PetShop and may not be copied, distributed, or used without permission.',
              ),
              InfoSection(
                title: 'Termination',
                content:
                    'We reserve the right to suspend or terminate access to the app if a user violates these terms or engages in harmful behavior.',
              ),
              const SizedBox(height: 24),
              Text(
                'Last updated: February 2026',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodySmall,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
