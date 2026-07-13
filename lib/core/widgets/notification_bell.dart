import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/notification_service.dart';
import '../utils/theme.dart';

/// A bell icon with an unread-count badge.
/// Polls the unread count every 30 seconds and whenever the notifications
/// screen is closed (so the badge updates right after marking things read).
class NotificationBell extends StatefulWidget {
  final Color iconColor;
  final double size;

  const NotificationBell({
    Key? key,
    this.iconColor = Colors.white,
    this.size = 24,
  }) : super(key: key);

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unreadCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _refreshCount();
    // Poll periodically so the badge stays fresh while the dashboard is open
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshCount(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refreshCount() async {
    final count = await NotificationService.getUnreadCount();
    if (mounted) setState(() => _unreadCount = count);
  }

  Future<void> _openNotifications() async {
    await Get.toNamed('/notifications');
    _refreshCount(); // refresh badge after returning (some may have been read)
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: _openNotifications,
          icon: Icon(
            Icons.notifications_outlined,
            color: widget.iconColor,
            size: widget.size,
          ),
          tooltip: 'Notifications',
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primaryDark, width: 1),
              ),
              child: Text(
                _unreadCount > 9 ? '9+' : '$_unreadCount',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
