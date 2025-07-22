import 'dart:io';
import 'package:cwt_ecommerce_app/data/repositories/brands/brand_repository.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/product_model.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/exceptions/exceptions.dart';
import '../../../utils/http/http_client.dart'; // Import your THttpHelper


/// Repository for managing product-related data and operations using a Laravel API.
class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();

  /* ---------------------------- FUNCTIONS ---------------------------------*/

  /// Get limited featured products.
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final response = await THttpHelper.get('/products?featured=true&limit=4');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw TExceptions('Failed to fetch featured products: $e');
    }
  }

  /// Get a single product by ID.
  Future<ProductModel> getSingleProduct(String productId) async {
    try {
      final response = await THttpHelper.get('/products/$productId');
      return ProductModel.fromJson(response['data']);
    } catch (e) {
      throw TExceptions('Failed to fetch product: $e');
    }
  }

  /// Get all featured products.
  Future<List<ProductModel>> getAllFeaturedProducts() async {
    try {
      final response = await THttpHelper.get('/products?featured=true');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw TExceptions('Failed to fetch all featured products: $e');
    }
  }

  /// Fetch products by query (replaced with API filtering).
  Future<List<ProductModel>> fetchProductsByQuery(dynamic query) async {
    try {
      // Since query was for Firestore, we'll assume it's a Map for API params
      String endpoint = '/products';
      if (query is Map<String, dynamic>) {
        final queryParams = query.entries.map((e) => '${e.key}=${e.value}').join('&');
        endpoint += '?$queryParams';
      }
      final response = await THttpHelper.get(endpoint);
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw TExceptions('Failed to fetch products by query: $e');
    }
  }

  /// Get favorite products based on a list of product IDs.
  Future<List<ProductModel>> getFavouriteProducts(List<String> productIds) async {
    try {
      final response = await THttpHelper.get('/products?ids=${productIds.join(',')}');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw TExceptions('Failed to fetch favorite products: $e');
    }
  }

  /// Fetches products for a specific category.
  Future<List<ProductModel>> getProductsForCategory({required String categoryId, int limit = 4}) async {
    try {
      final endpoint = limit == -1
          ? '/products?category_id=$categoryId'
          : '/products?category_id=$categoryId&limit=$limit';
      final response = await THttpHelper.get(endpoint);
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw TExceptions('Failed to fetch products for category: $e');
    }
  }

  /// Fetches products for a specific brand.
  Future<List<ProductModel>> getProductsForBrand(String brandId, int limit) async {
    try {
      final endpoint = limit == -1
          ? '/products?brand_id=$brandId'
          : '/products?brand_id=$brandId&limit=$limit';
      final response = await THttpHelper.get(endpoint);
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw TExceptions('Failed to fetch products for brand: $e');
    }
  }

  /// Search products with optional filters.
  Future<List<ProductModel>> searchProducts(
      String query, {
        String? categoryId,
        String? brandId,
        double? minPrice,
        double? maxPrice,
      }) async {
    try {
      String endpoint = '/products?search=$query';
      if (categoryId != null) endpoint += '&category_id=$categoryId';
      if (brandId != null) endpoint += '&brand_id=$brandId';
      if (minPrice != null) endpoint += '&min_price=$minPrice';
      if (maxPrice != null) endpoint += '&max_price=$maxPrice';

      final response = await THttpHelper.get(endpoint);
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw TExceptions('Failed to search products: $e');
    }
  }

  /// Update a single field in a product.
  Future<void> updateSingleField(String docId, Map<String, dynamic> json) async {
    try {
      await THttpHelper.patch('/products/$docId', json);
    } catch (e) {
      throw TExceptions('Failed to update product field: $e');
    }
  }

  /// Update an entire product.
  Future<void> updateProduct(ProductModel product) async {
    try {
      await THttpHelper.put('/products/${product.id}', product.toJson());
    } catch (e) {
      throw TExceptions('Failed to update product: $e');
    }
  }

  /// Upload dummy data to the API (simplified without Firebase Storage).
  Future<void> uploadDummyData(List<ProductModel> products) async {
    try {
      final brandRepository = Get.put(BrandRepository());

      for (var product in products) {
        // Fetch brand data from API (assuming BrandRepository is also refactored)
        final brand = await brandRepository.getSingleBrand(product.brand!.id);
        if (brand == null || brand.image.isEmpty) {
          throw 'No Brands found. Please upload brands first.';
        }
        product.brand!.image = brand.image;

        // For simplicity, assume images are already hosted or uploaded separately
        // If you need to upload images, use THttpHelper.uploadFile
        if (product.images != null && product.images!.isNotEmpty) {
          List<String> uploadedImages = [];
          for (var image in product.images!) {
            if (File(image).existsSync()) { // Check if it's a local file
              final response = await THttpHelper.uploadFile('/upload', File(image), 'image');
              uploadedImages.add(response['url']);
            } else {
              uploadedImages.add(image); // Assume it's already a URL
            }
          }
          product.images = uploadedImages;
        }

        if (product.productType == ProductType.variable.toString()) {
          for (var variation in product.productVariations!) {
            if (File(variation.image).existsSync()) {
              final response = await THttpHelper.uploadFile('/upload', File(variation.image), 'image');
              variation.image = response['url'];
            }
          }
        }

        // Store product in API
        await THttpHelper.post('/products', product.toJson());
      }
    } catch (e) {
      throw TExceptions('Failed to upload dummy data: $e');
    }
  }
}