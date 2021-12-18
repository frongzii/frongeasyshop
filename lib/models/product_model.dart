import 'dart:convert';

class ProductModel {
  final String nameProduct;
  final int amountProduct;
  final int priceProduct;
  final String pathProduct;
  ProductModel({
    required this.nameProduct,
    required this.amountProduct,
    required this.priceProduct,
    required this.pathProduct,
  });

  Map<String, dynamic> toMap() {
    return {
      'nameProduct': nameProduct,
      'amountProduct': amountProduct,
      'priceProduct': priceProduct,
      'pathProduct': pathProduct,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      nameProduct: map['nameProduct'] ?? '',
      amountProduct: map['amountProduct']?.toInt() ?? 0,
      priceProduct: map['priceProduct']?.toInt() ?? 0,
      pathProduct: map['pathProduct'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(String source) => ProductModel.fromMap(json.decode(source));
}
