import 'dart:io';
import 'package:get/get.dart';
import 'package:cwt_ecommerce_app/features/shop/models/category_model.dart'; // Adjust path
import 'package:cwt_ecommerce_app/features/shop/models/product_category_model.dart'; // Adjust path
import 'package:cwt_ecommerce_app/utils/http/http_client.dart'; // Adjust path
import 'package:cwt_ecommerce_app/utils/exceptions/exceptions.dart'; // Adjust path for TExceptions

class CategoryRepository extends GetxController {
  static CategoryRepository get instance => Get.find();

  /// Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await THttpHelper.get('/categories');

      if (response == null || response['data'] == null) {
        throw const FormatException('Unexpected API response');
      }

      final List<dynamic> data = response['data'];
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e, 'fetching all categories');
    }
  }


  /// Get subcategories by categoryId
  Future<List<CategoryModel>> getSubCategories(String categoryId) async {
    try {
      final response = await THttpHelper.get('/categories?parent_id=$categoryId');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e, 'fetching subcategories for category ID: $categoryId');
    }
  }

  /// Upload category dummy data to the Laravel API
  Future<void> uploadDummyData(List<CategoryModel> categories) async {
    try {
      for (var category in categories) {
        String imageUrl = category.image;

        if (category.image.isNotEmpty && File(category.image).existsSync()) {
          final uploadResponse = await THttpHelper.uploadFile('api/upload', File(category.image), 'image');
          imageUrl = uploadResponse['url'] ?? category.image;
        }

        // Create a new instance to avoid modifying the original object
        final updatedCategory = CategoryModel(
          id: category.id,
          name: category.name,
          image: imageUrl,
          isFeatured: category.isFeatured,
          parentId: category.parentId,
        );

        await THttpHelper.post('/categories', updatedCategory.toJson());
      }
    } catch (e) {
      throw _handleError(e, 'uploading dummy category data');
    }
  }


  /// Upload product category dummy data to the Laravel API
  Future<void> uploadProductCategoryDummyData(List<ProductCategoryModel> productCategories) async {
    try {
      for (var entry in productCategories) {
        await THttpHelper.post('api/product-categories', entry.toJson());
      }
    } catch (e) {
      throw _handleError(e, 'uploading dummy product-category data');
    }
  }

  /// Error handling method
  TExceptions _handleError(dynamic e, String operation) {
    if (e is SocketException) {
      return TExceptions('No Internet connection while $operation. Please try again.');
    } else if (e is HttpException) {
      return TExceptions('Server error while $operation: ${e.message}');
    } else {
      return TExceptions('Something went wrong while $operation: $e');
    }
  }
}