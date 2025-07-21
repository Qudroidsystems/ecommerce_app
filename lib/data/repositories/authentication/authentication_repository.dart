import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../features/personalization/models/user_model.dart';
import '../../../utils/exceptions/exceptions.dart';
import '../../../utils/http/http_client.dart' as httpClient;
import '../user/user_repository.dart';


class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();


  final _httpClient = Get.put(httpClient.THttpHelper());
  final deviceStorage = GetStorage();
  final userRepository = Get.put(UserRepository());
  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  @override
  void onReady() {
    screenRedirect();
    super.onReady();
  }

  /// Get the authenticated user ID
  String get getUserID {
    final user = userRepository.getStoredUser();
    if (user == null || user.id.isEmpty) {
      throw const TExceptions('No authenticated user found');
    }
    return user.id;
  }

  /// Check authentication status and redirect
  Future<void> screenRedirect() async {
    final token = deviceStorage.read('auth_token');
    if (token != null) {
      try {
        final user = await userRepository.fetchUserDetails();
        if (user.emailVerifiedAt == null) {
          Get.offAllNamed('/verify-email');
        } else {
          Get.offAllNamed('/home');
        }
      } catch (e) {
        Get.offAllNamed('/login');
      }
    } else {
      Get.offAllNamed('/login');
    }
  }

  /// Register with email and password
  Future<Map<String, dynamic>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? gender,
    String? dateOfBirth,
  }) async {
    try {
      final response = await httpClient.THttpHelper.post('register', {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (gender != null) 'gender': gender,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Registration failed');
      }

      final token = response['token'];
      deviceStorage.write('auth_token', token);
      await userRepository.saveUserRecord(UserModel.fromJson(response['user']));

      return response;
    } catch (e) {
      throw TExceptions('Registration failed: $e');
    }
  }

  /// Login with email and password
  Future<Map<String, dynamic>> loginWithEmailAndPassword(String email, String password) async {
    try {
      final response = await httpClient.THttpHelper.post('login', {
        'email': email,
        'password': password,
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Login failed');
      }

      final token = response['token'];
      deviceStorage.write('auth_token', token);
      await userRepository.saveUserRecord(UserModel.fromJson(response['user']));

      return response;
    } catch (e) {
      throw TExceptions('Login failed: $e');
    }
  }

  /// Google Sign-In
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user == null) {
        throw TExceptions('Google Sign-In cancelled by user');
      }

      final googleAuth = await user.authentication;
      final accessToken = googleAuth.accessToken;
      if (accessToken == null) {
        throw TExceptions('Failed to obtain Google access token');
      }

      final response = await httpClient.THttpHelper.post('social-login', {
        'provider': 'google',
        'access_token': accessToken,
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Google Sign-In failed');
      }

      final token = response['token'];
      deviceStorage.write('auth_token', token);
      await userRepository.saveUserRecord(UserModel.fromJson(response['user']));

      return response;
    } catch (e) {
      throw TExceptions('Google Sign-In failed: $e');
    }
  }

  /// Facebook Sign-In
  Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      final loginResult = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);
      if (loginResult.status != LoginStatus.success) {
        throw TExceptions('Facebook Sign-In cancelled or failed: ${loginResult.message}');
      }

      final accessToken = loginResult.accessToken?.token;
      if (accessToken == null) {
        throw TExceptions('Failed to obtain Facebook access token');
      }

      final response = await httpClient.THttpHelper.post('social-login', {
        'provider': 'facebook',
        'access_token': accessToken,
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Facebook Sign-In failed');
      }

      final token = response['token'];
      deviceStorage.write('auth_token', token);
      await userRepository.saveUserRecord(UserModel.fromJson(response['user']));

      return response;
    } catch (e) {
      throw TExceptions('Facebook Sign-In failed: $e');
    }
  }

  /// Re-authenticate for sensitive actions
  Future<Map<String, dynamic>> reAuthenticateWithEmailAndPassword(String email, String password) async {
    try {
      final response = await httpClient.THttpHelper.post('login', {
        'email': email,
        'password': password,
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Re-authentication failed');
      }

      return response;
    } catch (e) {
      throw TExceptions('Re-authentication failed: $e');
    }
  }

  /// Send email verification notification
  Future<void> sendEmailVerification() async {
    try {
      final response = await httpClient.THttpHelper.post('email/verification-notification', {}, headers: {
        'Authorization': 'Bearer ${deviceStorage.read('auth_token')}',
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to send verification email');
      }
    } catch (e) {
      throw TExceptions('Failed to send verification email: $e');
    }
  }

  /// Check email verification status
  Future<Map<String, dynamic>> checkEmailVerificationStatus() async {
    try {
      final response = await httpClient.THttpHelper.get('user', headers: {
        'Authorization': 'Bearer ${deviceStorage.read('auth_token')}',
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to check verification status');
      }

      await userRepository.saveUserRecord(UserModel.fromJson(response['user']));
      return response;
    } catch (e) {
      throw TExceptions('Failed to check verification status: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final response = await httpClient.THttpHelper.post('password/email', {'email': email});

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Failed to send password reset email');
      }
    } catch (e) {
      throw TExceptions('Failed to send password reset email: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final response = await httpClient.THttpHelper.post('logout', {}, headers: {
        'Authorization': 'Bearer ${deviceStorage.read('auth_token')}',
      });

      if (!response['success']) {
        throw TExceptions(response['message'] ?? 'Logout failed');
      }

      deviceStorage.remove('auth_token');
      Get.offAllNamed('/login');
    } catch (e) {
      throw TExceptions('Logout failed: $e');
    }
  }
}