class NotificationModel {
  final String? id;
  final String? title;
  final String? body;
  final String? timestamp;
  final String? reciver;
  final String? jobId;
  final String? senderId;
  final String? postId;
  final bool? read;

  NotificationModel({
    this.id,
    this.title,
    this.body,
    this.timestamp,
    this.reciver,
    this.jobId,
    this.senderId,
    this.postId,
    this.read,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'No title',
      body: json['body'] ?? 'No body',
      timestamp: json['timestamp']?.toString() ?? 'Unknown time',
      reciver: json['reciver'] ?? 'No reciver',
      jobId: json['jobId'] ?? 'No jobId',
      senderId: json['senderId'] ?? 'No senderId',
      postId: json['postId'] ?? 'No postId',
      read: json['read'] ?? false,
    );
  }
}
