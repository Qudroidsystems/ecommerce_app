import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../features/personalization/models/user_model.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../../utils/http/http_client.dart';


/// Repository class for user-related operations.
class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  /// Function to save user data to Laravel backend.
  Future<void> saveUserRecord(UserModel user) async {
    try {
      await THttpHelper.post('user', user.toJson());
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Function to fetch user details from Laravel backend.
  Future<UserModel> fetchUserDetails() async {
    try {
      final response = await THttpHelper.get('user');
      if (response['success']) {
        return UserModel.fromJson(response['user']);
      } else {
        throw response['message'];
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Function to update user data in Laravel backend.
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await THttpHelper.put('user', updatedUser.toJson());
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Update any field in specific Users endpoint
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await THttpHelper.patch('user', json);
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Upload any Image
  Future<String> uploadImage(String path, XFile image) async {
    try {
      // Fetch CSRF token before making the multipart request
      await THttpHelper.fetchCsrfToken();

      final uri = Uri.parse('${THttpHelper.baseUrl}/user/profile-picture');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      // Get headers with Bearer token
      final headers = await THttpHelper.getHeaders();
      request.headers.addAll(headers);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonResponse['url']; // Adjust based on your Laravel response
      } else {
        throw jsonResponse['message'] ?? 'Failed to upload image: ${response.statusCode}';
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Function to remove user data from Laravel backend.
  Future<void> removeUserRecord(String userId) async {
    try {
      await THttpHelper.delete('user');
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Handle exceptions
  String _handleException(dynamic e) {
    if (e is FormatException) {
      return 'Invalid format. Please check your input.';
    } else if (e is PlatformException) {
      return 'Platform error: ${e.message}';
    } else {
      return e.toString();
    }
  }
}