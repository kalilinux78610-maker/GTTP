class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class OfflineSavedException extends ApiException {
  OfflineSavedException([super.message = 'Saved offline']);
}
