import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../exceptions/exceptions.dart';

class THttpHelper {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static final _storage = GetStorage();

  static Future<void> fetchCsrfToken() async {
    try {
      final url = Uri.parse('$baseUrl/sanctum/csrf-cookie');
      print('THttpHelper: Fetching CSRF token from $url');
      final response = await http.get(url);
      print('THttpHelper: CSRF response status: ${response.statusCode}, body: ${response.body}');
      if (response.statusCode != 204) {
        if (response.body.contains('<!DOCTYPE html>')) {
          throw TExceptions('Invalid CSRF response: Server returned HTML (likely 404 or 500)', response.statusCode);
        }
        final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        final message = body['message'] ?? 'Failed to fetch CSRF token: ${response.statusCode}';
        throw TExceptions.fromLaravelResponse(body, response.statusCode);
      }
      print('THttpHelper: CSRF token fetched successfully');
    } catch (e) {
      print('THttpHelper: CSRF fetch error: $e');
      throw TExceptions('Network error: $e', null);
    }
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = _storage.read('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> get(String endpoint, {bool skipCsrf = false}) async {
    try {
      if (!skipCsrf) await fetchCsrfToken();
      final headers = await getHeaders();
      final url = Uri.parse('$baseUrl/${endpoint.replaceAll(RegExp(r'^/+'), '')}');
      print('THttpHelper: GET request to $url, headers: $headers');
      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      print('THttpHelper: GET error: $e');
      throw TExceptions('Network error: $e', null);
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, dynamic data, {bool skipCsrf = false}) async {
    try {
      if (!skipCsrf) await fetchCsrfToken();
      final headers = await getHeaders();
      final url = Uri.parse('$baseUrl/${endpoint.replaceAll(RegExp(r'^/+'), '')}');
      print('THttpHelper: POST request to $url, data: $data, headers: $headers');
      final response = await http.post(url, headers: headers, body: jsonEncode(data));
      return _handleResponse(response);
    } catch (e) {
      print('THttpHelper: POST error: $e');
      throw TExceptions('Network error: $e', null);
    }
  }

  static Future<Map<String, dynamic>> put(String endpoint, dynamic data) async {
    try {
      await fetchCsrfToken();
      final headers = await getHeaders();
      final url = Uri.parse('$baseUrl/${endpoint.replaceAll(RegExp(r'^/+'), '')}');
      print('THttpHelper: PUT request to $url, data: $data, headers: $headers');
      final response = await http.put(url, headers: headers, body: jsonEncode(data));
      return _handleResponse(response);
    } catch (e) {
      print('THttpHelper: PUT error: $e');
      throw TExceptions('Network error: $e', null);
    }
  }

  static Future<Map<String, dynamic>> patch(String endpoint, dynamic data) async {
    try {
      await fetchCsrfToken();
      final headers = await getHeaders();
      final url = Uri.parse('$baseUrl/${endpoint.replaceAll(RegExp(r'^/+'), '')}');
      print('THttpHelper: PATCH request to $url, data: $data, headers: $headers');
      final response = await http.patch(url, headers: headers, body: jsonEncode(data));
      return _handleResponse(response);
    } catch (e) {
      print('THttpHelper: PATCH error: $e');
      throw TExceptions('Network error: $e', null);
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      await fetchCsrfToken();
      final headers = await getHeaders();
      final url = Uri.parse('$baseUrl/${endpoint.replaceAll(RegExp(r'^/+'), '')}');
      print('THttpHelper: DELETE request to $url, headers: $headers');
      final response = await http.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      print('THttpHelper: DELETE error: $e');
      throw TExceptions('Network error: $e', null);
    }
  }

  static Future<Map<String, dynamic>> uploadFile(String endpoint, File file, String fieldName) async {
    try {
      await fetchCsrfToken();
      final headers = await getHeaders();
      final url = Uri.parse('$baseUrl/${endpoint.replaceAll(RegExp(r'^/+'), '')}');
      print('THttpHelper: UPLOAD request to $url, file: ${file.path}, headers: $headers');
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      print('THttpHelper: UPLOAD error: $e');
      throw TExceptions('Network error: $e', null);
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      print('THttpHelper: Response status: ${response.statusCode}, body: ${response.body}');
      if (response.body.contains('<!DOCTYPE html>')) {
        throw TExceptions('Invalid response: Server returned HTML instead of JSON', response.statusCode);
      }
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (body is Map<String, dynamic>) {
          return body;
        } else if (body is List<dynamic>) {
          return {'data': body};
        } else {
          return {'success': true, 'data': body};
        }
      } else if (response.statusCode == 401) {
        throw TExceptions('Unauthorized: Invalid or expired token', response.statusCode);
      } else {
        throw TExceptions.fromLaravelResponse(body, response.statusCode);
      }
    } catch (e) {
      print('THttpHelper: Response handling error: $e');
      throw TExceptions('Failed to parse response: ${response.body}', response.statusCode);
    }
  }
}