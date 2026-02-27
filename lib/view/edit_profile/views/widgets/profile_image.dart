import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/utils/app_textstyles.dart';
import 'package:petshop/controllers/auth_controller.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Stack(
        children: [
          Obx(() {
            final auth = Get.find<AuthController>();
            final id = auth
                .avatarId; // dodaćemo getter u AuthController (jedna linija)

            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
                image: (id >= 1 && id <= 6)
                    ? DecorationImage(
                        image: AssetImage('assets/avatars/a$id.jpg'),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
              ),
              child: (id >= 1 && id <= 6)
                  ? null
                  : Icon(
                      Icons.person,
                      size: 50,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
            );
          }),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showImagePickerBottomSheet(context, isDark),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
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
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerBottomSheet(BuildContext context, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Choose Avatar',
              style: AppTextStyle.withColor(
                AppTextStyle.h3,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),

            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (_, index) {
                final id = index + 1;

                return GestureDetector(
                  onTap: () async {
                    final auth = Get.find<AuthController>();
                    await auth.setAvatarId(
                      id,
                    ); // ovo ćemo dodati u AuthController
                    Get.back();
                  },
                  child: Obx(() {
                    final auth = Get.find<AuthController>();
                    final selected = auth.avatarId == id;

                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage: AssetImage('assets/avatars/a$id.jpg'),
                      ),
                    );
                  }),
                );
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
