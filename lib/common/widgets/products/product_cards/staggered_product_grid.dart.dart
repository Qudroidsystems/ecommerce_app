import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; // Add this dependency
import '../../../../features/shop/models/product_model.dart';
import 'product_card_vertical.dart';

class TTemuStyleProductGrid extends StatelessWidget {
  const TTemuStyleProductGrid({
    super.key,
    required this.products,
    this.isNetworkImage = true,
  });

  final List<ProductModel> products;
  final bool isNetworkImage;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // Vary the width for Temu-like effect
        double width = _getVariableWidth(index);

        return TProductCardVertical(
          product: products[index],
          width: width,
          isNetworkImage: isNetworkImage,
        );
      },
    );
  }

  double _getVariableWidth(int index) {
    // Create pattern: normal, wide, normal, normal, wide, normal...
    List<double> widthPattern = [180, 220, 180, 180, 240, 180, 200, 180];
    return widthPattern[index % widthPattern.length];
  }
}