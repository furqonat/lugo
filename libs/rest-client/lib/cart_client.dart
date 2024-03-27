library rest_client;

import 'package:dio/dio.dart' show Dio, RequestOptions, Options, ResponseType;
import 'package:rest_client/shared.dart';
import 'package:retrofit/retrofit.dart';

part 'cart_client.g.dart';

class InnerCart {
  final String? id;
  final List<CartItem>? cartItem;

  InnerCart({
    this.id,
    this.cartItem,
  });

  factory InnerCart.fromJson(Map<String, dynamic> json) => InnerCart(
        id: json["id"],
        cartItem: json["cart_item"] == null
            ? []
            : List<CartItem>.from(
                json["cart_item"]!.map((x) => CartItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cart_item": cartItem == null
            ? []
            : List<dynamic>.from(cartItem!.map((x) => x.toJson())),
      };
}

class CartItem {
  final String? id;
  final int? quantity;
  final String? productId;
  final String? cartId;
  final ProductCart? product;

  CartItem({
    this.id,
    this.quantity,
    this.productId,
    this.cartId,
    this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json["id"],
        quantity: json["quantity"],
        productId: json["product_id"],
        cartId: json["cart_id"],
        product: json["product"] == null
            ? null
            : ProductCart.fromJson(json["product"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "quantity": quantity,
        "product_id": productId,
        "cart_id": cartId,
        "product": product?.toJson(),
      };
}

class ProductCart {
  final String? id;
  final String? merchantId;
  final String? name;
  final String? image;
  final String? description;
  final int? price;
  final String? productType;
  final bool? status;

  ProductCart({
    this.id,
    this.merchantId,
    this.name,
    this.image,
    this.description,
    this.price,
    this.productType,
    this.status,
  });

  factory ProductCart.fromJson(Map<String, dynamic> json) => ProductCart(
        id: json["id"],
        merchantId: json["merchant_id"],
        name: json["name"],
        image: json["image"],
        description: json["description"],
        price: json["price"],
        productType: json["product_type"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "merchant_id": merchantId,
        "name": name,
        "image": image,
        "description": description,
        "price": price,
        "product_type": productType,
        "status": status,
      };
}

class Cart {
  final InnerCart? data;
  final int? total;

  Cart({
    this.data,
    this.total,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        data: json["data"] == null ? null : InnerCart.fromJson(json["data"]),
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "total": total,
      };
}

@RestApi(baseUrl: "https://cart.gentatechnology.com/")
abstract class CartClient {
  factory CartClient(Dio dio, {String baseUrl}) = _CartClient;

  @GET("cart")
  @Headers(<String, dynamic>{'Content-Type': 'application/json'})
  Future<Cart> getCarts(
    @Header("Authorization") String token,
    @Queries() Map<String, dynamic> queries,
  );

  @POST("cart")
  @Headers(<String, dynamic>{'Content-Type': 'application/json'})
  Future<Response> addProductToCart(
    @Header("Authorization") String token,
    @Body() Map<String, dynamic> body,
  );

  @PUT("cart")
  @Headers(<String, dynamic>{'Content-Type': 'application/json'})
  Future<Response> updateProductFromCart(
    @Header("Authorization") String token,
    @Body() Map<String, dynamic> body,
  );
}
