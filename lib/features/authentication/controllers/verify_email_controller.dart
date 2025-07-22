import 'dart:async';
import 'package:get/get.dart';
import '../../../common/widgets/success_screen/success_screen.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/popups/loaders.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../personalization/controllers/user_controller.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();

  final String? email = Get.arguments as String?;

  @override
  void onInit() {
    // Send Email Verification and Set Timer for auto redirect
    sendEmailVerification();
    setTimerForAutoRedirect();
    super.onInit();
  }

  /// Send Email Verification link
  Future<void> sendEmailVerification() async {
    try {
      await AuthenticationRepository.instance.sendEmailVerification();
      TLoaders.successSnackBar(
        title: 'Email Sent',
        message: 'Please check your inbox and verify your email${email != null ? ' ($email)' : ''}.',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Timer to automatically redirect on Email Verification
  void setTimerForAutoRedirect() {
    Timer.periodic(
      const Duration(seconds: 5), // Check every 5 seconds to reduce API calls
          (timer) async {
        try {
          await UserController.instance.fetchUserRecord();
          final user = UserController.instance.user.value;
          if (user.emailVerifiedAt != null) {
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
          // Silently handle errors to avoid spamming the user
        }
      },
    );
  }

  /// Manually Check if Email Verified
  Future<void> checkEmailVerificationStatus() async {
    try {
      await UserController.instance.fetchUserRecord();
      final user = UserController.instance.user.value;
      if (user.emailVerifiedAt != null) {
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
          title: 'Email Not Verified',
          message: 'Please verify your email by clicking the link sent to ${email ?? user.email}.',
        );
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}