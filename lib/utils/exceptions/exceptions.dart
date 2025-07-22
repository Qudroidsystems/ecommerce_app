/// Exception class for handling various errors.
class TExceptions implements Exception {
  /// The associated error message.
  final String message;
  final int? statusCode;

  /// Default constructor with a generic error message and optional status code.
  const TExceptions([this.message = 'An unexpected error occurred. Please try again.', this.statusCode]);

  /// Create an exception from an HTTP status code and optional error message.
  factory TExceptions.fromStatusCode(int statusCode, {String? errorMessage}) {
    String message;
    switch (statusCode) {
      case 400:
        message = errorMessage ?? 'Bad request. Please check your input.';
        break;
      case 401:
        message = errorMessage ?? 'Unauthorized. Please log in again.';
        break;
      case 403:
        message = errorMessage ?? 'Forbidden. You do not have permission to perform this action.';
        break;
      case 404:
        message = errorMessage ?? 'Resource not found.';
        break;
      case 422:
        message = errorMessage ?? 'Validation failed. Please check your input.';
        break;
      case 500:
        message = errorMessage ?? 'Server error. Please try again later.';
        break;
      default:
        message = errorMessage ?? 'Request failed with status: $statusCode';
    }
    return TExceptions(message, statusCode);
  }

  /// Create an exception from a Laravel error response.
  factory TExceptions.fromLaravelResponse(Map<String, dynamic> response, int statusCode) {
    String message = response['message']?.toString() ?? 'Request failed with status: $statusCode';
    if (statusCode == 422 && response['errors'] != null) {
      final errors = response['errors'] as Map<String, dynamic>;
      message += ' - ${errors.values.expand((e) => e as List).join(", ")}';
    }
    return TExceptions(message, statusCode);
  }

  @override
  String toString() => message;
}