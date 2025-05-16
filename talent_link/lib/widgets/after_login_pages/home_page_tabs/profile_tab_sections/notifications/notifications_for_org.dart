// import 'package:flutter/material.dart';

// import 'package:talent_link/services/notificationService.dart';
// import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/notifications/notificationNavigator.dart';

// class orgNotificationsPage extends StatefulWidget {
//   @override
//   _orgNotificationsPageState createState() => _orgNotificationsPageState();
// }

// class _orgNotificationsPageState extends State<orgNotificationsPage> {
//   late NotificationService _notificationService;
//   late AnimationController _animationController;
//   List notifications = [];
//   bool isLoading = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(appBar: AppBar(title: Text('Notifications')));
//   }
// }

import 'package:flutter/material.dart';
import 'package:talent_link/services/notification_service.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/notifications/notification_navigator.dart';
import 'package:logger/logger.dart';

class OrgNotificationsPage extends StatefulWidget {
  const OrgNotificationsPage({super.key});

  @override
  OrgNotificationsPageState createState() => OrgNotificationsPageState();
}

class OrgNotificationsPageState extends State<OrgNotificationsPage>
    with SingleTickerProviderStateMixin {
  List notifications = [];
  bool isLoading = true;
  late AnimationController _animationController;
  late NotificationService _notificationService;
  final _logger = Logger();

  // for org notifications
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
          await _notificationService.fetchApplyForJobNotifications();
      if (mounted) {
        final jobNotificationsList =
            jobNotifications.map((notification) {
              return {
                'id': notification.id,
                'title': notification.title,
                'body': notification.body,
                'timestamp': notification.timestamp,
                'type': 'applyjob',
                'jobId': notification.jobId,
                'senderId': notification.senderId,
                'postId': notification.postId,
                'read': notification.read ?? false,
              };
            }).toList();
        _logger.d('Job notifications list:', error: jobNotificationsList);

        allNotifications.addAll(jobNotificationsList);

        setState(() {
          notifications = allNotifications;
          isLoading = false;
        });
      }
    } catch (e) {
      _logger.e("Error fetching notifications", error: e);
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
      duration: Duration(milliseconds: 300),
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
        return Icons.favorite;
      case 'comment':
        return Icons.comment_bank_rounded;
      case 'reply':
        return Icons.reply;

      case 'friend':
        return Icons.person_add;
      case 'system':
        return Icons.system_update;

      case 'event':
        return Icons.event;
      case 'applyjob':
        return Icons.work;
      case 'post':
        return Icons.post_add;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type, bool read) {
    if (read) return Colors.grey;

    switch (type) {
      case 'message':
        return Colors.blue;
      case 'friend':
        return Colors.green;
      case 'system':
        return Colors.purple;
      case 'payment':
        return Colors.amber;
      case 'event':
        return Colors.red;
      case 'applyjob':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      isLoading = true;
    });

    await _fetchNotifications();

    return Future.value();
  }

  // void _markAsRead(int index) {
  //   setState(() {
  //     notifications[index]['read'] = true;
  //   });
  // }
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

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark notification as read')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all),
            onPressed: () {
              setState(() {
                for (var notification in notifications) {
                  notification['read'] = true;
                }
              });
            },
            tooltip: 'Mark all as read',
          ),
        ],
        elevation: 0,
      ),
      body:
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
                    SizedBox(height: 20),
                    Text(
                      'Loading notifications...',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh: _handleRefresh,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationCard(notification, index);
                  },
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
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map notification, int index) {
    final bool isRead = notification['read'];
    final String type = notification['type'];

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
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
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              setState(() {
                notifications.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notification dismissed'),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      setState(() {
                        notifications.insert(index, notification);
                      });
                    },
                  ),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              elevation: isRead ? 0 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isRead ? Colors.transparent : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              color: isRead ? Colors.white : Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _markAsRead(index);
                  NotificationNavigator(
                    context,
                  ).navigateBasedOnType(notification);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _getNotificationColor(type, isRead).withValues(
                      red: _getNotificationColor(type, isRead).r.toDouble(),
                      green: _getNotificationColor(type, isRead).g.toDouble(),
                      blue: _getNotificationColor(type, isRead).b.toDouble(),
                      alpha: 26.0,
                    ),
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
                              color: _getNotificationColor(type, false),
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
                                color: _getNotificationColor(
                                  type,
                                  isRead,
                                ).withValues(
                                  red:
                                      _getNotificationColor(
                                        type,
                                        isRead,
                                      ).r.toDouble(),
                                  green:
                                      _getNotificationColor(
                                        type,
                                        isRead,
                                      ).g.toDouble(),
                                  blue:
                                      _getNotificationColor(
                                        type,
                                        isRead,
                                      ).b.toDouble(),
                                  alpha: 26.0,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getNotificationIcon(type),
                                color: _getNotificationColor(type, isRead),
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
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
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    notification['body'],
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        notification['timestamp'],
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (!isRead)
                                        TextButton(
                                          onPressed: () => _markAsRead(index),

                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 0,
                                            ),
                                            minimumSize: Size(0, 0),
                                            tapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                          child: Text(
                                            'Mark as Read',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 12,
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
      },
    );
  }
}
