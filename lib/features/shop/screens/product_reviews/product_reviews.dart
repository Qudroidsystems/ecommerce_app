import 'package:flutter/material.dart';
import 'package:cwt_ecommerce_app/utils/http/http_client.dart'; // Adjust path to your THttpHelper
import 'package:cwt_ecommerce_app/features/shop/models/product_review_model.dart'; // Adjust path to your ProductReviewModel

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/sizes.dart';
import 'widgets/progress_indicator_and_rating.dart';
import 'widgets/rating_star.dart';
import 'widgets/review_details_container.dart';

class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({super.key});

  // Fetch product reviews from the API
  Future<List<ProductReviewModel>> _fetchProductReviews() async {
    try {
      final response = await THttpHelper.get('api/product-reviews'); // Adjust endpoint as needed
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => ProductReviewModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// -- Appbar
      appBar: const TAppBar(title: Text('Reviews & Ratings'), showBackArrow: true),

      /// -- Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// -- Reviews Info
              const Text(
                "Ratings and reviews are verified and are from people who use the same type of device that you use.",
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Overall Product Ratings (Static for now, could be dynamic)
              const TOverallProductRating(),
              const TRatingBarIndicator(rating: 3.5), // Replace with dynamic data if available
              const Text("12,611"), // Replace with dynamic count if available
              const SizedBox(height: TSizes.spaceBtwSections),

              /// User Reviews List with FutureBuilder
              FutureBuilder<List<ProductReviewModel>>(
                future: _fetchProductReviews(),
                builder: (context, snapshot) {
                  // Loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Error state
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // No data state
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No reviews available.'));
                  }

                  // Data loaded successfully
                  final reviews = snapshot.data!;
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: reviews.length,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwSections),
                    itemBuilder: (_, index) => UserReviewCard(productReview: reviews[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}