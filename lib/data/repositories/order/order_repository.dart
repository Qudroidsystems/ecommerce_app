import 'package:get/get.dart';
import '../../../utils/http/http_client.dart';
import '../../../features/shop/models/order_model.dart';
import '../authentication/authentication_repository.dart';
import '../../../utils/exceptions/exceptions.dart';

class OrderRepository extends GetxController {
  static OrderRepository get instance => Get.find();

  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final response = await THttpHelper.get('/orders');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw TExceptions('Failed to fetch orders: $e');
    }
  }

  Future<void> saveOrder(OrderModel order) async {
    try {
      final response = await THttpHelper.post('/orders', order.toJson());
      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to save order');
      }
    } catch (e) {
      throw TExceptions('Failed to save order: $e');
    }
  }
}