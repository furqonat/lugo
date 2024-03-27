import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:rest_client/cart_client.dart';
import 'package:rest_client/product_client.dart';
import 'api_menu.dart';
import 'controller_menu.dart';

class BindingFoodMenu implements Bindings {
  @override
  void dependencies() {
    final dio = Dio();
    Get.lazyPut<ControllerFoodMenu>(
      () => ControllerFoodMenu(
        api: ApiFoodMenu(
          cartClient: CartClient(dio),
        ),
        cartClient: CartClient(dio),
        productClient: ProductClient(dio),
      ),
    );
  }
}
