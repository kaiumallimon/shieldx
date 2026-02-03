// =====================================================
// ShieldX Connection Monitor
// File: connection_monitor.dart
// =====================================================
// Description: Network connectivity monitoring for
// offline-first sync coordination
// =====================================================

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Connection status enum
enum ConnectionStatus {
  online,
  offline,
  unknown,
}

/// Connection monitor service
class ConnectionMonitor extends ChangeNotifier {
  static ConnectionMonitor? _instance;
  ConnectionStatus _status = ConnectionStatus.unknown;
  Timer? _checkTimer;
  final StreamController<ConnectionStatus> _statusController = StreamController<ConnectionStatus>.broadcast();

  ConnectionMonitor._();

  factory ConnectionMonitor() {
    _instance ??= ConnectionMonitor._();
    return _instance!;
  }

  /// Current connection status
  ConnectionStatus get status => _status;

  /// Connection status stream
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  /// Check if online
  bool get isOnline => _status == ConnectionStatus.online;

  /// Check if offline
  bool get isOffline => _status == ConnectionStatus.offline;

  /// Start monitoring
  void startMonitoring() {
    _checkTimer?.cancel();
    _checkConnection();
    _checkTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkConnection();
    });
  }

  /// Stop monitoring
  void stopMonitoring() {
    _checkTimer?.cancel();
  }

  /// Manual connection check
  Future<void> _checkConnection() async {
    try {
      // Simple connectivity check
      // In production, implement proper network check
      final newStatus = ConnectionStatus.online; // Placeholder

      if (newStatus != _status) {
        _status = newStatus;
        _statusController.add(_status);
        notifyListeners();
      }
    } catch (e) {
      if (_status != ConnectionStatus.offline) {
        _status = ConnectionStatus.offline;
        _statusController.add(_status);
        notifyListeners();
      }
    }
  }

  /// Force online status (for testing)
  void setOnline() {
    _status = ConnectionStatus.online;
    _statusController.add(_status);
    notifyListeners();
  }

  /// Force offline status (for testing)
  void setOffline() {
    _status = ConnectionStatus.offline;
    _statusController.add(_status);
    notifyListeners();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _statusController.close();
    super.dispose();
  }
}
