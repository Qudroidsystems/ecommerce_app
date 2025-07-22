import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cwt_ecommerce_app/utils/http/http_client.dart'; // Adjust path to your THttpHelper
import 'package:cwt_ecommerce_app/utils/exceptions/exceptions.dart'; // Adjust path to your TExceptions

/// Helper functions for API-related operations.
class TCloudHelperFunctions {
  /// Helper function to check the state of a single API record.
  ///
  /// Returns a Widget based on the state of the snapshot.
  /// If data is still loading, it returns a CircularProgressIndicator.
  /// If no data is found, it returns a generic "No Data Found" message.
  /// If an error occurs, it returns a generic error message or custom error message.
  /// Otherwise, it returns null.
  static Widget? checkSingleRecordState<T>(
      AsyncSnapshot<T> snapshot, {
        String? errorMessage,
      }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data == null) {
      return const Center(child: Text('No Data Found!'));
    }

    if (snapshot.hasError) {
      return Center(child: Text(errorMessage ?? 'Something went wrong.'));
    }

    return null;
  }

  /// Helper function to check the state of multiple (list) API records.
  ///
  /// Returns a Widget based on the state of the snapshot.
  /// If data is still loading, it returns a loader widget or CircularProgressIndicator.
  /// If no data is found, it returns a generic "No Data Found" message or a custom nothingFound widget.
  /// If an error occurs, it returns a generic error message or a custom error widget.
  /// Otherwise, it returns null.
  static Widget? checkMultiRecordState<T>({
    required AsyncSnapshot<List<T>> snapshot,
    Widget? loader,
    Widget? error,
    Widget? nothingFound,
    String? errorMessage,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return loader ?? const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
      return nothingFound ?? const Center(child: Text('No Data Found!'));
    }

    if (snapshot.hasError) {
      return error ?? Center(child: Text(errorMessage ?? 'Something went wrong.'));
    }

    return null;
  }

  /// Retrieve the URL for a file by uploading it to the API if it’s a local file,
  /// or return the URL directly if it’s already hosted.
  static Future<String> getURLFromFilePathAndName(String path) async {
    try {
      if (path.isEmpty) return '';

      // Check if the path is a local file or a URL
      if (File(path).existsSync()) {
        // If it’s a local file, upload it to the API
        final response = await THttpHelper.uploadFile('api/upload', File(path), 'file');
        return response['url'] ?? '';
      } else {
        // Assume it’s already a URL (e.g., from previous upload or external source)
        return path;
      }
    } catch (e) {
      throw TExceptions('Failed to get URL from file path: $e');
    }
  }

  /// Validate or return a URL directly (no transformation needed for API-based URLs).
  static Future<String> getURLFromURI(String url) async {
    try {
      if (url.isEmpty) return '';

      // For an API-based system, the URL is likely already valid.
      // Optionally, you could add a HEAD request to verify the URL’s validity.
      return url;
    } catch (e) {
      throw TExceptions('Failed to validate URL: $e');
    }
  }
}