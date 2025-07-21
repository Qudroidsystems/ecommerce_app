import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../features/personalization/models/user_model.dart';
import '../../../utils/exceptions/exceptions.dart';
import '../../../utils/http/http_client.dart' as httpClient;
import '../authentication/authentication_repository.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _httpClient = Get.find<httpClient.THttpHelper>();
  final deviceStorage = GetStorage();

  /// Fetch user details
  Future<UserModel> fetchUserDetails() async {
    try {
      final token = Get.find<AuthenticationRepository>().deviceStorage.read('auth_token');
      if (token == null) {
        throw const TExceptions('No authentication token found');
      }
      final response = await httpClient.THttpHelper.get('user', headers: {'Authorization': 'Bearer $token'});
      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to fetch user details');
      }
      final user = UserModel.fromJson(response['user']);
      await saveUserRecord(user); // Store user locally
      return user;
    } catch (e) {
      throw TExceptions('Failed to fetch user details: $e');
    }
  }

  /// Save user record to local storage
  Future<void> saveUserRecord(UserModel user) async {
    try {
      await deviceStorage.write('USER', user.toJson());
    } catch (e) {
      throw TExceptions('Failed to save user record: $e');
    }
  }

  /// Get stored user
  UserModel? getStoredUser() {
    try {
      final userJson = deviceStorage.read('USER');
      if (userJson == null) return null;
      return UserModel.fromJson(userJson);
    } catch (e) {
      throw TExceptions('Failed to retrieve stored user: $e');
    }
  }

  /// Update user record
  Future<void> updateUserRecord(UserModel user) async {
    try {
      final token = Get.find<AuthenticationRepository>().deviceStorage.read('auth_token');
      if (token == null) {
        throw TExceptions('No authentication token found');
      }
      final response = await httpClient.THttpHelper.put(
        'user',
        user.toJson(),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to update user record');
      }
      await saveUserRecord(user); // Update local storage
    } catch (e) {
      throw TExceptions('Failed to update user record: $e');
    }
  }

  /// Update single field
  Future<void> updateSingleField(Map<String, dynamic> data) async {
    try {
      final token = Get.find<AuthenticationRepository>().deviceStorage.read('auth_token');
      if (token == null) {
        throw TExceptions('No authentication token found');
      }
      final response = await httpClient.THttpHelper.patch(
        'user',
        data,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to update user field');
      }
    } catch (e) {
      throw TExceptions('Failed to update user field: $e');
    }
  }

  /// Upload profile picture
  Future<String> uploadProfilePicture(XFile image) async {
    try {
      final token = Get.find<AuthenticationRepository>().deviceStorage.read('auth_token');
      if (token == null) {
        throw TExceptions('No authentication token found');
      }
      final formData = <String, dynamic>{};
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        formData['profile_image'] = httpClient.MultipartFile(
          bytes,
          filename: image.name,
          contentType: image.mimeType,
        );
      } else {
        final file = File(image.path);
        formData['profile_image'] = httpClient.MultipartFile(
          file,
          filename: image.name,
          contentType: image.mimeType,
        );
      }
      await httpClient.THttpHelper.fetchCsrfToken();
      final response = await httpClient.THttpHelper.postMultipart(
        'user/profile-image',
        formData,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to upload profile image');
      }
      return response['data']['profile_image_url'] ?? '';
    } catch (e) {
      throw TExceptions('Failed to upload profile image: $e');
    }
  }

  /// Remove user record
  Future<void> deleteAccount() async {
    try {
      final token = Get.find<AuthenticationRepository>().deviceStorage.read('auth_token');
      if (token == null) {
        throw TExceptions('No authentication token found');
      }
      final response = await httpClient.THttpHelper.delete(
        'user',
        headers: {'Authorization': 'Bearer $token'},
      );
      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to delete account');
      }
      await deviceStorage.remove('USER');
    } catch (e) {
      throw TExceptions('Failed to delete account: $e');
    }
  }
}