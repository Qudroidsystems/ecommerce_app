import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../features/shop/models/brand_category_model.dart';
import '../../../features/shop/models/brand_model.dart';
import '../../../utils/http/http_client.dart';

class BrandRepository extends GetxController {
  static BrandRepository get instance => Get.find();

  /// Get all brands
  Future<List<BrandModel>> getAllBrands() async {
    try {
      final response = await THttpHelper.get('/brands');
      print('Raw API Response (getAllBrands): $response');
      if (response is Map && response['success'] == true) {
        return (response['data'] as List).map((e) => BrandModel.fromJson(e)).toList();
      } else {
        throw 'Invalid API response format';
      }
    } catch (e) {
      print('Error in getAllBrands: $e');
      throw _handleError(e);
    }
  }

  /// Get single brand by ID
  Future<BrandModel?> getSingleBrand(String id) async {
    try {
      final response = await THttpHelper.get('/brands/$id');
      print('Raw API Response (getSingleBrand): $response');
      return BrandModel.fromJson(response);
    } catch (e) {
      print('Error in getSingleBrand: $e');
      throw _handleError(e);
    }
  }

  /// Get featured brands
  Future<List<BrandModel>> getFeaturedBrands() async {
    try {
      final response = await THttpHelper.get('/brands?isFeatured=true&limit=20');
      print('Raw API Response (getFeaturedBrands): $response');
      if (response is Map && response['success'] == true) {
        return (response['data'] as List).map((e) => BrandModel.fromJson(e)).toList();
      } else {
        throw 'Invalid API response format';
      }
    } catch (e) {
      print('Error in getFeaturedBrands: $e');
      throw _handleError(e);
    }
  }

  /// Get brands for a specific category
  Future<List<BrandModel>> getBrandsForCategory(String categoryId) async {
    try {
      final response = await THttpHelper.get('/brands/category/$categoryId');
      print('Raw API Response (getBrandsForCategory): $response');
      if (response is Map && response['success'] == true) {
        return (response['data'] as List).map((e) => BrandModel.fromJson(e)).toList();
      } else {
        throw 'Invalid API response format';
      }
    } catch (e) {
      print('Error in getBrandsForCategory: $e');
      throw _handleError(e);
    }
  }

  /// Upload dummy brands data
  Future<void> uploadDummyData(List<BrandModel> brands) async {
    try {
      for (var brand in brands) {
        await THttpHelper.post('/brands', brand.toJson());
      }
    } catch (e) {
      print('Error in uploadDummyData: $e');
      throw _handleError(e);
    }
  }

  /// Upload dummy brand-category data
  Future<void> uploadBrandCategoryDummyData(List<BrandCategoryModel> brandCategory) async {
    try {
      for (var entry in brandCategory) {
        await THttpHelper.post('/brand-categories', entry.toJson());
      }
    } catch (e) {
      print('Error in uploadBrandCategoryDummyData: $e');
      throw _handleError(e);
    }
  }

  /// Error handling method
  String _handleError(dynamic e) {
    if (e is SocketException) {
      return 'No Internet connection. Please try again.';
    } else if (e is PlatformException) {
      return e.message ?? 'Platform error occurred.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}