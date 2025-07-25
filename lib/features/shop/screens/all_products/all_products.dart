import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/products/product_cards/product_card_vertical.dart';
import '../../../../common/widgets/shimmers/vertical_product_shimmer.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/device/device_utility.dart';
import '../../../../utils/helpers/cloud_helper_functions.dart';
import '../../controllers/all_products_controller.dart';
import '../../models/product_model.dart';

/// Represents a screen that displays a list of products with the option for custom sorting and filtering.
class AllProducts extends StatelessWidget {
  const AllProducts({
    super.key,
    required this.title,
    this.futureMethod,
  });

  /// The title of the screen.
  final String title;

  /// Represents a function to fetch products as a future from an API.
  final Future<List<ProductModel>>? futureMethod;

  @override
  Widget build(BuildContext context) {
    // Initialize controller for managing product fetching
    final controller = Get.put(AllProductsController());

    return Scaffold(
      appBar: TAppBar(title: Text(title), showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: FutureBuilder<List<ProductModel>>(
            future: futureMethod ?? controller.fetchAllProducts(), // Default to fetching all products
            builder: (_, snapshot) {
              // Check the state of the FutureBuilder snapshot
              const loader = TVerticalProductShimmer();
              final widget = TCloudHelperFunctions.checkMultiRecordState(
                snapshot: snapshot,
                loader: loader,
                errorMessage: 'Failed to load products. Please try again.',
              );

              // Return appropriate widget based on snapshot state
              if (widget != null) return widget;

              // Products found!
              final products = snapshot.data!;
              return TSortableProductList(products: products);
            },
          ),
        ),
      ),
    );
  }
}

/// Represents a sortable list of products that can be filtered and sorted.
class TSortableProductList extends StatelessWidget {
  const TSortableProductList({
    super.key,
    required this.products,
  });

  /// The list of products to be displayed.
  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    // Initialize controller for managing product sorting
    final controller = Get.put(AllProductsController());
    // Assign the products to the controller
    controller.assignProducts(products);

    return Column(
      children: [
        /// -- Sort & Filter Section
        Row(
          children: [
            Obx(
                  () => Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.sort),
                    labelText: 'Sort By',
                  ),
                  value: controller.selectedSortOption.value,
                  onChanged: (value) {
                    // Sort products based on the selected option
                    controller.sortProducts(value!);
                  },
                  items: ['Name', 'Higher Price', 'Lower Price', 'Sale', 'Newest', 'Popularity']
                      .map((option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwSections),

        /// Product Grid Section
        Obx(
              () => controller.products.isEmpty
              ? const Center(child: Text('No products available.'))
              : TGridLayout(
            itemCount: controller.products.length,
            itemBuilder: (_, index) => TProductCardVertical(
              product: controller.products[index],
              isNetworkImage: true,
            ),
          ),
        ),

        /// Bottom spacing to accommodate the navigation bar
        SizedBox(height: TDeviceUtils.getBottomNavigationBarHeight() + TSizes.defaultSpace),
      ],
    );
  }
}