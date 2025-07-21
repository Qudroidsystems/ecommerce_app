import 'package:get/get.dart';
import '../../../features/shop/models/order_model.dart';
import '../../../utils/exceptions/exceptions.dart';
import '../../../utils/http/http_client.dart';
import '../authentication/authentication_repository.dart';

class OrderRepository extends GetxController {
  static OrderRepository get instance => Get.find();

  /// Variables
  final _httpClient = Get.find<THttpHelper>();

  /// Get all orders related to current user
  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final userId = AuthenticationRepository.instance.getUserID;
      if (userId.isEmpty) throw const TExceptions('Unable to find user information. Try again in few minutes.');

      final response = await THttpHelper.get('orders', headers: {
        'Authorization': 'Bearer ${AuthenticationRepository.instance.deviceStorage.read('auth_token')}',
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to fetch orders');
      }

      return (response['orders'] as List<dynamic>)
          .map((orderJson) => OrderModel.fromJson(orderJson as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw TExceptions('Something went wrong while fetching Order Information: $e');
    }
  }

  /// Store new user order
  Future<void> saveOrder(OrderModel order, String userId) async {
    try {
      final response = await THttpHelper.post(
        'orders',
        order.toJson(),
        headers: {
          'Authorization': 'Bearer ${AuthenticationRepository.instance.deviceStorage.read('auth_token')}',
          'Content-Type': 'application/json',
        },
      );

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to save order');
      }
    } catch (e) {
      throw TExceptions('Something went wrong while saving Order Information: $e');
    }
  }
}