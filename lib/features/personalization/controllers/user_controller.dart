import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/exceptions/exceptions.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../models/user_model.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final userRepository = Get.find<UserRepository>();
  final authRepository = Get.find<AuthenticationRepository>();
  final user = UserModel.empty().obs;
  final imageUploading = false.obs;
  final profileLoading = false.obs;
  final hidePassword = true.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  final reAuthFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

  /// Fetch user record
  Future<void> fetchUserRecord() async {
    try {
      profileLoading.value = true;
      final userData = await userRepository.fetchUserDetails();
      user.value = userData;
    } catch (e) {
      user.value = UserModel.empty();
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e is TExceptions ? e.message : 'Failed to fetch user data: $e',
      );
    } finally {
      profileLoading.value = false;
    }
  }

  /// Save user record from API response
  Future<void> saveUserRecord({Map<String, dynamic>? userResponse}) async {
    try {
      profileLoading.value = true;
      if (userResponse != null) {
        final newUser = UserModel.fromJson(userResponse['user']);
        user.value = newUser;
        await userRepository.saveUserRecord(newUser);
      } else {
        throw TExceptions('No user data provided');
      }
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e is TExceptions ? e.message : 'Failed to save user record: $e',
      );
    } finally {
      profileLoading.value = false;
    }
  }

  /// Upload profile picture
  Future<void> uploadUserProfilePicture() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxHeight: 512,
        maxWidth: 512,
      );
      if (image == null) {
        TLoaders.warningSnackBar(title: 'No Image Selected', message: 'Please select an image.');
        return;
      }

      imageUploading.value = true;

      final imageUrl = await userRepository.uploadProfilePicture(image);
      user.value = user.value.copyWith(profileImage: imageUrl);
      await userRepository.updateSingleField({'profile_image': imageUrl});

      TLoaders.successSnackBar(title: 'Success', message: 'Profile picture updated successfully');
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e is TExceptions ? e.message : 'Failed to upload profile picture: $e',
      );
    } finally {
      imageUploading.value = false;
    }
  }

  /// Update gender
  Future<void> updateGender(String gender) async {
    try {
      profileLoading.value = true;
      await userRepository.updateSingleField({'gender': gender});
      user.value = user.value.copyWith(gender: gender);
      TLoaders.successSnackBar(title: 'Success', message: 'Gender updated successfully');
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e is TExceptions ? e.message : 'Failed to update gender: $e',
      );
    } finally {
      profileLoading.value = false;
    }
  }

  /// Update date of birth
  Future<void> updateDateOfBirth(DateTime dateOfBirth) async {
    try {
      profileLoading.value = true;
      await userRepository.updateSingleField({'date_of_birth': dateOfBirth.toIso8601String()});
      user.value = user.value.copyWith(dateOfBirth: dateOfBirth);
      TLoaders.successSnackBar(title: 'Success', message: 'Date of birth updated successfully');
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e is TExceptions ? e.message : 'Failed to update date of birth: $e',
      );
    } finally {
      profileLoading.value = false;
    }
  }

  /// Re-authenticate user
  Future<void> reAuthenticateEmailAndPasswordUser() async {
    try {
      if (!reAuthFormKey.currentState!.validate()) {
        TLoaders.warningSnackBar(title: 'Validation Error', message: 'Please fill in all required fields.');
        return;
      }

      TFullScreenLoader.openLoadingDialog('Re-authenticating...', TImages.docerAnimation);

      final response = await authRepository.reAuthenticateWithEmailAndPassword(
        verifyEmail.text.trim(),
        verifyPassword.text.trim(),
      );

      TFullScreenLoader.stopLoading();

      if (response['success']) {
        TLoaders.successSnackBar(title: 'Success', message: 'Re-authentication successful');
        Get.back(); // Return to previous screen (e.g., ChangeName)
      } else {
        throw TExceptions(response['message'] ?? 'Re-authentication failed');
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e is TExceptions ? e.message : 'Re-authentication failed: $e',
      );
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await authRepository.logout();
      user.value = UserModel.empty(); // Clear user data
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e is TExceptions ? e.message : 'Logout failed: $e',
      );
    }
  }

  /// Delete account warning popup
  Future<void> deleteAccountWarningPopup() async {
    Get.defaultDialog(
      title: 'Delete Account',
      middleText: 'Are you sure you want to delete your account permanently? This action is not reversible.',
      confirm: ElevatedButton(
        onPressed: () async {
          try {
            TFullScreenLoader.openLoadingDialog('Deleting account...', TImages.docerAnimation);
            await userRepository.deleteAccount();
            await authRepository.logout();
            user.value = UserModel.empty(); // Clear user data
            TFullScreenLoader.stopLoading();
            TLoaders.successSnackBar(title: 'Success', message: 'Account deleted successfully');
          } catch (e) {
            TFullScreenLoader.stopLoading();
            TLoaders.errorSnackBar(
              title: 'Error',
              message: e is TExceptions ? e.message : 'Failed to delete account: $e',
            );
          }
        },
        child: const Text('Delete'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }
}