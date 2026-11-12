class PropertyModel {
  final String id;
  final String title;
  final String type; // 'House', 'Apartment', 'Office', 'Land'
  final double price;
  final String address;
  final int bedrooms;
  final int bathrooms;
  final int kitchens;
  final double sqft;
  final String imageUrl;
  final bool isFeatured;
  final String ownerId;

  PropertyModel({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.address,
    required this.bedrooms,
    required this.bathrooms,
    required this.kitchens,
    required this.sqft,
    required this.imageUrl,
    this.isFeatured = false,
    required this.ownerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'price': price,
      'address': address,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'kitchens': kitchens,
      'sqft': sqft,
      'imageUrl': imageUrl,
      'isFeatured': isFeatured,
      'ownerId': ownerId,
    };
  }

  factory PropertyModel.fromMap(Map<String, dynamic> map, String docId) {
    return PropertyModel(
      id: docId,
      title: map['title'] ?? '',
      type: map['type'] ?? 'Apartment',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      address: map['address'] ?? '',
      bedrooms: (map['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (map['bathrooms'] as num?)?.toInt() ?? 0,
      kitchens: (map['kitchens'] as num?)?.toInt() ?? 0,
      sqft: (map['sqft'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      isFeatured: map['isFeatured'] ?? false,
      ownerId: map['ownerId'] ?? '',
    );
  }
}
