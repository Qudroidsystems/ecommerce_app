import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app.dart';
import 'data/repositories/authentication/authentication_repository.dart';

/// -- Entry point of Flutter App
Future<void> main() async {
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  /// -- GetX Local Storage
  await GetStorage.init();

  /// -- Overcome transparent spaces at the bottom in iOS full Mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  /// -- Await Splash until other items Load
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// -- Initialize Authentication Repository
  Get.put(AuthenticationRepository());

  /// -- Main App Starts here...
  runApp(const App());
}