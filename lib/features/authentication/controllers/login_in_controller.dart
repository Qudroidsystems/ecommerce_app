import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../../personalization/controllers/user_controller.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  /// Variables
  final hidePassword = true.obs;
  final rememberMe = false.obs;
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  final userController = Get.find<UserController>();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    email.text = localStorage.read('REMEMBER_ME_EMAIL') ?? '';
    password.text = localStorage.read('REMEMBER_ME_PASSWORD') ?? '';
    super.onInit();
  }

  /// Email and Password SignIn
  Future<void> emailAndPasswordSignIn() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog('Logging you in...', TImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(title: 'No Internet', message: 'Please check your internet connection.');
        return;
      }

      // Form Validation
      if (!loginFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Save Data if Remember Me is selected
      if (rememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
        localStorage.write('REMEMBER_ME_PASSWORD', password.text.trim());
      } else {
        localStorage.remove('REMEMBER_ME_EMAIL');
        localStorage.remove('REMEMBER_ME_PASSWORD');
      }

      // Login user using Email & Password Authentication
      final response = await AuthenticationRepository.instance.loginWithEmailAndPassword(
        email.text.trim(),
        password.text.trim(),
      );

      // Save user data
      if (response['success']) {
        await userController.saveUserRecord(userResponse: response);
      }

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Redirect
      try {
        await AuthenticationRepository.instance.screenRedirect();
      } catch (e) {
        TLoaders.errorSnackBar(title: 'Navigation Error', message: 'Failed to redirect: $e');
        Get.offAllNamed('/login'); // Fallback to login screen
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Google SignIn Authentication
  Future<void> googleSignIn() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog('Logging you in with Google...', TImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(title: 'No Internet', message: 'Please check your internet connection.');
        return;
      }

      // Google Authentication
      final response = await AuthenticationRepository.instance.signInWithGoogle();
      if (response == null) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(title: 'Cancelled', message: 'Google Sign-In was cancelled.');
        return;
      }

      // Save user data
      if (response['success']) {
        await userController.saveUserRecord(userResponse: response);
      }

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Redirect
      try {
        await AuthenticationRepository.instance.screenRedirect();
      } catch (e) {
        TLoaders.errorSnackBar(title: 'Navigation Error', message: 'Failed to redirect: $e');
        Get.offAllNamed('/login'); // Fallback to login screen
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Facebook SignIn Authentication
  Future<void> facebookSignIn() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog('Logging you in with Facebook...', TImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(title: 'No Internet', message: 'Please check your internet connection.');
        return;
      }

      // Facebook Authentication
      final response = await AuthenticationRepository.instance.signInWithFacebook();
      if (response == null) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(title: 'Cancelled', message: 'Facebook Sign-In was cancelled.');
        return;
      }

      // Save user data
      if (response['success']) {
        await userController.saveUserRecord(userResponse: response);
      }

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Redirect
      try {
        await AuthenticationRepository.instance.screenRedirect();
      } catch (e) {
        TLoaders.errorSnackBar(title: 'Navigation Error', message: 'Failed to redirect: $e');
        Get.offAllNamed('/login'); // Fallback to login screen
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}