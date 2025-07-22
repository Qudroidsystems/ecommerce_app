import 'package:get/get.dart';
import '../../../features/personalization/models/address_model.dart';
import '../../../utils/exceptions/exceptions.dart';
import '../../../utils/http/http_client.dart';

class AddressRepository extends GetxController {
  static AddressRepository get instance => Get.find();

  /// Fetch all addresses for the authenticated user
  Future<List<AddressModel>> fetchUserAddresses() async {
    try {
      final response = await THttpHelper.get('api/addresses');
      if (response['success']) {
        final List<dynamic> data = response['addresses'] ?? [];
        return data.map((json) => AddressModel.fromJson(json)).toList();
      } else {
        throw TExceptions(response['message'] ?? 'Failed to fetch addresses');
      }
    } catch (e) {
      throw TExceptions('Error fetching addresses: $e');
    }
  }

  /// Add a new address
  Future<String> addAddress(AddressModel address) async {
    try {
      final response = await THttpHelper.post('api/addresses', address.toJson());
      if (response['success']) {
        return response['address']['id'].toString();
      } else {
        throw TExceptions(response['message'] ?? 'Failed to add address');
      }
    } catch (e) {
      throw TExceptions('Error adding address: $e');
    }
  }

  /// Update an existing address
  Future<void> updateAddress(AddressModel address) async {
    try {
      final response = await THttpHelper.put('api/addresses/${address.id}', address.toJson());
      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to update address');
      }
    } catch (e) {
      throw TExceptions('Error updating address: $e');
    }
  }

  /// Update the selected (default) field for an address
  Future<void> updateSelectedField({required String addressId, required bool selected}) async {
    try {
      final response = await THttpHelper.patch('api/addresses/$addressId', {'is_default': selected});
      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to update address selection');
      }
    } catch (e) {
      throw TExceptions('Error updating address selection: $e');
    }
  }

  /// Delete an address
  Future<void> deleteAddress(String addressId) async {
    try {
      final response = await THttpHelper.delete('api/addresses/$addressId');
      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to delete address');
      }
    } catch (e) {
      throw TExceptions('Error deleting address: $e');
    }
  }
}