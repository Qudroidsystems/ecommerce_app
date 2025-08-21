import 'package:get/get.dart';
import '../../../data/repositories/categories/category_repository.dart';
import '../../../data/repositories/product/product_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();

  RxBool isLoading = true.obs;
  RxList<CategoryModel> allCategories = <CategoryModel>[].obs;
  RxList<CategoryModel> featuredCategories = <CategoryModel>[].obs;

  final _categoryRepository = Get.put(CategoryRepository());
  final _productRepository = Get.put(ProductRepository());

  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;

      // Fetch categories from repository
      final fetchedCategories = await _categoryRepository.getAllCategories();
      print('Fetched Categories: ${fetchedCategories.map((c) => c.toJson())}');

      // Update state
      allCategories.assignAll(fetchedCategories);
      featuredCategories.assignAll(
        allCategories
            .where((category) => category.isFeatured)
            .take(8)
            .toList(),
      );
      print('Featured Categories: ${featuredCategories.map((c) => c.toJson())}');
      if (featuredCategories.isEmpty) {
        TLoaders.warningSnackBar(title: 'Warning', message: 'No featured categories found');
      }
    } catch (e) {
      print('Error in fetchCategories: $e');
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: 'Failed to load categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<CategoryModel>> getSubCategories(String categoryId) async {
    try {
      return await _categoryRepository.getSubCategories(categoryId);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  Future<List<ProductModel>> getCategoryProducts({required String categoryId, int limit = 4}) async {
    try {
      return await _productRepository.getProductsForCategory(categoryId: categoryId, limit: limit);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }
}