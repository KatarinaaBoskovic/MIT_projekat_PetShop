import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/auth_controller.dart';
import 'package:petshop/services/firestore_service.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    if (!auth.isAdmin) {
      return const Center(child: Text('Not authorized'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirestoreService.getUsersStream(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('Error loading users'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text('No users'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final d = docs[i];
            final data = d.data();

            final uid = (data['uid'] as String?) ?? d.id;
            final email = (data['email'] as String?) ?? '';
            final name =
                (data['name'] as String?) ??
                (data['displayName'] as String?) ??
                '';
            final role = (data['role'] as String?) ?? 'user';
            final blocked = data['blocked'] == true;

            final isSelf = auth.user?.uid == uid;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? email : name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                  const SizedBox(height: 10),

                  // role + blocked kontrole
                  Row(
                    children: [
                      // ROLE
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: role == 'admin' ? 'admin' : 'user',
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'user',
                              child: Text('user'),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text('admin'),
                            ),
                          ],
                          onChanged: isSelf
                              ? null // admin ne menja sam sebi role
                              : (val) async {
                                  if (val == null) return;
                                  final ok =
                                      await FirestoreService.adminUpdateUser(
                                        uid: uid,
                                        role: val,
                                      );
                                  if (!ok) {
                                    Get.snackbar(
                                      'Error',
                                      'Failed to update role',
                                    );
                                  }
                                },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // BLOCKED
                      Expanded(
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Blocked'),
                          value: blocked,
                          onChanged: isSelf
                              ? null // admin ne blokira sam sebe
                              : (v) async {
                                  final ok =
                                      await FirestoreService.adminUpdateUser(
                                        uid: uid,
                                        blocked: v,
                                      );
                                  if (!ok) {
                                    Get.snackbar(
                                      'Error',
                                      'Failed to update blocked',
                                    );
                                  }
                                },
                        ),
                      ),
                    ],
                  ),

                  if (isSelf)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'This is you (controls disabled)',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
}
