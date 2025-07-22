import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../common/widgets/loaders/circular_loader.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../../authentication/screens/login/login.dart';
import '../models/user_model.dart';
import '../screens/profile/re_authenticate_user_login_form.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  Rx<UserModel> user = UserModel.empty().obs;
  final imageUploading = false.obs;
  final profileLoading = false.obs;
  final profileImageUrl = ''.obs;
  final hidePassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    fetchUserRecord();
    super.onInit();
  }

  Future<void> fetchUserRecord() async {
    try {
      print('fetchUserRecord called');
      profileLoading.value = true;
      final userData = await userRepository.fetchUserDetails();
      print('User data fetched: ${userData.toJson()}');
      user(userData);
      print('User controller updated');
    } catch (e) {
      print('fetchUserRecord error: $e');
      user(UserModel.empty());
      // Don't show error snackbar during initial app load
      // Only show it if this is called manually by user
      if (Get.currentRoute != '/') {
        TLoaders.warningSnackBar(title: 'Error', message: e.toString());
      }
      // Rethrow the exception so AuthenticationRepository can handle it
      rethrow;
    } finally {
      profileLoading.value = false;
    }
  }

  Future<void> saveUserRecord({UserModel? user}) async {
    try {
      await fetchUserRecord();
      if (this.user.value.id.isEmpty && user != null) {
        await userRepository.saveUserRecord(user);
        this.user(user);
      }
    } catch (e) {
      TLoaders.warningSnackBar(
        title: 'Data not saved',
        message: 'Something went wrong while saving your information. You can re-save your data in your Profile.',
      );
    }
  }

  Future<void> uploadUserProfilePicture() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxHeight: 512,
        maxWidth: 512,
      );
      if (image == null) {
        TLoaders.warningSnackBar(title: 'No Image', message: 'No image selected.');
        return;
      }
      imageUploading.value = true;
      final uploadedImage = await userRepository.uploadImage('Users/Profile', image);
      profileImageUrl.value = uploadedImage;
      user.value = user.value.copyWith(profileImage: uploadedImage);
      await userRepository.updateSingleField({'profile_image': uploadedImage});
      user.refresh();
      TLoaders.successSnackBar(
        title: 'Congratulations',
        message: 'Your Profile Image has been updated!',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      imageUploading.value = false;
    }
  }

  void deleteAccountWarningPopup() {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(TSizes.md),
      title: 'Delete Account',
      middleText:
      'Are you sure you want to delete your account permanently? This action is not reversible and all of your data will be removed permanently.',
      confirm: ElevatedButton(
        onPressed: () async => deleteUserAccount(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
          child: Text('Delete'),
        ),
      ),
      cancel: OutlinedButton(
        child: const Text('Cancel'),
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
      ),
    );
  }

  Future<void> deleteUserAccount() async {
    try {
      TFullScreenLoader.openLoadingDialog('Processing', TImages.docerAnimation);
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(title: 'No Connection', message: 'Please check your internet connection.');
        return;
      }
      if (user.value.socialProvider != null) {
        await AuthenticationRepository.instance.deleteAccount();
        TFullScreenLoader.stopLoading();
        Get.offAll(() => const LoginScreen());
      } else {
        TFullScreenLoader.stopLoading();
        Get.to(() => const ReAuthLoginForm());
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  Future<void> reAuthenticateEmailAndPasswordUser() async {
    try {
      TFullScreenLoader.openLoadingDialog('Processing', TImages.docerAnimation);
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(title: 'No Connection', message: 'Please check your internet connection.');
        return;
      }
      if (!reAuthFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }
      await AuthenticationRepository.instance.reAuthenticateWithEmailAndPassword(
        verifyEmail.text.trim(),
        verifyPassword.text.trim(),
      );
      await AuthenticationRepository.instance.deleteAccount();
      TFullScreenLoader.stopLoading();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  Future<void> logout() async {
    try {
      Get.defaultDialog(
        contentPadding: const EdgeInsets.all(TSizes.md),
        title: 'Logout',
        middleText: 'Are you sure you want to Logout?',
        confirm: ElevatedButton(
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
            child: Text('Confirm'),
          ),
          onPressed: () async {
            Navigator.of(Get.overlayContext!).pop();
            Get.defaultDialog(
              title: '',
              barrierDismissible: false,
              backgroundColor: Colors.transparent,
              content: const TCircularLoader(),
            );
            await AuthenticationRepository.instance.logout();
          },
        ),
        cancel: OutlinedButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        ),
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}