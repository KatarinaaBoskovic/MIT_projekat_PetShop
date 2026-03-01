import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/auth_controller.dart';
import 'package:petshop/view/admin/screens/admin_orders_screen.dart';
import 'package:petshop/view/admin/screens/admin_products_screen.dart';
import 'package:petshop/view/admin/screens/admin_users_screen.dart';
import 'package:petshop/view/singin_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          IconButton(
            onPressed: () async {
              await auth.signOut();
              Get.offAll(() => SinginScreen());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: index,
        children: const [
          AdminProductsScreen(),
          AdminOrdersScreen(),
          AdminUsersScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Users',
          ),
        ],
      ),
    );
  }
}
