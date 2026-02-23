import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String displayName;
  final String? description;
  final String? iconUrl;
  final String? imageUrl;
  final bool isActive;
  final int sortOrder;
  final List<String> subcategories;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    this.iconUrl,
    this.imageUrl,
    this.isActive = true,
    this.sortOrder = 0,
    this.subcategories = const [],
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
  });
  // Create Category from Firestore document
  factory Category.fromFirestore(Map<String, dynamic> data, String id) {
    return Category(
      id: id,
      name: data['name'] ?? '',
      displayName: data['displayName'] ?? data['name'] ?? '',
      description: data['description'],
      iconUrl: data['iconUrl'],
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      sortOrder: data['sortOrder'] ?? 0,
      subcategories: List<String>.from(data['subcategories'] ?? []),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }
  // Convert category to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'displayName': displayName,
      'description': description,
      'iconUrl': iconUrl,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'subcategories': subcategories,
      'metadata': metadata,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  String toString() => displayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
