import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await NotificationService.getNotifications();
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load notifications';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(NotificationModel n) async {
    if (n.isRead) return;
    final ok = await NotificationService.markAsRead(n.id);
    if (ok) {
      setState(() {
        final index = _notifications.indexWhere((e) => e.id == n.id);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: n.id,
            role: n.role,
            userId: n.userId,
            type: n.type,
            title: n.title,
            message: n.message,
            referenceId: n.referenceId,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final ok = await NotificationService.markAllAsRead();
    if (ok) {
      setState(() {
        _notifications = _notifications
            .map(
              (n) => NotificationModel(
                id: n.id,
                role: n.role,
                userId: n.userId,
                type: n.type,
                title: n.title,
                message: n.message,
                referenceId: n.referenceId,
                isRead: true,
                createdAt: n.createdAt,
              ),
            )
            .toList();
      });
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'member_added':
      case 'member_assigned':
        return Icons.person_add_alt_1_rounded;
      case 'membership_assigned':
      case 'membership_renewed':
        return Icons.card_membership_rounded;
      case 'payment_received':
        return Icons.payments_outlined;
      case 'membership_expiring':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'payment_received':
        return AppTheme.active;
      case 'membership_expiring':
        return AppTheme.pending;
      case 'member_added':
      case 'member_assigned':
        return const Color(0xFF1976D2);
      default:
        return AppTheme.primary;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Notifications'),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _error!,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadNotifications,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: _loadNotifications,
              child: _notifications.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 64,
                          color: AppTheme.textHint,
                        ),
                        SizedBox(height: 12),
                        Center(
                          child: Text(
                            'No notifications yet',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: _notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final n = _notifications[index];
                        final color = _colorForType(n.type);
                        return InkWell(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                          onTap: () => _markAsRead(n),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: n.isRead
                                  ? AppTheme.surface
                                  : color.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMd,
                              ),
                              border: Border.all(
                                color: n.isRead
                                    ? AppTheme.border
                                    : color.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _iconForType(n.type),
                                    color: color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              n.title,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: n.isRead
                                                    ? FontWeight.w500
                                                    : FontWeight.w700,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                          ),
                                          if (!n.isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              margin: const EdgeInsets.only(
                                                left: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n.message,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _timeAgo(n.createdAt),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textHint,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
