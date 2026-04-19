import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nutilize/core/models/app_notification.dart';
import 'package:nutilize/core/models/office.dart';
import 'package:nutilize/core/models/reservation.dart';
import 'package:nutilize/core/models/reservation_approval.dart';
import 'package:nutilize/core/services/office_service.dart';
import 'package:nutilize/core/services/reservation_service.dart';

class NotificationService extends ChangeNotifier {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ReservationService _reservationService = ReservationService();
  final OfficeService _officeService = OfficeService();

  int? _userId;
  List<AppNotification> _notifications = const [];
  Set<String> _seenApprovalKeys = <String>{};
  bool _isInitialized = false;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  Future<void> initializeForUser(int userId) async {
    if (_isInitialized && _userId == userId) {
      return;
    }

    _userId = userId;
    await _loadPersistedState();

    _isInitialized = true;
    notifyListeners();
  }

  Future<List<AppNotification>> checkForNewApprovalNotifications() async {
    if (_userId == null) {
      return const [];
    }

    final reservations = await _reservationService.getUserReservations(_userId!);
    if (reservations.isEmpty) {
      return const [];
    }

    final offices = await _officeService.getAllOffices();
    final officeById = {for (final office in offices) office.officeId: office};

    final List<AppNotification> newNotifications = [];

    for (final reservation in reservations) {
      final approvals = await _reservationService.getReservationApprovals(
        reservation.reservationId,
      );

      for (final approval in approvals) {
        if (approval.status != 'approved' && approval.status != 'rejected') {
          continue;
        }

        final dedupeKey = '${approval.approvalId}:${approval.status}';
        if (_seenApprovalKeys.contains(dedupeKey)) {
          continue;
        }

        final officeName = _resolveOfficeName(officeById[approval.officeId]);
        final newItem = _buildNotificationItem(
          approval: approval,
          reservation: reservation,
          officeName: officeName,
        );

        _seenApprovalKeys.add(dedupeKey);
        newNotifications.add(newItem);
      }
    }

    if (newNotifications.isEmpty) {
      return const [];
    }

    _notifications = [...newNotifications, ..._notifications];
    await _saveAll();
    notifyListeners();

    return newNotifications;
  }

  Future<void> markAllAsRead() async {
    if (_notifications.isEmpty) {
      return;
    }

    _notifications = _notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList(growable: false);

    await _saveNotifications();
    notifyListeners();
  }

  AppNotification _buildNotificationItem({
    required ReservationApproval approval,
    required Reservation reservation,
    required String officeName,
  }) {
    final isApproved = approval.status == 'approved';
    final actionText = isApproved ? 'approved' : 'declined';

    return AppNotification(
      id: '${approval.approvalId}:${approval.status}:${DateTime.now().millisecondsSinceEpoch}',
      title: 'Reservation $actionText',
      message:
          '${reservation.activityName} was $actionText by $officeName.',
      type: isApproved ? 'approved' : 'rejected',
      reservationId: reservation.reservationId,
      createdAt: DateTime.now(),
      isRead: false,
    );
  }

  String _resolveOfficeName(Office? office) {
    if (office == null) {
      return 'an approver';
    }

    final name = office.departmentName.trim();
    return name.isEmpty ? 'an approver' : name;
  }

  String _notificationsStorageKey() => 'app_notifications_user_${_userId ?? 0}';

  String _seenKeysStorageKey() => 'app_seen_approval_keys_user_${_userId ?? 0}';

  Future<void> _loadPersistedState() async {
    _notifications = const [];
    _seenApprovalKeys = <String>{};

    final rawNotifications =
        await _storage.read(key: _notificationsStorageKey());
    if (rawNotifications != null && rawNotifications.isNotEmpty) {
      try {
        final parsed = jsonDecode(rawNotifications) as List<dynamic>;
        _notifications = parsed
            .map((entry) =>
                AppNotification.fromJson(entry as Map<String, dynamic>))
            .toList(growable: false);
      } catch (_) {
        _notifications = const [];
      }
    }

    final rawSeenKeys = await _storage.read(key: _seenKeysStorageKey());
    if (rawSeenKeys != null && rawSeenKeys.isNotEmpty) {
      try {
        final parsed = jsonDecode(rawSeenKeys) as List<dynamic>;
        _seenApprovalKeys =
            parsed.map((entry) => entry.toString()).toSet();
      } catch (_) {
        _seenApprovalKeys = <String>{};
      }
    }
  }

  Future<void> _saveAll() async {
    await _saveNotifications();
    await _saveSeenKeys();
  }

  Future<void> _saveNotifications() async {
    final serialized = jsonEncode(
      _notifications.map((notification) => notification.toJson()).toList(),
    );
    await _storage.write(key: _notificationsStorageKey(), value: serialized);
  }

  Future<void> _saveSeenKeys() async {
    final serialized = jsonEncode(_seenApprovalKeys.toList(growable: false));
    await _storage.write(key: _seenKeysStorageKey(), value: serialized);
  }
}
