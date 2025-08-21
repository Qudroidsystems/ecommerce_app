import 'package:cwt_ecommerce_app/utils/constants/enums.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/product/product_repository.dart';
import '../../../../utils/exceptions/exceptions.dart';
import '../../../../utils/popups/loaders.dart';
import '../../models/product_model.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  final isLoading = false.obs;
  final productRepository = Get.put(ProductRepository());
  RxList<ProductModel> featuredProducts = <ProductModel>[].obs;

  @override
  void onInit() {
    fetchFeaturedProducts();
    super.onInit();
  }

  Future<void> fetchFeaturedProducts() async {
    try {
      isLoading.value = true;
      final products = await productRepository.getFeaturedProducts();
      print('ProductController: Fetched ${products.length} featured products: ${products.map((p) => p.toJson()).toList()}');
      featuredProducts.assignAll(products);
      if (products.isEmpty) {
        print('ProductController: No featured products found');
        TLoaders.warningSnackBar(title: 'Warning', message: 'No featured products available');
      }
    } catch (e, stackTrace) {
      print('ProductController: Error fetching featured products: $e\nStackTrace: $stackTrace');
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: 'Failed to load products: $e');
      featuredProducts.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String getProductPrice(ProductModel product) {
    double smallestPrice = double.infinity;
    double largestPrice = 0.0;

    if (product.productType == ProductType.single.toString() || (product.productVariations?.isEmpty ?? true)) {
      return (product.salePrice > 0.0 ? product.salePrice : product.price).toStringAsFixed(2);
    } else {
      for (var variation in product.productVariations!) {
        double priceToConsider = variation.salePrice > 0.0 ? variation.salePrice : variation.price;
        if (priceToConsider < smallestPrice) {
          smallestPrice = priceToConsider;
        }
        if (priceToConsider > largestPrice) {
          largestPrice = priceToConsider;
        }
      }
      if (smallestPrice == largestPrice) {
        return smallestPrice.toStringAsFixed(2);
      } else {
        return '${smallestPrice.toStringAsFixed(2)} - \₦ ${largestPrice.toStringAsFixed(2)}';
      }
    }
  }

  String? calculateSalePercentage(double originalPrice, double? salePrice) {
    if (salePrice == null || salePrice <= 0.0 || originalPrice <= 0.0) return null;
    double percentage = ((originalPrice - salePrice) / originalPrice) * 100;
    return '${percentage.toStringAsFixed(0)}%';
  }

  String getProductStockStatus(ProductModel product) {
    if (product.productType == ProductType.single.toString()) {
      return product.stock > 0 ? 'In Stock' : 'Out of Stock';
    } else {
      final stock = product.productVariations?.fold<int>(0, (sum, element) => sum + element.stock) ?? 0;
      return stock > 0 ? 'In Stock' : 'Out of Stock';
    }
  }

  Future<void> updateProductStock(String productId, int quantitySold, String variationId) async {
    try {
      final product = await productRepository.getSingleProduct(productId);
      print('ProductController: Fetched product for stock update: ${product.toJson()}');
      if (variationId.isEmpty) {
        product.stock = (product.stock - quantitySold).clamp(0, product.stock);
        product.soldQuantity += quantitySold;
        await productRepository.updateProduct(product);
        print('ProductController: Updated simple product stock: ${product.stock}, sold: ${product.soldQuantity}');
      } else {
        final variation = product.productVariations?.firstWhere(
              (v) => v.id == variationId,
          orElse: () => throw TExceptions('Variation not found', null),
        );
        if (variation != null) {
          variation.stock = (variation.stock - quantitySold).clamp(0, variation.stock);
          variation.soldQuantity = (variation.soldQuantity ?? 0) + quantitySold;
          await productRepository.updateProduct(product);
          print('ProductController: Updated variation stock: ${variation.stock}, sold: ${variation.soldQuantity}');
        }
      }
    } catch (e, stackTrace) {
      print('ProductController: Error updating product stock: $e\nStackTrace: $stackTrace');
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: 'Failed to update stock: $e');
    }
  }
}