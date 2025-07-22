import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../features/authentication/screens/login/login.dart';
import '../../../features/authentication/screens/signup/verify_email.dart';
import '../../../features/personalization/controllers/user_controller.dart';
import '../../../features/shop/screens/home/home.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/exceptions/exceptions.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/http/http_client.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final _storage = GetStorage();

  @override
  void onReady() {
    super.onReady();
    // Add a small delay to ensure all dependencies are ready
    Future.delayed(const Duration(milliseconds: 500), () {
      screenRedirect();
    });
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      TFullScreenLoader.openLoadingDialog('Logging in...', TImages.docerAnimation);
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(title: 'No Connection', message: 'Please check your internet connection.');
        return;
      }
      final response = await THttpHelper.post('login', {
        'email': email,
        'password': password,
      }, skipCsrf: true);
      TFullScreenLoader.stopLoading();
      if (response['success']) {
        await _storage.write('auth_token', response['token']);
        await UserController.instance.fetchUserRecord();
        await screenRedirect();
      } else {
        throw TExceptions(response['message'] ?? 'Login failed', response['statusCode']);
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      TFullScreenLoader.openLoadingDialog('Registering...', TImages.docerAnimation);
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(title: 'No Connection', message: 'Please check your internet connection.');
        return;
      }
      final response = await THttpHelper.post('register', {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
      }, skipCsrf: true);
      TFullScreenLoader.stopLoading();
      if (response['success']) {
        await _storage.write('auth_token', response['token']);
        Get.to(() => VerifyEmailScreen(email: email));
      } else {
        throw TExceptions(response['message'] ?? 'Registration failed', response['statusCode']);
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      TFullScreenLoader.openLoadingDialog('Signing in with Google...', TImages.docerAnimation);
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(title: 'No Connection', message: 'Please check your internet connection.');
        return;
      }
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        TFullScreenLoader.stopLoading();
        throw TExceptions('Google Sign-In cancelled');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final response = await THttpHelper.post('social-login', {
        'provider': 'google',
        'access_token': googleAuth.accessToken,
      }, skipCsrf: true);
      TFullScreenLoader.stopLoading();
      if (response['success']) {
        await _storage.write('auth_token', response['token']);
        await UserController.instance.fetchUserRecord();
        await screenRedirect();
      } else {
        throw TExceptions(response['message'] ?? 'Google Sign-In failed', response['statusCode']);
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      TFullScreenLoader.openLoadingDialog('Signing in with Facebook...', TImages.docerAnimation);
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(title: 'No Connection', message: 'Please check your internet connection.');
        return;
      }
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) {
        TFullScreenLoader.stopLoading();
        throw TExceptions('Facebook Sign-In cancelled or failed');
      }
      final response = await THttpHelper.post('social-login', {
        'provider': 'facebook',
        'access_token': result.accessToken!.token,
      }, skipCsrf: true);
      TFullScreenLoader.stopLoading();
      if (response['success']) {
        await _storage.write('auth_token', response['token']);
        await UserController.instance.fetchUserRecord();
        await screenRedirect();
      } else {
        throw TExceptions(response['message'] ?? 'Facebook Sign-In failed', response['statusCode']);
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      TFullScreenLoader.openLoadingDialog('Sending password reset email...', TImages.docerAnimation);
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(title: 'No Connection', message: 'Please check your internet connection.');
        return;
      }
      final response = await THttpHelper.post('password/email', {
        'email': email,
      }, skipCsrf: true);
      TFullScreenLoader.stopLoading();
      if (response['success']) {
        TLoaders.successSnackBar(
          title: 'Success',
          message: response['message'] ?? 'Password reset link sent to your email.',
        );
      } else {
        throw TExceptions(response['message'] ?? 'Failed to send password reset email', response['statusCode']);
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await THttpHelper.post('email/verification-notification', {});
    } catch (e) {
      throw TExceptions('Failed to send verification email: $e');
    }
  }

  Future<void> reAuthenticateWithEmailAndPassword(String email, String password) async {
    try {
      TFullScreenLoader.openLoadingDialog('Re-authenticating...', TImages.docerAnimation);
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(title: 'No Connection', message: 'Please check your internet connection.');
        return;
      }
      final response = await THttpHelper.post('login', {
        'email': email,
        'password': password,
      }, skipCsrf: true);
      TFullScreenLoader.stopLoading();
      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Re-authentication failed', response['statusCode']);
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      throw TExceptions('Re-authentication failed: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      TFullScreenLoader.openLoadingDialog('Deleting account...', TImages.docerAnimation);
      await THttpHelper.delete('user');
      await _storage.remove('auth_token');
      TFullScreenLoader.stopLoading();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      throw TExceptions('Failed to delete account: $e');
    }
  }

  Future<void> logout() async {
    try {
      TFullScreenLoader.openLoadingDialog('Logging out...', TImages.docerAnimation);
      await THttpHelper.post('logout', {});
      await _storage.remove('auth_token');
      TFullScreenLoader.stopLoading();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      throw TExceptions('Logout failed: $e');
    }
  }

  Future<void> screenRedirect() async {
    try {
      // Hide the splash screen
      FlutterNativeSplash.remove();

      // Check if user has auth token
      final token = _storage.read('auth_token');

      if (token != null && token.isNotEmpty) {
        // User has token, try to fetch user data
        try {
          await UserController.instance.fetchUserRecord();
          final user = UserController.instance.user.value;

          if (user.id.isNotEmpty && user.emailVerifiedAt == null) {
            // User exists but email not verified
            Get.offAll(() => VerifyEmailScreen(email: user.email));
          } else if (user.id.isNotEmpty) {
            // User exists and email verified
            Get.offAll(() => const HomeScreen());
          } else {
            // Token invalid, go to login
            await _storage.remove('auth_token');
            Get.offAll(() => const LoginScreen());
          }
        } catch (e) {
          // Error fetching user, token might be invalid
          await _storage.remove('auth_token');
          Get.offAll(() => const LoginScreen());
        }
      } else {
        // No token, go to login
        Get.offAll(() => const LoginScreen());
      }
    } catch (e) {
      // Fallback to login screen
      Get.offAll(() => const LoginScreen());
    }
  }

  String get getUserID => UserController.instance.user.value.id;
}