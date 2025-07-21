class ProductReviewModel {
  final String id;
  final String userId;
  final double rating;
  final String? comment;
  final String? userName;
  final DateTime timestamp;
  final String? userImageUrl;
  final String? companyComment;
  final DateTime? companyTimestamp;

  ProductReviewModel({
    required this.id,
    required this.userId,
    required this.rating,
    required this.timestamp,
    this.comment,
    this.userName,
    this.userImageUrl,
    this.companyComment,
    this.companyTimestamp,
  });

  /// Create an empty instance for clean code
  static ProductReviewModel empty() => ProductReviewModel(
    id: '',
    userId: '',
    rating: 5,
    timestamp: DateTime.now(),
  );

  /// Convert model to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'user_name': userName,
      'timestamp': timestamp.toIso8601String(),
      'user_image_url': userImageUrl,
      'company_comment': companyComment,
      'company_timestamp': companyTimestamp?.toIso8601String(),
    };
  }

  /// Create a ProductReviewModel from JSON received from the Laravel API
  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    return ProductReviewModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      rating: (json['rating'] is String ? double.parse(json['rating']) : json['rating'].toDouble()),
      comment: json['comment'],
      userName: json['user_name'],
      timestamp: DateTime.parse(json['timestamp']),
      userImageUrl: json['user_image_url'],
      companyComment: json['company_comment'],
      companyTimestamp: json['company_timestamp'] != null ? DateTime.parse(json['company_timestamp']) : null,
    );
  }
}