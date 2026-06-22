import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;

  Future<void> initialize() async {
    List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    _checkStatus(result);
    _connectivity.onConnectivityChanged.listen(_checkStatus);
  }

  void _checkStatus(List<ConnectivityResult> results) {
    // If any of the results are not 'none', there is a connection
    bool hasConnection = results.any((result) => result != ConnectivityResult.none);
    _connectionController.add(hasConnection);
  }

  Future<bool> checkCurrentStatus() async {
    List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  void dispose() {
    _connectionController.close();
  }
}
