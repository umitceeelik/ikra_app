/// Thrown when an online operation is attempted without internet access.
class NoInternetException implements Exception {
  final String message;
  NoInternetException([this.message = 'NO_INTERNET']);
  @override
  String toString() => message;
}
