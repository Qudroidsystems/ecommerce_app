import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../common/widgets/success_screen/success_screen.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/popups/loaders.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();

  @override
  void onInit() {
    // Send email verification when the screen appears
    sendEmailVerification();
    // Start polling to check verification status
    setTimerForAutoRedirect();
    super.onInit();
  }

  /// Send Email Verification link
  Future<void> sendEmailVerification() async {
    try {
      await AuthenticationRepository.instance.sendEmailVerification();
      TLoaders.successSnackBar(
          title: 'Email Sent', message: 'Please check your inbox and verify your email.');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Timer to automatically check email verification status
  Future<void> setTimerForAutoRedirect() async {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final response = await AuthenticationRepository.instance.checkEmailVerificationStatus();
        if (response['success'] && response['user']['email_verified_at'] != null) {
          timer.cancel();
          Get.off(
                () => SuccessScreen(
              image: TImages.successfullyRegisterAnimation,
              title: TTexts.yourAccountCreatedTitle,
              subTitle: TTexts.yourAccountCreatedSubTitle,
              onPressed: () => AuthenticationRepository.instance.screenRedirect(),
            ),
          );
        }
      } catch (e) {
        // Silently handle errors to avoid spamming the user during polling
        if (kDebugMode) print('Verification check failed: $e');
      }
    });
  }

  /// Manually Check if Email Verified
  Future<void> checkEmailVerificationStatus() async {
    try {
      final response = await AuthenticationRepository.instance.checkEmailVerificationStatus();
      if (response['success'] && response['user']['email_verified_at'] != null) {
        Get.off(
              () => SuccessScreen(
            image: TImages.successfullyRegisterAnimation,
            title: TTexts.yourAccountCreatedTitle,
            subTitle: TTexts.yourAccountCreatedSubTitle,
            onPressed: () => AuthenticationRepository.instance.screenRedirect(),
          ),
        );
      } else {
        TLoaders.warningSnackBar(
            title: 'Email Not Verified', message: 'Please verify your email to continue.');
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}