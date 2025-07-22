import 'package:get/get.dart';
import '../../../../utils/local_storage/storage_utility.dart';
import '../../../../utils/popups/loaders.dart';
import '../../models/cart_item_model.dart';
import '../../models/product_model.dart';
import 'variation_controller.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();

  RxInt noOfCartItems = 0.obs;
  RxDouble totalCartPrice = 0.0.obs;
  RxInt productQuantityInCart = 0.obs;
  RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final variationController = VariationController.instance;
  final storage = TLocalStorage.instance(); // Use singleton directly

  @override
  void onInit() {
    super.onInit();
    print('CartController: onInit called');
    // Delay loading to ensure TLocalStorage is initialized
    Future.delayed(Duration.zero, loadCartItems);
  }

  /// Converts a ProductModel to a CartItemModel
  CartItemModel convertToCartItem(ProductModel product, int quantity) {
    if (product.productType == "single") {
      variationController.resetSelectedAttributes();
    }
    final variation = variationController.selectedVariation.value;
    final isVariation = variation.id.isNotEmpty;
    final price = isVariation
        ? (variation.salePrice > 0.0 ? variation.salePrice : variation.price)
        : (product.salePrice > 0.0 ? product.salePrice : product.price);

    return CartItemModel(
      productId: product.id,
      title: product.title,
      price: price,
      quantity: quantity,
      variationId: variation.id,
      image: isVariation ? variation.image : product.thumbnail,
      brandName: product.brand?.name ?? '',
      selectedVariation: isVariation ? variation.attributeValues : null,
    );
  }

  void addToCart(ProductModel product) {
    if (productQuantityInCart.value < 1) {
      TLoaders.customToast(message: 'Select Quantity');
      return;
    }

    if (product.productType == "variable" &&
        variationController.selectedVariation.value.id.isEmpty) {
      TLoaders.customToast(message: 'Select Variation');
      return;
    }

    if (product.productType == "variable" &&
        variationController.selectedVariation.value.stock < 1) {
      TLoaders.warningSnackBar(
          message: 'Selected variation is out of stock.', title: 'Oh Snap!');
      return;
    } else if (product.stock < 1) {
      TLoaders.warningSnackBar(
          message: 'Selected Product is out of stock.', title: 'Oh Snap!');
      return;
    }

    final selectedCartItem = convertToCartItem(product, productQuantityInCart.value);

    int index = cartItems.indexWhere((cartItem) =>
    cartItem.productId == selectedCartItem.productId &&
        cartItem.variationId == selectedCartItem.variationId);

    if (index >= 0) {
      cartItems[index].quantity += selectedCartItem.quantity;
    } else {
      cartItems.add(selectedCartItem);
    }

    updateCart();
    TLoaders.customToast(message: 'Your Product has been added to the Cart.');
  }

  void addOneToCart(CartItemModel item) {
    int index = cartItems.indexWhere((cartItem) =>
    cartItem.productId == item.productId &&
        cartItem.variationId == item.variationId);

    if (index >= 0) {
      cartItems[index].quantity += 1;
    } else {
      cartItems.add(item);
    }

    updateCart();
  }

  void removeOneFromCart(CartItemModel item) {
    int index = cartItems.indexWhere((cartItem) =>
    cartItem.productId == item.productId &&
        cartItem.variationId == item.variationId);

    if (index >= 0) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity -= 1;
      } else {
        removeFromCartDialog(index);
      }
      updateCart();
    }
  }

  void removeFromCartDialog(int index) {
    Get.defaultDialog(
      title: 'Remove Product',
      middleText: 'Are you sure you want to remove this product?',
      onConfirm: () {
        cartItems.removeAt(index);
        updateCart();
        TLoaders.customToast(message: 'Product removed from the Cart.');
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }

  void updateCart() {
    updateCartTotals();
    saveCartItems();
    cartItems.refresh();
  }

  Future<void> loadCartItems() async {
    try {
      print('CartController: Loading cart items');
      final cartItemStrings = storage.readData<List<dynamic>>('cartItems');
      if (cartItemStrings != null) {
        cartItems.assignAll(
            cartItemStrings.map((item) => CartItemModel.fromJson(item as Map<String, dynamic>)));
        updateCartTotals();
        print('CartController: Loaded ${cartItems.length} cart items');
      } else {
        print('CartController: No cart items found in storage');
      }
    } catch (e) {
      print('CartController: Error loading cart items: $e');
      cartItems.clear();
      if (Get.context != null) {
        TLoaders.warningSnackBar(title: 'Warning', message: 'Failed to load cart items: $e');
      }
    }
  }

  void updateCartTotals() {
    double calculatedTotalPrice = 0.0;
    int calculatedNoOfItems = 0;

    for (var item in cartItems) {
      calculatedTotalPrice += (item.price) * item.quantity.toDouble();
      calculatedNoOfItems += item.quantity;
    }

    totalCartPrice.value = calculatedTotalPrice;
    noOfCartItems.value = calculatedNoOfItems;
  }

  void saveCartItems() {
    try {
      final cartItemStrings = cartItems.map((item) => item.toJson()).toList();
      storage.writeData('cartItems', cartItemStrings);
      print('CartController: Saved ${cartItems.length} cart items to storage');
    } catch (e) {
      print('CartController: Error saving cart items: $e');
      if (Get.context != null) {
        TLoaders.warningSnackBar(title: 'Warning', message: 'Failed to save cart items: $e');
      }
    }
  }

  void updateAlreadyAddedProductCount(ProductModel product) {
    if (product.productType == "single") {
      productQuantityInCart.value = getProductQuantityInCart(product.id);
    } else {
      final variationId = variationController.selectedVariation.value.id;
      if (variationId.isNotEmpty) {
        productQuantityInCart.value = getVariationQuantityInCart(product.id, variationId);
      } else {
        productQuantityInCart.value = 0;
      }
    }
  }

  int getProductQuantityInCart(String productId) {
    return cartItems
        .where((item) => item.productId == productId)
        .fold(0, (previousValue, element) => previousValue + element.quantity);
  }

  int getVariationQuantityInCart(String productId, String variationId) {
    final foundItem = cartItems.firstWhere(
          (item) => item.productId == productId && item.variationId == variationId,
      orElse: () => CartItemModel.empty(),
    );

    return foundItem.quantity;
  }

  void clearCart() {
    productQuantityInCart.value = 0;
    cartItems.clear();
    updateCart();
  }
}