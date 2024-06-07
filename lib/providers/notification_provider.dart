import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/auth/notification_service.dart';
import 'package:v1_rentals/models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final PushNotificationService _pushNotificationService =
      PushNotificationService();
  List<NotificationModel> _notifications = [];
  bool _hasNewNotification = false;
  int _notificationCount = 0;
  String? userId;

  NotificationProvider({this.userId}) {
    if (userId != null) {
      _loadNotifications();
    }
  }

  List<NotificationModel> get notifications => _notifications;
  bool get hasNewNotification => _hasNewNotification;
  int get notificationCount => _notificationCount;

  void updateUserId(String? newUserId) {
    if (userId != newUserId) {
      userId = newUserId;
      if (userId != null) {
        _loadNotifications();
      }
    }
  }

  Future<void> _loadNotifications() async {
    if (userId == null) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _notifications = snapshot.docs.map((doc) {
        return NotificationModel.fromMap(doc.data());
      }).toList();
      _hasNewNotification = true;
      _notificationCount = _notifications.length;
      notifyListeners();
    });
  }

  Future<void> addNotification(NotificationModel notification) async {
    if (userId == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(notification.toMap());
    _notificationCount++;
    _hasNewNotification = true;
    notifyListeners();
  }

  void markAsRead() {
    _hasNewNotification = false;
    _notificationCount = 0;
    notifyListeners();
  }

  Future<void> updateFcmToken(String userId, String token) async {
    try {
      await _authService.updateUserData(userId, {'fcmToken': token});
      notifyListeners();
    } catch (e) {
      print("Failed to update FCM token: $e");
    }
  }

  Future<void> sendUserNotification(String userId) async {
    try {
      await _pushNotificationService.sendUserNotification(userId);
    } catch (e) {
      print('Error sending user notification: $e');
    }
  }

  Future<void> sendVendorNotification(String vendorId) async {
    try {
      await _pushNotificationService.sendVendorNotification(vendorId);
    } catch (e) {
      print('Error sending vendor notification: $e');
    }
  }
}
