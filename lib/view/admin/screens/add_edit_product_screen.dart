import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/models/product.dart';
import 'package:petshop/services/product_firestore_service.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameCtrl;
  late final TextEditingController categoryCtrl;
  late final TextEditingController brandCtrl;
  late final TextEditingController priceCtrl;
  late final TextEditingController oldPriceCtrl;
  late final TextEditingController currencyCtrl;
  late final TextEditingController stockCtrl;
  late final TextEditingController imageCtrl;
  late final TextEditingController descCtrl;

  bool isActive = true;
  bool isFeatured = false;
  bool isOnSale = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    nameCtrl = TextEditingController(text: p?.name ?? '');
    categoryCtrl = TextEditingController(text: p?.category ?? '');
    brandCtrl = TextEditingController(text: p?.brand ?? '');
    priceCtrl = TextEditingController(
      text: p != null ? p.price.toString() : '',
    );
    oldPriceCtrl = TextEditingController(text: p?.oldPrice?.toString() ?? '');
    currencyCtrl = TextEditingController(text: p?.currency ?? 'RSD');
    stockCtrl = TextEditingController(
      text: p != null ? p.stock.toString() : '0',
    );
    imageCtrl = TextEditingController(text: p?.primaryImage ?? '');
    descCtrl = TextEditingController(text: p?.description ?? '');

    isActive = p?.isActive ?? true;
    isFeatured = p?.isFeatured ?? false;
    isOnSale = p?.isOnSale ?? false;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    categoryCtrl.dispose();
    brandCtrl.dispose();
    priceCtrl.dispose();
    oldPriceCtrl.dispose();
    currencyCtrl.dispose();
    stockCtrl.dispose();
    imageCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = nameCtrl.text.trim();
    final category = categoryCtrl.text.trim();
    final brand = brandCtrl.text.trim().isEmpty ? null : brandCtrl.text.trim();
    final price = double.parse(priceCtrl.text.trim());
    final oldPrice = oldPriceCtrl.text.trim().isEmpty
        ? null
        : double.parse(oldPriceCtrl.text.trim());
    final currency = currencyCtrl.text.trim().isEmpty
        ? 'RSD'
        : currencyCtrl.text.trim().toUpperCase();
    final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;
    final img = imageCtrl.text.trim();
    final desc = descCtrl.text.trim();

    if (widget.product == null) {
      final product = Product(
        id: '',
        name: name,
        category: category,
        price: price,
        oldPrice: oldPrice,
        currency: currency,
        images: img.isEmpty ? [] : [img],
        primaryImage: img,
        description: desc,
        brand: brand,
        stock: stock,
        isActive: isActive,
        isFeatured: isFeatured,
        isOnSale: isOnSale,
      );

      final id = await ProductFirestoreService.addProduct(product);
      if (id == null) {
        Get.snackbar('Error', 'Failed to add product');
        return;
      }
      Get.back();
      Get.snackbar('Success', 'Product added');
    } else {
      final ok = await ProductFirestoreService.updateProduct(
        productId: widget.product!.id,
        data: {
          'name': name,
          'category': category,
          'brand': brand,
          'price': price,
          'oldPrice': oldPrice,
          'currency': currency,
          'stock': stock,
          'primaryImage': img,
          'images': img.isEmpty ? [] : [img],
          'description': desc,
          'isActive': isActive,
          'isFeatured': isFeatured,
          'isOnSale': isOnSale,
        },
      );

      if (!ok) {
        Get.snackbar('Error', 'Failed to update product');
        return;
      }
      Get.back();
      Get.snackbar('Success', 'Product updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Product' : 'Add Product')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: categoryCtrl,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: brandCtrl,
              decoration: const InputDecoration(
                labelText: 'Brand (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                return double.tryParse(v.trim()) == null
                    ? 'Invalid number'
                    : null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: oldPriceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Old price (optional)',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                return double.tryParse(v.trim()) == null
                    ? 'Invalid number'
                    : null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: currencyCtrl,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stock',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: imageCtrl,
              decoration: const InputDecoration(
                labelText: 'Primary image URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: descCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('Active'),
              value: isActive,
              onChanged: (v) => setState(() => isActive = v),
            ),
            SwitchListTile(
              title: const Text('Featured'),
              value: isFeatured,
              onChanged: (v) => setState(() => isFeatured = v),
            ),
            SwitchListTile(
              title: const Text('On sale'),
              value: isOnSale,
              onChanged: (v) => setState(() => isOnSale = v),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEdit ? 'Save changes' : 'Add product'),
            ),
          ],
        ),
      ),
    );
  }
}
