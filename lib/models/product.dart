class Product {
  final String name;
  final String category;
  final double price;
  final double? oldPrice;
  final String imageUrl;
  final bool isFavorite;
  final String description;

  const Product({
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.oldPrice,
    this.isFavorite = false,
  });
}

final List<Product> products = [
  const Product(
    name: 'SNOOZA-Dog Bed',
    category: 'Equipment',
    price: 4500,
    oldPrice: 7300,
    imageUrl: 'assets/images/product.jpg',
    description:
        'Snooza Ortho Sofa is designed for older dogs who find it difficult to get in and out of their regular beds or baskets. The comfortable and durable Ortho Sofa has a secure orthopaedic support foam base that is stable and comfortable, as well as soft padding that provides a sense of comfort and calm for your pet.',
  ),
   const Product(
    name: 'Essential Dog Hoodie',
    category: 'Clothes',
    price: 2300,
    oldPrice: 3700,
    imageUrl: 'assets/images/product3.jpg',
    description:'Signature Spark Paws Butterstretch™ fabric. Very stretchy, durable, soft texture. Fluffy cozy fleece interior. Machine wash cold, line dry. 55% Cotton, 40% Polyester, 5% Spandex',
  ),
   const Product(
    name: 'Zolux Wild Rope',
    category: 'Toys',
    price: 1030,
    oldPrice: 1700,
    imageUrl: 'assets/images/product2.jpg',
    description:'Made from beech wood and 100% cotton rope',
  ),
   const Product(
    name: 'Orijen Puppy',
    category: 'Food',
    price: 13500,
    oldPrice: 15600,
    imageUrl: 'assets/images/products2.jpg',
    description:'Orijen Puppy provides biologically appropriate nutrition for puppies, with an emphasis on a high protein content derived from fresh chicken, turkey, fish, and chicken offal.',
      ),
];
