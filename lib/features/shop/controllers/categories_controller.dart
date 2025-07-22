import 'package:get/get.dart';
import '../../../data/repositories/categories/category_repository.dart';
import '../../../data/repositories/product/product_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();

  /// Observables
  RxBool isLoading = true.obs;
  RxList<CategoryModel> allCategories = <CategoryModel>[].obs;
  RxList<CategoryModel> featuredCategories = <CategoryModel>[].obs;

  /// Dependencies
  final _categoryRepository = Get.put(CategoryRepository());
  final  _productRepository = Get.put(ProductRepository());



  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  /// Fetch all categories
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;

      // Fetch categories from repository
      final fetchedCategories = await _categoryRepository.getAllCategories();

      // Update state
      allCategories.assignAll(fetchedCategories);
      featuredCategories.assignAll(
        allCategories
            .where((category) => category.isFeatured && category.parentId.isEmpty)
            .take(8)
            .toList(),
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch subcategories by category ID
  Future<List<CategoryModel>> getSubCategories(String categoryId) async {
    try {
      return await _categoryRepository.getSubCategories(categoryId);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  /// Fetch products by category ID
  Future<List<ProductModel>> getCategoryProducts({required String categoryId, int limit = 4}) async {
    try {
      return await _productRepository.getProductsForCategory(categoryId: categoryId, limit: limit);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }
}
