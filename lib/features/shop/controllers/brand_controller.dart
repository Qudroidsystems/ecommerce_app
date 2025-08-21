import 'package:get/get.dart';
import '../../../data/repositories/product/product_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../models/brand_model.dart';
import '../models/product_model.dart';
import '../../../data/repositories/brands/brand_repository.dart';

class BrandController extends GetxController {
  static BrandController get instance => Get.find();

  RxBool isLoading = true.obs;
  RxList<BrandModel> allBrands = <BrandModel>[].obs;
  RxList<BrandModel> featuredBrands = <BrandModel>[].obs;
  final brandRepository = Get.put(BrandRepository());

  @override
  void onInit() {
    getFeaturedBrands();
    super.onInit();
  }

  /// -- Load Featured Brands
  Future<void> getFeaturedBrands() async {
    try {
      isLoading.value = true;
      // Fetch featured brands directly
      final fetchedBrands = await brandRepository.getFeaturedBrands();
      print('Fetched Featured Brands: ${fetchedBrands.map((b) => b.toJson()).toList()}');
      allBrands.assignAll(fetchedBrands);
      featuredBrands.assignAll(fetchedBrands.take(4).toList());
      print('Featured Brands: ${featuredBrands.map((b) => b.toJson()).toList()}');
    } catch (e) {
      print('Error in getFeaturedBrands: $e');
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
      print('isLoading: ${isLoading.value}');
    }
  }

  /// -- Get Brands For Category
  Future<List<BrandModel>> getBrandsForCategory(String categoryId) async {
    final brands = await brandRepository.getBrandsForCategory(categoryId);
    return brands;
  }

  /// Get Brand Specific Products
  Future<List<ProductModel>> getBrandProducts(String brandId, int limit) async {
    final products = await ProductRepository.instance.getProductsForBrand(brandId, limit);
    return products;
  }
}