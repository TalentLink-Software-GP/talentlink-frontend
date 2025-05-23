// app_lifecycle_manager.dart
import 'package:flutter/material.dart';
import 'package:talent_link/services/socket_service.dart';

class AppLifecycleManager extends StatefulWidget {
  final Widget child;
  final String? userId;
  final String? token;

  const AppLifecycleManager({
    required this.child,
    this.userId,
    this.token,
    super.key,
  });

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  late final SocketService _socketService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePresence();
  }

  Future<void> _initializePresence() async {
    if (widget.userId == null || widget.token == null) return;

    _socketService = SocketService();
    await _socketService.initializePresence(
      url: const String.fromEnvironment(
        'API_URL',
        defaultValue: 'http://10.0.2.2:5000',
      ),
      userId: widget.userId!,
      token: widget.token!,
    );
    _isInitialized = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _socketService.updatePresence(false);
    } else if (state == AppLifecycleState.resumed) {
      _socketService.updatePresence(true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isInitialized) {
      _socketService.updatePresence(false);
      _socketService.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
