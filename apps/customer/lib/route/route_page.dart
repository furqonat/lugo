import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:lugo_customer/page/about_us/binding_aboutus.dart';
import 'package:lugo_customer/page/about_us/page_aboutus.dart';
import 'package:lugo_customer/page/auth/binding_auth.dart';
import 'package:lugo_customer/page/auth/page_auth.dart';
import 'package:lugo_customer/page/chat/binding_chat.dart';
import 'package:lugo_customer/page/chat/page_chat.dart';
import 'package:lugo_customer/page/check_order/binding_checkorder.dart';
import 'package:lugo_customer/page/check_order/page_checkorder.dart';
import 'package:lugo_customer/page/delivery_finish/binding_delivfinish.dart';
import 'package:lugo_customer/page/delivery_finish/page_delivfinish.dart';
import 'package:lugo_customer/page/detail_point/binding_detailpoint.dart';
import 'package:lugo_customer/page/detail_point/page_detailpoint.dart';
import 'package:lugo_customer/page/digital_pay/binding_digitalpay.dart';
import 'package:lugo_customer/page/digital_pay/page_digitalpay.dart';
import 'package:lugo_customer/page/discount/binding_discount.dart';
import 'package:lugo_customer/page/discount/page_discount.dart';
import 'package:lugo_customer/page/edit_profile/binding_editprofile.dart';
import 'package:lugo_customer/page/edit_profile/page_editprofile.dart';
import 'package:lugo_customer/page/food/binding_food.dart';
import 'package:lugo_customer/page/food/page_food.dart';
import 'package:lugo_customer/page/food_finish/binding_foodfinish.dart';
import 'package:lugo_customer/page/food_finish/page_foodfinish.dart';
import 'package:lugo_customer/page/food_order_hisory/binding_historyfood.dart';
import 'package:lugo_customer/page/food_order_hisory/page_historyfood.dart';
import 'package:lugo_customer/page/food_pay/binding_foodpay.dart';
import 'package:lugo_customer/page/food_pay/page_foodpay.dart';
import 'package:lugo_customer/page/history_order/binding_history.dart';
import 'package:lugo_customer/page/history_order/page_history.dart';
import 'package:lugo_customer/page/home/binding_home.dart';
import 'package:lugo_customer/page/home/page_home.dart';
import 'package:lugo_customer/page/location_picker/binding_locationpicker.dart';
import 'package:lugo_customer/page/location_picker/page_locationpicker.dart';
import 'package:lugo_customer/page/main_page/binding_main.dart';
import 'package:lugo_customer/page/main_page/page_main.dart';
import 'package:lugo_customer/page/mart/binding_mart.dart';
import 'package:lugo_customer/page/mart/page_mart.dart';
import 'package:lugo_customer/page/mart_menu/binding_martmenu.dart';
import 'package:lugo_customer/page/mart_menu/page_martmenu.dart';
import 'package:lugo_customer/page/mart_order_history/binding_marthistory.dart';
import 'package:lugo_customer/page/mart_order_history/page_marthistory.dart';
import 'package:lugo_customer/page/mart_pay/binding_marpay.dart';
import 'package:lugo_customer/page/mart_pay/page_marpay.dart';
import 'package:lugo_customer/page/order_finish/binding_orderfinish.dart';
import 'package:lugo_customer/page/order_finish/page_orderfinish.dart';
import 'package:lugo_customer/page/otp/binding_otp.dart';
import 'package:lugo_customer/page/otp/page_otp.dart';
import 'package:lugo_customer/page/pin/binding_pin.dart';
import 'package:lugo_customer/page/pin/page_pin.dart';
import 'package:lugo_customer/page/point/binding_point.dart';
import 'package:lugo_customer/page/point/page_point.dart';
import 'package:lugo_customer/page/privacy_term/binding_privacyterm.dart';
import 'package:lugo_customer/page/privacy_term/page_privacyterm.dart';
import 'package:lugo_customer/page/profile/binding_profile.dart';
import 'package:lugo_customer/page/profile/page_profile.dart';
import 'package:lugo_customer/page/saldo/binding_saldo.dart';
import 'package:lugo_customer/page/saldo/page_saldo.dart';
import 'package:lugo_customer/page/splash_screen/binding_splash.dart';
import 'package:lugo_customer/page/splash_screen/page_splash.dart';
import 'package:lugo_customer/page/webview/binding_webview.dart';
import 'package:lugo_customer/page/webview/page_webview.dart';
import 'package:lugo_customer/route/route_name.dart';
import '../page/food_menu/binding_menu.dart';
import '../page/food_menu/page_menu.dart';
import '../page/room_chat/binding_roomchat.dart';
import '../page/room_chat/page_roomchat.dart';
import '../page/running_order/binding_running.dart';
import '../page/running_order/page_running.dart';

