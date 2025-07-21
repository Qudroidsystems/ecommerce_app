import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../features/personalization/models/address_model.dart';
import '../../../utils/exceptions/exceptions.dart';
import '../../../utils/http/http_client.dart';

class AddressRepository extends GetxController {
  static AddressRepository get instance => Get.find();

  final _httpClient = Get.find<THttpHelper>();
  final deviceStorage = GetStorage();

  /// Fetch all user addresses
  Future<List<AddressModel>> fetchUserAddresses() async {
    try {
      final response = await THttpHelper.get('addresses', headers: {
        'Authorization': 'Bearer ${deviceStorage.read('auth_token')}',
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to fetch addresses');
      }

      return (response['data'] as List).map((json) => AddressModel.fromJson(json)).toList();
    } catch (e) {
      throw TExceptions('Failed to fetch addresses: $e');
    }
  }

  /// Add a new address
  Future<String> addAddress(AddressModel address, String userId) async {
    try {
      final response = await THttpHelper.post('addresses', address.toJson(), headers: {
        'Authorization': 'Bearer ${deviceStorage.read('auth_token')}',
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to add address');
      }

      return response['data']['id'].toString();
    } catch (e) {
      throw TExceptions('Failed to add address: $e');
    }
  }

  /// Update an existing address
  Future<void> updateAddress(AddressModel address, String userId) async {
    try {
      final response = await THttpHelper.put('addresses/${address.id}', address.toJson(), headers: {
        'Authorization': 'Bearer ${deviceStorage.read('auth_token')}',
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to update address');
      }
    } catch (e) {
      throw TExceptions('Failed to update address: $e');
    }
  }

  /// Delete an address
  Future<void> deleteAddress(String userId, String addressId) async {
    try {
      final response = await THttpHelper.delete('addresses/$addressId', headers: {
        'Authorization': 'Bearer ${deviceStorage.read('auth_token')}',
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to delete address');
      }
    } catch (e) {
      throw TExceptions('Failed to delete address: $e');
    }
  }

  /// Update selected field for an address
  Future<void> updateSelectedField(String userId, String addressId, bool selected) async {
    try {
      final response = await THttpHelper.patch('addresses/$addressId/select', {
        'selected': selected,
      }, headers: {
        'Authorization': 'Bearer ${deviceStorage.read('auth_token')}',
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to update selected address');
      }
    } catch (e) {
      throw TExceptions('Failed to update selected address: $e');
    }
  }
}