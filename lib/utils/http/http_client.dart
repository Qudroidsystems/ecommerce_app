import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../exceptions/exceptions.dart';

class MultipartFile {
  final dynamic data; // File for mobile, Uint8List for web
  final String filename;
  final String? contentType;

  MultipartFile(this.data, {required this.filename, this.contentType});
}

class THttpHelper {
  static const String _baseUrl = 'http://10.0.2.2:8000/api'; // Update to production URL

  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$_baseUrl/${endpoint.replaceAll(RegExp(r'^/+'), '')}');
      print('THttpHelper: GET request to $url, headers: $headers');
      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      print('THttpHelper: GET error: $e');
      throw TExceptions('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, dynamic data, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$_baseUrl/${endpoint.replaceAll(RegExp(r'^/+'), '')}');
      final defaultHeaders = {'Content-Type': 'application/json', ...?headers};
      print('THttpHelper: POST request to $url, data: $data, headers: $defaultHeaders');
      final response = await http.post(url, headers: defaultHeaders, body: jsonEncode(data));
      return _handleResponse(response);
    } catch (e) {
      print('THttpHelper: POST error: $e');
      throw TExceptions('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> put(String endpoint, dynamic data, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$_baseUrl/${endpoint.replaceAll(RegExp(r'^/+'), '')}');
      final defaultHeaders = {'Content-Type': 'application/json', ...?headers};
      print('THttpHelper: PUT request to $url, data: $data, headers: $defaultHeaders');
      final response = await http.put(url, headers: defaultHeaders, body: jsonEncode(data));
      return _handleResponse(response);
    } catch (e) {
      print('THttpHelper: PUT error: $e');
      throw TExceptions('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> patch(String endpoint, dynamic data, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$_baseUrl/${endpoint.replaceAll(RegExp(r'^/+'), '')}');
      final defaultHeaders = {'Content-Type': 'application/json', ...?headers};
      print('THttpHelper: PATCH request to $url, data: $data, headers: $defaultHeaders');
      final response = await http.patch(url, headers: defaultHeaders, body: jsonEncode(data));
      return _handleResponse(response);
    } catch (e) {
      print('THttpHelper: PATCH error: $e');
      throw TExceptions('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$_baseUrl/${endpoint.replaceAll(RegExp(r'^/+'), '')}');
      print('THttpHelper: DELETE request to $url, headers: $headers');
      final response = await http.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      print('THttpHelper: DELETE error: $e');
      throw TExceptions('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> uploadFile(String endpoint, File file, String fieldName,
      {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$_baseUrl/${endpoint.replaceAll(RegExp(r'^/+'), '')}');
      print('THttpHelper: UPLOAD request to $url, file: ${file.path}, headers: $headers');
      var request = http.MultipartRequest('POST', url);
      if (headers != null) request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      print('THttpHelper: UPLOAD error: $e');
      throw TExceptions('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> postMultipart(String endpoint, Map<String, dynamic> data,
      {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$_baseUrl/${endpoint.replaceAll(RegExp(r'^/+'), '')}');
      print('THttpHelper: POST MULTIPART request to $url, data: $data, headers: $headers');
      var request = http.MultipartRequest('POST', url);
      if (headers != null) request.headers.addAll(headers);

      for (var entry in data.entries) {
        if (entry.value is MultipartFile) {
          final value = entry.value as MultipartFile;
          if (kIsWeb) {
            request.files.add(http.MultipartFile.fromBytes(
              entry.key,
              value.data as Uint8List,
              filename: value.filename,
              contentType: value.contentType != null ? MediaType.parse(value.contentType!) : null,
            ));
          } else {
            request.files.add(await http.MultipartFile.fromPath(
              entry.key,
              (value.data as File).path,
              contentType: value.contentType != null ? MediaType.parse(value.contentType!) : null,
            ));
          }
        } else {
          request.fields[entry.key] = entry.value.toString();
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      print('THttpHelper: POST MULTIPART error: $e');
      throw TExceptions('Network error: $e');
    }
  }

  static Future<void> fetchCsrfToken() async {
    try {
      final url = Uri.parse('$_baseUrl/../sanctum/csrf-cookie');
      print('THttpHelper: Fetching CSRF token from $url');
      await http.get(url);
    } catch (e) {
      print('THttpHelper: CSRF token fetch error: $e');
      throw TExceptions('Failed to fetch CSRF token: $e');
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      print('THttpHelper: Response status: ${response.statusCode}, body: $body');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (body is Map<String, dynamic>) {
          return body;
        } else if (body is List<dynamic>) {
          return {'data': body};
        } else {
          return {'success': true, 'data': body};
        }
      } else {
        String errorMessage = body['message']?.toString() ?? 'Request failed with status: ${response.statusCode}';
        if (response.statusCode == 422 && body['errors'] != null) {
          final errors = body['errors'] as Map<String, dynamic>;
          errorMessage += ' - ${errors.values.expand((e) => e as List).join(", ")}';
        }
        print('THttpHelper: Request failed with status: ${response.statusCode}, message: $errorMessage');
        throw TExceptions.fromStatusCode(response.statusCode, errorMessage: errorMessage);
      }
    } catch (e) {
      print('THttpHelper: JSON parsing error: $e');
      throw TExceptions('Failed to parse response: ${response.body}');
    }
  }
}