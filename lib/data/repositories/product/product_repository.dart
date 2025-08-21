import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../features/shop/models/product_model.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/exceptions/exceptions.dart';
import '../../../utils/http/http_client.dart';
import '../../repositories/brands/brand_repository.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();

  Future<List<ProductModel>> parseProductsInIsolate(List<dynamic> data) async {
    try {
      return await compute((input) {
        return input
            .where((json) => json != null && json is Map<String, dynamic>)
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }, data);
    } catch (e, stackTrace) {
      print('ProductRepository: Error parsing products in isolate: $e\nStackTrace: $stackTrace');
      return [];
    }
  }

  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final response = await THttpHelper.get('/products?featured=true&limit=20');
      print('ProductRepository: Raw API Response for getFeaturedProducts: $response');
      if (response['success'] != true) {
        print('ProductRepository: API returned success: false');
        throw TExceptions('API returned success: false', null);
      }

      final List<dynamic>? data = response['data'];
      if (data == null || data.isEmpty) {
        print('ProductRepository: No data found in response');
        return <ProductModel>[];
      }

      print('ProductRepository: Parsed data for getFeaturedProducts: $data');
      return await parseProductsInIsolate(data);
    } catch (e, stackTrace) {
      print('ProductRepository: Error in getFeaturedProducts: $e\nStackTrace: $stackTrace');
      throw TExceptions('Failed to fetch featured products: $e', null);
    }
  }

  Future<ProductModel> getSingleProduct(String productId) async {
    try {
      final response = await THttpHelper.get('/products/$productId');
      print('ProductRepository: Raw API Response for getSingleProduct: $response');
      if (response['success'] != true) {
        throw TExceptions('API returned success: false', null);
      }

      final data = response['data'];
      if (data == null || data is! Map<String, dynamic>) {
        throw TExceptions('Invalid product data format', null);
      }

      return ProductModel.fromJson(data);
    } catch (e, stackTrace) {
      print('ProductRepository: Error in getSingleProduct: $e\nStackTrace: $stackTrace');
      throw TExceptions('Failed to fetch product: $e', null);
    }
  }

  Future<List<ProductModel>> getAllFeaturedProducts() async {
    try {
      final response = await THttpHelper.get('/products?featured=true');
      print('ProductRepository: Raw API Response for getAllFeaturedProducts: $response');
      if (response['success'] != true) {
        throw TExceptions('API returned success: false', null);
      }

      final List<dynamic>? data = response['data'];
      if (data == null || data.isEmpty) {
        print('ProductRepository: No data found in response');
        return <ProductModel>[];
      }

      print('ProductRepository: Parsed data for getAllFeaturedProducts: $data');
      return await parseProductsInIsolate(data);
    } catch (e, stackTrace) {
      print('ProductRepository: Error in getAllFeaturedProducts: $e\nStackTrace: $stackTrace');
      throw TExceptions('Failed to fetch all featured products: $e', null);
    }
  }

  Future<List<ProductModel>> fetchProductsByQuery(dynamic query) async {
    try {
      String endpoint = '/products';
      if (query is Map<String, dynamic>) {
        final queryParams = query.entries.map((e) => '${e.key}=${e.value}').join('&');
        endpoint += '?$queryParams';
      }
      final response = await THttpHelper.get(endpoint);
      print('ProductRepository: Raw API Response for fetchProductsByQuery: $response');
      if (response['success'] != true) {
        throw TExceptions('API returned success: false', null);
      }

      final List<dynamic>? data = response['data'];
      if (data == null || data.isEmpty) {
        print('ProductRepository: No data found in response');
        return <ProductModel>[];
      }

      print('ProductRepository: Parsed data for fetchProductsByQuery: $data');
      return await parseProductsInIsolate(data);
    } catch (e, stackTrace) {
      print('ProductRepository: Error in fetchProductsByQuery: $e\nStackTrace: $stackTrace');
      throw TExceptions('Failed to fetch products by query: $e', null);
    }
  }

  Future<List<ProductModel>> getFavouriteProducts(List<String> productIds) async {
    try {
      final response = await THttpHelper.get('/products?ids=${productIds.join(',')}');
      print('ProductRepository: Raw API Response for getFavouriteProducts: $response');
      if (response['success'] != true) {
        throw TExceptions('API returned success: false', null);
      }

      final List<dynamic>? data = response['data'];
      if (data == null || data.isEmpty) {
        print('ProductRepository: No data found in response');
        return <ProductModel>[];
      }

      print('ProductRepository: Parsed data for getFavouriteProducts: $data');
      return await parseProductsInIsolate(data);
    } catch (e, stackTrace) {
      print('ProductRepository: Error in getFavouriteProducts: $e\nStackTrace: $stackTrace');
      throw TExceptions('Failed to fetch favorite products: $e', null);
    }
  }

  Future<List<ProductModel>> getProductsForCategory({required String categoryId, int limit = 20}) async {
    try {
      final endpoint = limit == -1
          ? '/products?category_id=$categoryId'
          : '/products?category_id=$categoryId&limit=$limit';
      final response = await THttpHelper.get(endpoint);
      print('ProductRepository: Raw API Response for getProductsForCategory: $response');
      if (response['success'] != true) {
        throw TExceptions('API returned success: false', null);
      }

      final List<dynamic>? data = response['data'];
      if (data == null || data.isEmpty) {
        print('ProductRepository: No data found in response');
        return <ProductModel>[];
      }

      print('ProductRepository: Parsed data for getProductsForCategory: $data');
      return await parseProductsInIsolate(data);
    } catch (e, stackTrace) {
      print('ProductRepository: Error in getProductsForCategory: $e\nStackTrace: $stackTrace');
      throw TExceptions('Failed to fetch products for category: $e', null);
    }
  }

  Future<List<ProductModel>> getProductsForBrand(String brandId, int limit) async {
    try {
      final endpoint = limit == -1
          ? '/products?brand_id=$brandId'
          : '/products?brand_id=$brandId&limit=$limit';
      final response = await THttpHelper.get(endpoint);
      print('ProductRepository: Raw API Response for getProductsForBrand: $response');
      if (response['success'] != true) {
        throw TExceptions('API returned success: false', null);
      }

      final List<dynamic>? data = response['data'];
      if (data == null || data.isEmpty) {
        print('ProductRepository: No data found in response');
        return <ProductModel>[];
      }

      print('ProductRepository: Parsed data for getProductsForBrand: $data');
      return await parseProductsInIsolate(data);
    } catch (e, stackTrace) {
      print('ProductRepository: Error in getProductsForBrand: $e\nStackTrace: $stackTrace');
      throw TExceptions('Failed to fetch products for brand: $e', null);
    }
  }

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
      print('ProductRepository: Raw API Response for searchProducts: $response');
      if (response['success'] != true) {
        throw TExceptions('API returned success: false', null);
      }

      final List<dynamic>? data = response['data'];
      if (data == null || data.isEmpty) {
        print('ProductRepository: No data found in response');
        return <ProductModel>[];
      }

      print('ProductRepository: Parsed data for searchProducts: $data');
      return await parseProductsInIsolate(data);
    } catch (e, stackTrace) {
      print('ProductRepository: Error in searchProducts: $e\nStackTrace: $stackTrace');
      throw TExceptions('Failed to search products: $e', null);
    }
  }

  Future<void> updateSingleField(String docId, Map<String, dynamic> json) async {
    try {
      await THttpHelper.patch('/products/$docId', json);
      print('ProductRepository: Updated single field for product $docId');
    } catch (e, stackTrace) {
      print('ProductRepository: Error in updateSingleField: $e\nStackTrace: $stackTrace');
      throw TExceptions('Failed to update product field: $e', null);
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await THttpHelper.put('/products/${product.id}', product.toJson());
      print('ProductRepository: Updated product ${product.id}');
    } catch (e, stackTrace) {
      print('ProductRepository: Error in updateProduct: $e\nStackTrace: $stackTrace');
      throw TExceptions('Failed to update product: $e', null);
    }
  }

  Future<void> uploadDummyData(List<ProductModel> products) async {
    try {
      final brandRepository = Get.put(BrandRepository());
      for (var product in products) {
        if (product.brand != null) {
          final brand = await brandRepository.getSingleBrand(product.brand!.id);
          if (brand == null || brand.image.isEmpty) {
            throw TExceptions('No Brands found. Please upload brands first.', null);
          }
          product.brand = brand;
        }

        if (product.images != null && product.images!.isNotEmpty) {
          List<String> uploadedImages = [];
          for (var image in product.images!) {
            if (File(image).existsSync()) {
              final response = await THttpHelper.uploadFile('/upload', File(image), 'image');
              uploadedImages.add(response['url']);
            } else {
              uploadedImages.add(image);
            }
          }
          product.images = uploadedImages;
        }

        if (product.productType == ProductType.variable.toString() && product.productVariations != null) {
          for (var variation in product.productVariations!) {
            if (File(variation.image).existsSync()) {
              final response = await THttpHelper.uploadFile('/upload', File(variation.image), 'image');
              variation.image = response['url'];
            }
          }
        }

        await THttpHelper.post('/products', product.toJson());
        print('ProductRepository: Uploaded product ${product.id}');
      }
    } catch (e, stackTrace) {
      print('ProductRepository: Error in uploadDummyData: $e\nStackTrace: $stackTrace');
      throw TExceptions('Failed to upload dummy data: $e', null);
    }
  }
}