import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:talent_link/services/notification_service.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/notifications/notification_navigator.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  List notifications = [];
  bool isLoading = true;
  late AnimationController _animationController;
  late NotificationService _notificationService;
  final logger = Logger();

  // for user notifications
  Future<void> _fetchNotifications() async {
    try {
      List allNotifications = [];

      final userNotifications =
          await _notificationService.fetchUserNotificationsLikeCommentReply();
      if (mounted) {
        final userNotificationsList =
            userNotifications.map((notification) {
              String notificationType = 'post';
              final title = notification.title?.toLowerCase() ?? '';
              final body = notification.body?.toLowerCase() ?? '';

              if (title.contains('like') || body.contains('like')) {
                notificationType = 'like';
              } else if (title.contains('comment') ||
                  body.contains('comment')) {
                notificationType = 'comment';
              } else if (title.contains('reply') || body.contains('reply')) {
                notificationType = 'reply';
              }

              return {
                'id': notification.id,
                'title': notification.title,
                'body': notification.body,
                'timestamp': notification.timestamp,
                'read': notification.read ?? false,
                'type': notificationType,
                'jobId': notification.jobId,
                'senderId': notification.senderId,
                'postId': notification.postId,
              };
            }).toList();

        allNotifications.addAll(userNotificationsList);
        allNotifications.sort((a, b) {
          final aTime = DateTime.tryParse(a['timestamp']) ?? DateTime.now();
          final bTime = DateTime.tryParse(b['timestamp']) ?? DateTime.now();
          return bTime.compareTo(aTime);
        });

        setState(() {
          notifications = allNotifications;
          isLoading = false;
        });
      }

      //for job notifications
      final jobNotifications =
          await _notificationService.fetchJobNotifications();
      if (mounted) {
        final jobNotificationsList =
            jobNotifications.map((notification) {
              return {
                'id': notification.id,
                'title': notification.title,
                'body': notification.body,
                'timestamp': notification.timestamp,
                'type': 'job',
                'jobId': notification.jobId,
                'senderId': notification.senderId,
                'postId': notification.postId,
                'read': notification.read ?? false,
              };
            }).toList();
        logger.d("Job notifications list", error: jobNotificationsList);

        allNotifications.addAll(jobNotificationsList);

        setState(() {
          notifications = allNotifications;
          isLoading = false;
        });
      }
    } catch (e) {
      logger.e("Error fetching notifications", error: e);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fetchNotifications();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite_rounded;
      case 'comment':
        return Icons.comment_rounded;
      case 'reply':
        return Icons.reply_rounded;
      case 'friend':
        return Icons.person_add_rounded;
      case 'system':
        return Icons.system_update_rounded;
      case 'event':
        return Icons.event_rounded;
      case 'job':
        return Icons.work_rounded;
      case 'post':
        return Icons.post_add_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String type, bool read) {
    if (read) return Colors.grey;

    final primaryColor = Theme.of(context).primaryColor;
    switch (type) {
      case 'like':
        return Colors.pink;
      case 'comment':
        return Colors.blue;
      case 'reply':
        return Colors.green;
      case 'job':
        return primaryColor;
      default:
        return primaryColor;
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      isLoading = true;
    });
    await _fetchNotifications();
    return Future.value();
  }

  Future<void> _markAsRead(int index) async {
    final notification = notifications[index];
    final notificationId = notification['id'];

    setState(() {
      notifications[index]['read'] = true;
    });

    try {
      await _notificationService.markAsRead(notificationId);
    } catch (e) {
      setState(() {
        notifications[index]['read'] = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark notification as read'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Colors.white,
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Notifications',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.done_all_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            for (var notification in notifications) {
                              notification['read'] = true;
                            }
                          });
                        },
                        tooltip: 'Mark all as read',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  isLoading
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 60,
                              width: 60,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Loading notifications...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                      : notifications.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: Theme.of(context).primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return _buildNotificationCard(notification, index);
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 80,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map notification, int index) {
    final bool isRead = notification['read'];
    final String type = notification['type'];
    final Color notificationColor = _getNotificationColor(type, isRead);

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutQuint,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Dismissible(
        key: Key(notification['id']),
        background: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          setState(() {
            notifications.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Notification dismissed'),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () {
                  setState(() {
                    notifications.insert(index, notification);
                  });
                },
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: isRead ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isRead ? Colors.transparent : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              _markAsRead(index);
              NotificationNavigator(context).navigateBasedOnType(notification);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color:
                    isRead ? Colors.white : notificationColor.withOpacity(0.05),
              ),
              child: Stack(
                children: [
                  if (!isRead)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: notificationColor,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: notificationColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getNotificationIcon(type),
                            color: notificationColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['title'],
                                style: TextStyle(
                                  fontWeight:
                                      isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification['body'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    notification['timestamp'],
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (!isRead)
                                    TextButton(
                                      onPressed: () => _markAsRead(index),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 0,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Mark as Read',
                                        style: TextStyle(
                                          color: notificationColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
