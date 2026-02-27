import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/cart_controller.dart';
import 'package:petshop/controllers/wishlist_controller.dart';
import 'package:petshop/models/product.dart';
import 'package:petshop/utils/app_textstyles.dart';
import 'package:petshop/view/cart_screen.dart';
import 'package:petshop/view/widgets/price_text.dart';
import 'package:petshop/view/widgets/size_selector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:petshop/utils/app_image.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? selectedSize;

  @override
  void initState() {
    super.initState();

    // Initialize with first available size if product has sizes
    final availableSizes = _getAvailableSizes();
    if (availableSizes.isNotEmpty) {
      selectedSize = availableSizes.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'Details',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          //share button
          IconButton(
            onPressed: () => _shareProduct(
              context,
              widget.product.name,
              widget.product.description,
            ),
            icon: Icon(
              Icons.share,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                //image
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: AppImage(
                    widget.product.imageUrl, // ( getter vraća primaryImage)
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                //favorite button
                Positioned(
                  child: GetBuilder<WishlistController>(
                    id: 'wishlist_${widget.product.id}',
                    builder: (wishlistController) {
                      final isInWishlist = wishlistController
                          .isProductInWishlist(widget.product.id);
                      return IconButton(
                        icon: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_border,
                          color: isInWishlist
                              ? Theme.of(context).primaryColor
                              : (isDark ? Colors.white : Colors.black),
                        ),
                        onPressed: () {
                          wishlistController.toggleWishlist(widget.product);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            //product details
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: AppTextStyle.withColor(
                            AppTextStyle.h2,
                            Theme.of(context).textTheme.headlineMedium!.color!,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          PriceText(
                            priceRsd: widget.product.price.toDouble(),
                            style: AppTextStyle.withColor(
                              AppTextStyle.h2,
                              Theme.of(
                                context,
                              ).textTheme.headlineMedium!.color!,
                            ),
                          ),
                          if (widget.product.oldPrice != null &&
                              widget.product.oldPrice! > widget.product.price)
                            PriceText(
                              priceRsd: widget.product.oldPrice!.toDouble(),
                              style:
                                  AppTextStyle.withColor(
                                    AppTextStyle.bodySmall,
                                    isDark
                                        ? Colors.grey[400]!
                                        : Colors.grey[600]!,
                                  ).copyWith(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        widget.product.category,
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodyMedium,
                          isDark ? Colors.grey[400]! : Colors.grey[600]!,
                        ),
                      ),
                      if (widget.product.brand != null) ...[
                        Text(
                          ' . ',
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodyMedium,
                            isDark ? Colors.grey[400]! : Colors.grey[600]!,
                          ),
                        ),
                        Text(
                          widget.product.brand!,
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodyMedium,
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Stock status
                  if (widget.product.stock <= 5 && widget.product.stock > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Only ${widget.product.stock} left in stock!',
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodySmall,
                          Colors.orange,
                        ),
                      ),
                    )
                  else if (widget.product.stock == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Out of stock',
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodySmall,
                          Colors.red,
                        ),
                      ),
                    ),

                  SizedBox(height: screenHeight * 0.02),
                  //show size selector only if sizes are available
                  if (_getAvailableSizes().isNotEmpty) ...[
                    Text(
                      'Select Size',
                      style: AppTextStyle.withColor(
                        AppTextStyle.labelMedium,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    //size selector with product sizes
                    SizeSelector(
                      sizes: _getAvailableSizes(),
                      onSizeSelected: (size) {
                        setState(() {
                          selectedSize = size;
                        });
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],

                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Description',
                    style: AppTextStyle.withColor(
                      AppTextStyle.labelMedium,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    widget.product.description,
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodySmall,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      //buttons
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Row(
            children: [
              Expanded(
                child: GetBuilder<CartController>(
                  builder: (cartController) {
                    final isInCart = cartController.isProductInCart(
                      widget.product.id,
                      selectedSize: selectedSize,
                    );
                    return OutlinedButton(
                      onPressed: widget.product.stock > 0
                          ? () => _addToCart(cartController)
                          : null,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                        side: BorderSide(
                          color: isDark ? Colors.white70 : Colors.black12,
                        ),
                      ),
                      child: Text(
                        widget.product.stock > 0
                            ? (isInCart ? 'Update Cart' : 'Add To Cart')
                            : 'Out of Stock',
                        style: AppTextStyle.withColor(
                          AppTextStyle.buttonMedium,
                          Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.product.stock > 0
                      ? () async {
                          final cartController = Get.find<CartController>();

                          // proveri size ako postoji
                          final availableSizes = _getAvailableSizes();
                          if (availableSizes.isNotEmpty &&
                              selectedSize == null) {
                            Get.snackbar(
                              'Size Required',
                              'Please select a size before buying',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                              backgroundColor: Colors.orange,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          // dodaj u cart
                          await cartController.addToCart(
                            product: widget.product,
                            quantity: 1,
                            selectedSize: selectedSize,
                          );

                          // idi na cart screen
                          Get.to(() => const CartScreen());
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    'Buy Now',
                    style: AppTextStyle.withColor(
                      AppTextStyle.buttonMedium,
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add product to cart
  Future<void> _addToCart(CartController cartController) async {
    // Check if size selection is required
    final availableSizes = _getAvailableSizes();
    if (availableSizes.isNotEmpty && selectedSize == null) {
      Get.snackbar(
        'Size Required',
        'Please select a size before adding to cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // add to cart with selected options
    await cartController.addToCart(
      product: widget.product,
      quantity: 1,
      selectedSize: selectedSize,
    );
  }

  // Get available sizes from product specifications
  List<String> _getAvailableSizes() {
    if (widget.product.specifications.containsKey('sizes')) {
      final sizes = widget.product.specifications['sizes'];
      if (sizes is List) {
        return List<String>.from(sizes);
      }
    }

    // Return empty list if no sizes specified (will hide size selector)
    return [];
  }

  //share product
  Future<void> _shareProduct(
    BuildContext context,
    String productName,
    String description,
  ) async {
    //get the render box for share position origin
    final box = context.findRenderObject() as RenderBox?;

    String shopLink = 'https://petshop.com/product/${widget.product.id}';
    final String shareMessage = '$description\n\nShop now at $shopLink';
    try {
      final ShareResult result = await Share.share(
        shareMessage,
        subject: productName,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
      if (result.status == ShareResultStatus.success) {
        debugPrint('Thank you for sharing!');
      }
    } catch (e) {
      debugPrint('Error Sharing:$e');
    }
  }
}