class RoutingPages {
  static final pages = [
    GetPage(
        name: Routes.start,
        page: () => const PageSplash(),
        binding: BindingSplash()),
    GetPage(
        name: Routes.auth,
        page: () => const PageAuth(),
        binding: BindingAuth()),
    GetPage(
        name: Routes.otp, page: () => const PageOtp(), binding: BindingOtp()),
    GetPage(
        name: Routes.pin, page: () => const PagePin(), binding: BindingPin()),
    GetPage(
        name: Routes.saldo,
        page: () => const PageSaldo(),
        binding: BindingSaldo()),
    GetPage(
        name: Routes.point,
        page: () => const PagePoint(),
        binding: BindingPoint()),
    GetPage(
        name: Routes.detailPoint,
        page: () => const PageDetailPoint(),
        binding: BindingDetailPoint()),
    GetPage(
        name: Routes.home,
        page: () => const PageHome(),
        binding: BindingHome()),
    GetPage(
        name: Routes.main,
        page: () => const PageMain(),
        binding: BindingMain()),
    GetPage(
        name: Routes.locationPicker,
        page: () => const PageLocationPicker(),
        binding: BindingLocationPicker()),
    GetPage(
        name: Routes.checkOrder,
        page: () => const PageCheckOrder(),
        binding: BindingCheckOrder()),
    GetPage(
        name: Routes.orderFinish,
        page: () => const PageOrderFinish(),
        binding: BindingOrderFinish()),
    GetPage(
        name: Routes.deliveryFinish,
        page: () => const PageDelivFinish(),
        binding: BindingDelivFinish()),
    GetPage(
        name: Routes.roomChat,
        page: () => const PageRoomChat(),
        binding: BindingRoomChat()),
    GetPage(
        name: Routes.chat,
        page: () => const PageChat(),
        binding: BindingChat()),
    GetPage(
        name: Routes.orderHistory,
        page: () => const PageHistory(),
        binding: BindingHistory()),
    GetPage(
        name: Routes.runningOrder,
        page: () => const PageRunning(),
        binding: BindingRunning()),
    GetPage(
        name: Routes.food,
        page: () => const PageFood(),
        binding: BindingFood()),
    GetPage(
        name: Routes.foodMenu,
        page: () => const PageFoodMenu(),
        binding: BindingFoodMenu()),
    GetPage(
        name: Routes.foodPay,
        page: () => const PageFoodPay(),
        binding: BindingFoodPay()),
    GetPage(
        name: Routes.foodFinish,
        page: () => const PageFoodFinish(),
        binding: BindingFoodFinish()),
    GetPage(
        name: Routes.profile,
        page: () => const PageProfile(),
        binding: BindingProfile()),
    GetPage(
        name: Routes.historyFood,
        page: () => const PageHistoryFood(),
        binding: BindingHistoryFood()),
    GetPage(
        name: Routes.editProfile,
        page: () => const PageEditProfile(),
        binding: BindingEditProfile()),
    GetPage(
        name: Routes.aboutUs,
        page: () => const PageAboutUs(),
        binding: BindingAboutUs()),
    GetPage(
        name: Routes.privacyTerm,
        page: () => const PagePrivacyTerm(),
        binding: BindingPrivacyTerm()),
    GetPage(
        name: Routes.mart,
        page: () => const PageMart(),
        binding: BindingMart()),
    GetPage(
        name: Routes.martMenu,
        page: () => const PageMartMenu(),
        binding: BindingMartMenu()),
    GetPage(
        name: Routes.martPay,
        page: () => const PageMartPay(),
        binding: BindingMartPay()),
    GetPage(
        name: Routes.historyMart,
        page: () => const PageMartHistory(),
        binding: BindingMartHistory()),
    GetPage(
        name: Routes.discount,
        page: () => const PageDiscount(),
        binding: BindingDiscount()),
    GetPage(
        name: Routes.digitalPay,
        page: () => const PageDigitalPay(),
        binding: BindingDigitalPay()),
    GetPage(
        name: Routes.webview,
        page: () => const PageWebView(),
        binding: BindingWebView()),
  ];
}
