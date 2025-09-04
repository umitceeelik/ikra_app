import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin wrapper around connectivity_plus to check online/offline state.
class ConnectivityService {
  final Connectivity _connectivity;
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Returns true if the device has any network connectivity.
  Future<bool> hasInternet() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
