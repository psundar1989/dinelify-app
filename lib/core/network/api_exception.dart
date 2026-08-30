/// Mirrors Laravel's `{success:false, message, errors}` envelope. Thrown by
/// every service method so the UI layer always deals with one error type.
class ApiException implements Exception {
  const ApiException({required this.message, this.errors, this.statusCode});

  final String message;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  /// First validation message for a given field, if any (e.g. from a 422).
  String? fieldError(String field) {
    final value = errors?[field];
    if (value is List && value.isNotEmpty) return value.first.toString();
    return null;
  }

  @override
  String toString() => message;
}
