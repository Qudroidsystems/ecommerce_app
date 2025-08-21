import 'package:cwt_ecommerce_app/data/repositories/product/product_repository.dart';
import 'package:get/get.dart';
import '../../../utils/popups/loaders.dart';
import '../models/product_model.dart';
import '../../../utils/http/http_client.dart'; // Your THttpHelper import

class AllProductsController extends GetxController {
  static AllProductsController get instance => Get.find();

  // Observable variables
  RxList<ProductModel> products = <ProductModel>[].obs;
  RxString selectedSortOption = 'Name'.obs;

  // Fetch all products from the Laravel API
  Future<List<ProductModel>> fetchAllProducts() async {
    try {
      final response = await THttpHelper.get('api/products');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  // Assign products to the observable list
  void assignProducts(List<ProductModel> products) {
    this.products.assignAll(products);
    sortProducts(selectedSortOption.value); // Apply initial sorting
  }

  // Sort products based on the selected option
  void sortProducts(String sortOption) {
    selectedSortOption.value = sortOption;
    switch (sortOption) {
      case 'Name':
        products.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Higher Price':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Lower Price':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Sale':
        products.sort((a, b) => (b.salePrice ?? b.price).compareTo(a.salePrice ?? a.price));
        break;
      case 'Newest':
      // Uncomment and adjust if date field is available
      // products.sort((a, b) => b.date!.compareTo(a.date!));
        break;
      case 'Popularity':
        products.sort((a, b) => b.soldQuantity.compareTo(a.soldQuantity));
        break;
    }
    products.refresh(); // Notify UI of changes
  }
}