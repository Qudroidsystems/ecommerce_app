import 'package:get/get.dart';
import '../../../features/personalization/models/setting_model.dart';
import '../../../utils/exceptions/exceptions.dart';
import '../../../utils/http/http_client.dart';
import '../authentication/authentication_repository.dart';

class SettingsRepository extends GetxController {
  static SettingsRepository get instance => Get.find();

  final _httpClient = Get.find<THttpHelper>();

  /// Save setting data to the backend
  Future<void> registerSettings(SettingsModel setting) async {
    try {
      final response = await THttpHelper.post('settings', setting.toJson(), headers: {
        'Authorization': 'Bearer ${Get.find<AuthenticationRepository>().deviceStorage.read('auth_token')}',
        'Content-Type': 'application/json',
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to save settings');
      }
    } catch (e) {
      throw TExceptions('Something went wrong while saving settings: $e');
    }
  }

  /// Fetch setting details
  Future<SettingsModel> getSettings() async {
    try {
      final response = await THttpHelper.get('settings', headers: {
        'Authorization': 'Bearer ${Get.find<AuthenticationRepository>().deviceStorage.read('auth_token')}',
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to fetch settings');
      }

      return SettingsModel.fromJson(response['settings']);
    } catch (e) {
      throw TExceptions('Something went wrong while fetching settings: $e');
    }
  }

  /// Update setting data
  Future<void> updateSettingDetails(SettingsModel updatedSetting) async {
    try {
      final response = await THttpHelper.put('settings', updatedSetting.toJson(), headers: {
        'Authorization': 'Bearer ${Get.find<AuthenticationRepository>().deviceStorage.read('auth_token')}',
        'Content-Type': 'application/json',
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to update settings');
      }
    } catch (e) {
      throw TExceptions('Something went wrong while updating settings: $e');
    }
  }

  /// Update a single field in settings
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      final response = await THttpHelper.patch('settings', json, headers: {
        'Authorization': 'Bearer ${Get.find<AuthenticationRepository>().deviceStorage.read('auth_token')}',
        'Content-Type': 'application/json',
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to update settings field');
      }
    } catch (e) {
      throw TExceptions('Something went wrong while updating settings field: $e');
    }
  }
}