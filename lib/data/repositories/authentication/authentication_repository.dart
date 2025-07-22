import 'dart:convert';

import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../features/authentication/screens/login/login.dart';
import '../../../features/authentication/screens/onboarding/onboarding.dart';
import '../../../features/authentication/screens/signup/verify_email.dart';
import '../../../features/personalization/controllers/user_controller.dart';
import '../../../features/personalization/models/user_model.dart';
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
  final _isRedirecting = false.obs;
  final _lastLoginResponse = Rxn<Map<String, dynamic>>();
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _emailKey = 'EMAIL';
  static const _emailVerifiedKey = 'EMAIL_VERIFIED_AT';

  @override
  void onReady() {
    super.onReady();
    screenRedirect();
  }

// Updated loginWithEmailAndPassword method with better debugging
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      print('Login: Starting login process');

      // Try alternative loader first
      TFullScreenLoader.openLoadingDialogAlternative('Logging in...', TImages.docerAnimation);

      // Add a small delay to ensure the loader shows
      await Future.delayed(const Duration(milliseconds: 100));

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoadingAlternative();
        TLoaders.warningSnackBar(title: 'No Connection', message: 'Please check your internet connection.');
        return;
      }

      print('Login: Making API call');
      final response = await THttpHelper.post('login', {
        'email': email,
        'password': password,
      }, skipCsrf: true);

      if (response['success']) {
        print('Login: API call successful, storing data');

        await _storage.write(_tokenKey, response['token']);
        await _storage.write(_userIdKey, response['user']['id'].toString());
        await _storage.write(_emailKey, response['user']['email']);
        await _storage.write(_emailVerifiedKey, response['user']['email_verified_at']);
        _lastLoginResponse.value = response;

        // Update loader text
        TFullScreenLoader.stopLoadingAlternative();
        await Future.delayed(const Duration(milliseconds: 100));
        TFullScreenLoader.openLoadingDialogAlternative('Preparing your experience...', TImages.docerAnimation);

        print('Login: Fetching user record');
        await UserController.instance.fetchUserRecord();

        print('Login: Redirecting to appropriate screen');
        await screenRedirect();

        // Stop loading after navigation
        TFullScreenLoader.stopLoadingAlternative();
        print('Login: Process completed successfully');

      } else {
        TFullScreenLoader.stopLoadingAlternative();
        throw TExceptions(response['message'] ?? 'Login failed', response['statusCode']);
      }
    } catch (e) {
      print('Login: Error occurred: $e');
      TFullScreenLoader.stopLoadingAlternative();
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

      if (response['success']) {
        await _storage.write(_tokenKey, response['token']);
        await _storage.write(_userIdKey, response['user']['id'].toString());
        await _storage.write(_emailKey, response['user']['email']);
        await _storage.write(_emailVerifiedKey, response['user']['email_verified_at']);
        _lastLoginResponse.value = response;

        // Keep loading while navigating
        await Get.offAll(() => VerifyEmailScreen(email: email));

        // Stop loading after navigation
        TFullScreenLoader.stopLoading();
      } else {
        TFullScreenLoader.stopLoading();
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
        throw const TExceptions('Google Sign-In cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final response = await THttpHelper.post('social-login', {
        'provider': 'google',
        'access_token': googleAuth.accessToken,
      }, skipCsrf: true);

      if (response['success']) {
        await _storage.write(_tokenKey, response['token']);
        await _storage.write(_userIdKey, response['user']['id'].toString());
        await _storage.write(_emailKey, response['user']['email']);
        await _storage.write(_emailVerifiedKey, response['user']['email_verified_at']);
        _lastLoginResponse.value = response;

        // Keep loading while fetching user data and navigating
        await UserController.instance.fetchUserRecord();
        await screenRedirect();

        // Only stop loading after successful navigation
        TFullScreenLoader.stopLoading();
      } else {
        TFullScreenLoader.stopLoading();
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

      if (response['success']) {
        await _storage.write(_tokenKey, response['token']);
        await _storage.write(_userIdKey, response['user']['id'].toString());
        await _storage.write(_emailKey, response['user']['email']);
        await _storage.write(_emailVerifiedKey, response['user']['email_verified_at']);
        _lastLoginResponse.value = response;

        // Keep loading while fetching user data and navigating
        await UserController.instance.fetchUserRecord();
        await screenRedirect();

        // Only stop loading after successful navigation
        TFullScreenLoader.stopLoading();
      } else {
        TFullScreenLoader.stopLoading();
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
      await _storage.remove(_tokenKey);
      await _storage.remove(_userIdKey);
      await _storage.remove(_emailKey);
      await _storage.remove(_emailVerifiedKey);
      _lastLoginResponse.value = null;
      TFullScreenLoader.stopLoading();
      await Get.offAll(() => const LoginScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      throw TExceptions('Failed to delete account: $e');
    }
  }

  Future<void> logout() async {
    try {
      TFullScreenLoader.openLoadingDialog('Logging out...', TImages.docerAnimation);
      await THttpHelper.post('logout', {});
      await _storage.remove(_tokenKey);
      await _storage.remove(_userIdKey);
      await _storage.remove(_emailKey);
      await _storage.remove(_emailVerifiedKey);
      _lastLoginResponse.value = null;
      TFullScreenLoader.stopLoading();
      await Get.offAll(() => const LoginScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      throw TExceptions('Logout failed: $e');
    }
  }

  // Updated screenRedirect method
  Future<void> screenRedirect() async {
    print('screenRedirect: Starting screenRedirect');

    final token = _storage.read(_tokenKey);
    print('screenRedirect: Token exists: ${token != null}');

    if (token != null && token.isNotEmpty) {
      try {
        print('screenRedirect: Fetching user record...');
        final user = await UserController.instance.fetchUserRecord();
        print('screenRedirect: User fetched: ID=${user.id}, EmailVerifiedAt=${user.emailVerifiedAt}');

        // Add a small delay to show the loader
        await Future.delayed(const Duration(milliseconds: 500));

        // Remove splash screen before navigation
        FlutterNativeSplash.remove();

        if (user.id.isNotEmpty && user.emailVerifiedAt == null) {
          print('screenRedirect: Redirecting to VerifyEmailScreen');
          await Get.offAll(() => VerifyEmailScreen(email: user.email));
        } else if (user.id.isNotEmpty) {
          print('screenRedirect: Redirecting to HomeScreen');
          await Get.offAll(() => const HomeScreen());
        } else {
          print('screenRedirect: Invalid user data, clearing token');
          await _clearStorage();
          await Get.offAll(() => const LoginScreen());
        }
      } catch (e, stackTrace) {
        print('screenRedirect: Error fetching user: $e');

        // Remove splash screen
        FlutterNativeSplash.remove();

        if (e.toString().contains('Unauthorized') || e.toString().contains('Failed to parse response')) {
          print('screenRedirect: Invalid token, clearing and redirecting to login');
          await _clearStorage();
          await Get.offAll(() => const LoginScreen());
        } else if (_lastLoginResponse.value != null && _lastLoginResponse.value!['user'] != null) {
          final userData = _lastLoginResponse.value!['user'];
          UserController.instance.user.value = UserModel.fromJson(userData);
          print('screenRedirect: Using login response user data, redirecting to HomeScreen');
          await Get.offAll(() => const HomeScreen());
        } else {
          print('screenRedirect: No user data available, clearing token and redirecting to LoginScreen');
          await _clearStorage();
          await Get.offAll(() => const LoginScreen());
        }
      }
    } else {
      print('screenRedirect: No token found, checking isFirstTime');
      FlutterNativeSplash.remove();
      final isFirstTime = _storage.read('isFirstTime') ?? true;
      if (isFirstTime) {
        print('screenRedirect: First time user, redirecting to OnBoardingScreen');
        await _storage.write('isFirstTime', false);
        await Get.offAll(() => const OnBoardingScreen());
      } else {
        print('screenRedirect: Not first time, redirecting to LoginScreen');
        await Get.offAll(() => const LoginScreen());
      }
    }
  }

  Future<void> _clearStorage() async {
    await _storage.remove(_tokenKey);
    await _storage.remove(_userIdKey);
    await _storage.remove(_emailKey);
    await _storage.remove(_emailVerifiedKey);
    _lastLoginResponse.value = null;
  }

  String get getUserID => UserController.instance.user.value.id;
}