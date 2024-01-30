import 'dart:convert';
import 'package:lugo_customer/response/customer.dart';
import 'package:lugo_customer/response/driver_info.dart';
import 'package:lugo_customer/response/order_detail.dart';
import 'package:lugo_customer/response/order_item.dart';

OrderHistory orderHistoryFromJson(String str) => OrderHistory.fromJson(json.decode(str));

String orderHistoryToJson(OrderHistory data) => json.encode(data.toJson());

class OrderHistory {
  String? id;
  String? orderType;
  String? orderStatus;
  String? paymentType;
  DateTime? createdAt;
  String? driverId;
  String? customerId;
  int? grossAmount;
  int? netAmount;
  int? totalAmount;
  int? shippingCost;
  int? weightCost;
  int? version;
  bool? showable;
  DriverInfo? driver;
  Customer? customer;
  List<OrderItem>? orderItems;
  OrderDetail? orderDetail;


  OrderHistory({
    this.id,
    this.orderType,
    this.orderStatus,
    this.paymentType,
    this.createdAt,
    this.driverId,
    this.customerId,
    this.grossAmount,
    this.netAmount,
    this.totalAmount,
    this.shippingCost,
    this.weightCost,
    this.version,
    this.showable,
    this.driver,
    this.customer,
    this.orderItems,
    this.orderDetail
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) => OrderHistory(
      id: json["id"],
      orderType: json["order_type"],
      orderStatus: json["order_status"],
      paymentType: json["payment_type"],
      createdAt: DateTime.parse(json["created_at"]),
      driverId: json["driver_id"],
      customerId: json["customer_id"],
      grossAmount: json["gross_amount"],
      netAmount: json["net_amount"],
      totalAmount: json["total_amount"],
      shippingCost: json["shipping_cost"],
      weightCost: json["weight_cost"],
      version: json["version"],
      showable: json["showable"],
      driver: json["driver"] == null ? null : DriverInfo.fromJson(json["driver"]),
      customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
      orderItems: json["order_items"] == null ? null : List<OrderItem>.from(json["order_items"].map((x) => OrderItem.fromJson(x))),
      orderDetail: json["order_detail"] == null ? null : OrderDetail.fromJson(json["order_detail"])
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_type": orderType,
    "order_status": orderStatus,
    "payment_type": paymentType,
    "created_at": createdAt?.toIso8601String(),
    "driver_id": driverId,
    "customer_id": customerId,
    "gross_amount": grossAmount,
    "net_amount": netAmount,
    "total_amount": totalAmount,
    "shipping_cost": shippingCost,
    "weight_cost": weightCost,
    "version": version,
    "showable": showable,
    "driver": driver?.toJson(),
    "customer": customer?.toJson(),
    "order_items": List<dynamic>.from(orderItems!.map((x) => x.toJson())),
    "order_detail": orderDetail?.toJson(),
  };
}