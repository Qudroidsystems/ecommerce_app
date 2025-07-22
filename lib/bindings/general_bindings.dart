import 'package:cwt_ecommerce_app/features/personalization/controllers/settings_controller.dart';
import 'package:get/get.dart';
import '../data/repositories/user/user_repository.dart';
import '../features/personalization/controllers/address_controller.dart';
import '../features/personalization/controllers/user_controller.dart';
import '../features/shop/controllers/product/checkout_controller.dart';
import '../features/shop/controllers/product/images_controller.dart';
import '../features/shop/controllers/product/variation_controller.dart';
import '../utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    /// -- Core
    Get.put(NetworkManager(), permanent: true);
    Get.put(UserRepository(), permanent: true);
    Get.put(UserController(), permanent: true);

    /// -- Product
    // Get.put(CheckoutController());
    // Get.put(VariationController());
    // Get.put(ImagesController());
    //
    // /// -- Other
    // Get.put(AddressController());
    // Get.lazyPut(() => SettingsController(), fenix: true);
  }
}
