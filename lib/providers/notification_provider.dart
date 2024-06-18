import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/services/notification_service.dart';
import 'package:v1_rentals/models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final PushNotificationService _pushNotificationService =
      PushNotificationService();
  List<NotificationModel> _notifications = [];
  bool _hasNewNotification = false;
  int _notificationCount = 0;
  String? userId;
  StreamSubscription? _notificationSubscription;

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
    _notificationSubscription?.cancel();
    _notificationSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _notifications = snapshot.docs.map((doc) {
        return NotificationModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
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

  Future<void> removeNotification(String notificationId) async {
    if (userId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
      _notifications
          .removeWhere((notification) => notification.id == notificationId);
      _notificationCount--;
      notifyListeners();
    } catch (e) {
      print("Failed to delete notification: $e");
    }
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

  Future<void> sendUserNotification(
      String userId, String title, String body) async {
    try {
      await _pushNotificationService.sendUserNotification(userId, title, body);
    } catch (e) {
      print('Error sending user notification: $e');
    }
  }

  Future<void> sendVendorNotification(
      String vendorId, String title, String body) async {
    try {
      await _pushNotificationService.sendVendorNotification(
          vendorId, title, body);
    } catch (e) {
      print('Error sending vendor notification: $e');
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
}
