import 'package:get/get.dart';
import '../../../features/personalization/models/setting_model.dart';
import '../../../utils/http/http_client.dart';
import '../../../utils/exceptions/exceptions.dart';

class SettingsRepository extends GetxController {
  static SettingsRepository get instance => Get.find();
  final String settingsEndpoint = 'settings/global';

  Future<void> registerSettings(SettingsModel setting) async {
    try {
      await THttpHelper.post(settingsEndpoint, setting.toJson());
    } catch (e) {
      throw TExceptions('Failed to save settings: $e');
    }
  }

  Future<SettingsModel> getSettings() async {
    try {
      final response = await THttpHelper.get(settingsEndpoint);
      return SettingsModel.fromJson(response);
    } catch (e) {
      throw TExceptions('Failed to fetch settings: $e');
    }
  }

  Future<void> updateSettingDetails(SettingsModel updatedSetting) async {
    try {
      await THttpHelper.put(settingsEndpoint, updatedSetting.toJson());
    } catch (e) {
      throw TExceptions('Failed to update settings: $e');
    }
  }

  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await THttpHelper.patch(settingsEndpoint, json);
    } catch (e) {
      throw TExceptions('Failed to update settings field: $e');
    }
  }
}