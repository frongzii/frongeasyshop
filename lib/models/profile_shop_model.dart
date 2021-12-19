import 'dart:convert';

class ProfileShopModel {
  final String nameShop;
  final String address;
  final String phone;
  final double lat;
  final double long;
  final String pathImage;
  final bool product;
  ProfileShopModel({
    required this.nameShop,
    required this.address,
    required this.phone,
    required this.lat,
    required this.long,
    required this.pathImage,
    required this.product,
  });

  Map<String, dynamic> toMap() {
    return {
      'nameShop': nameShop,
      'address': address,
      'phone': phone,
      'lat': lat,
      'long': long,
      'pathImage': pathImage,
      'product': product,
    };
  }

  factory ProfileShopModel.fromMap(Map<String, dynamic> map) {
    return ProfileShopModel(
      nameShop: map['nameShop'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      lat: map['lat']?.toDouble() ?? 0.0,
      long: map['long']?.toDouble() ?? 0.0,
      pathImage: map['pathImage'] ?? '',
      product: map['product'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileShopModel.fromJson(String source) => ProfileShopModel.fromMap(json.decode(source));
}
