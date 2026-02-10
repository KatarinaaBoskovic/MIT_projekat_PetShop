import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/utils/app_textstyles.dart';
import 'package:petshop/view/privacy_policy/views/widgets/info_section.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
                title: 'Information We Collect',
                content:
                    'We collect information that you provide directly to us, including name, email address, and shipping information.',
              ),
              InfoSection(
                title: 'How We Use Your Information',
                content:
                    'We use information we collect to provide, maintain, and improve our services, process your transactions, and send you updates.',
              ),
              InfoSection(
                title: 'Information Sharing',
                content:
                    'We do not sell your personal information. We may share necessary data with trusted service providers such as delivery partners and payment processors solely to complete your transactions. These partners are required to protect your information.',
              ),
              InfoSection(
                title: 'Data Security',
                content:
                    'We implement appropriate technical and organizational measures to protect your personal data. While we strive to secure your information, no digital transmission or storage system is completely risk-free.',
              ),
              InfoSection(
                title: 'Your Rights',
                content:
                    'You have the right to access, update, or request deletion of your personal information. If you wish to exercise these rights, you may contact our support team through the app.',
              ),
              InfoSection(
                title: 'Cookie Policy',
                content:
                    'We may use cookies and similar technologies to improve performance, remember user preferences, and enhance your browsing experience within the app.',
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
