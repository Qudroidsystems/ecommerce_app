import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widgets/loaders/animation_loader.dart';
import '../constants/colors.dart';
import '../helpers/helper_functions.dart';

class TFullScreenLoader {
  static OverlayEntry? _overlayEntry;
  static bool _isLoading = false;

  static void openLoadingDialog(String text, String animation) {
    if (_isLoading) {
      print('TFullScreenLoader: Already loading, ignoring new request');
      return;
    }

    print('TFullScreenLoader: Opening loading dialog with text: $text');
    _isLoading = true;

    // Use WidgetsBinding to ensure we have a valid context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Get the overlay from the current context
        final context = Get.context ?? Get.overlayContext ?? navigatorKey.currentContext;
        if (context == null) {
          print('TFullScreenLoader: No valid context found');
          _isLoading = false;
          return;
        }

        final overlay = Overlay.of(context);
        if (overlay == null) {
          print('TFullScreenLoader: No overlay found');
          _isLoading = false;
          return;
        }

        _overlayEntry = OverlayEntry(
          builder: (context) => Material(
            color: Colors.transparent,
            child: Container(
              color: THelperFunctions.isDarkMode(context)
                  ? TColors.dark.withOpacity(0.9)
                  : TColors.white.withOpacity(0.9),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 50),
                      TAnimationLoaderWidget(text: text, animation: animation),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        overlay.insert(_overlayEntry!);
        print('TFullScreenLoader: Loading dialog inserted');
      } catch (e) {
        print('TFullScreenLoader: Error opening dialog: $e');
        _isLoading = false;
        _overlayEntry = null;
      }
    });
  }

  static void stopLoading() {
    if (!_isLoading || _overlayEntry == null) {
      print('TFullScreenLoader: No loading dialog to stop');
      return;
    }

    print('TFullScreenLoader: Stopping loading dialog');

    try {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isLoading = false;
      print('TFullScreenLoader: Loading dialog stopped successfully');
    } catch (e) {
      print('TFullScreenLoader: Error stopping loader: $e');
      _overlayEntry = null;
      _isLoading = false;
    }
  }

  // Alternative method using showDialog with better context management
  static void openLoadingDialogAlternative(String text, String animation) {
    if (_isLoading) {
      print('TFullScreenLoader: Already loading, ignoring new request');
      return;
    }

    _isLoading = true;
    print('TFullScreenLoader: Opening alternative loading dialog');

    // Ensure we run this after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final context = Get.context ?? Get.overlayContext ?? navigatorKey.currentContext;
        if (context == null) {
          print('TFullScreenLoader: No context available');
          _isLoading = false;
          return;
        }

        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          pageBuilder: (context, dialogAnimation, secondaryAnimation) {
            return PopScope(
              canPop: false,
              child: Scaffold(
                backgroundColor: THelperFunctions.isDarkMode(context)
                    ? TColors.dark.withOpacity(0.9)
                    : TColors.white.withOpacity(0.9),
                body: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 50),
                        TAnimationLoaderWidget(text: text, animation: animation),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ).then((_) {
          _isLoading = false;
          print('TFullScreenLoader: Alternative dialog closed');
        });
      } catch (e) {
        print('TFullScreenLoader: Error with alternative dialog: $e');
        _isLoading = false;
      }
    });
  }

  static void stopLoadingAlternative() {
    if (!_isLoading) {
      return;
    }

    try {
      final context = Get.context ?? Get.overlayContext ?? navigatorKey.currentContext;
      if (context != null && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        print('TFullScreenLoader: Alternative dialog popped');
      }
    } catch (e) {
      print('TFullScreenLoader: Error stopping alternative dialog: $e');
    } finally {
      _isLoading = false;
    }
  }

  static bool get isLoading => _isLoading;

  // Force stop all loaders
  static void forceStopAll() {
    print('TFullScreenLoader: Force stopping all loaders');

    // Stop overlay version
    try {
      _overlayEntry?.remove();
    } catch (e) {
      print('TFullScreenLoader: Error removing overlay: $e');
    }

    // Stop dialog version
    try {
      final context = Get.context ?? Get.overlayContext ?? navigatorKey.currentContext;
      if (context != null) {
        while (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      print('TFullScreenLoader: Error popping dialogs: $e');
    }

    _overlayEntry = null;
    _isLoading = false;
  }
}

// You'll need to add this to your main.dart or wherever you initialize your app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();