import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import 'no_connection_screen.dart';

class OfflineWrapper extends StatefulWidget {
  final Widget child;

  const OfflineWrapper({super.key, required this.child});

  @override
  State<OfflineWrapper> createState() => _OfflineWrapperState();
}

class _OfflineWrapperState extends State<OfflineWrapper> {
  bool _hasConnection = true;
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _connectivityService.connectionStream.listen((event) {
      if (mounted) {
        setState(() {
          _hasConnection = event;
        });
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    bool status = await _connectivityService.checkCurrentStatus();
    if (mounted) {
      setState(() {
        _hasConnection = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasConnection) {
      return NoConnectionScreen(
        onRetry: () {
          _checkInitialConnection();
        },
      );
    }
    return widget.child;
  }
}
