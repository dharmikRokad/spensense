import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/utils/logger.dart';

enum NotificationPermissionStatus { granted, denied, unknown }

class NotificationPermissionNotifier
    extends Notifier<NotificationPermissionStatus> {
  @override
  NotificationPermissionStatus build() => NotificationPermissionStatus.unknown;

  Future<void> checkAndRequest() async {
    // Post notifications permission (Android 13+)
    final postStatus = await Permission.notification.status;
    if (postStatus.isGranted) {
      state = NotificationPermissionStatus.granted;
      return;
    }

    final result = await Permission.notification.request();
    state = result.isGranted
        ? NotificationPermissionStatus.granted
        : NotificationPermissionStatus.denied;

    appLogger.i('Notification permission: ${state.name}');
  }
}

final notificationPermissionProvider =
    NotifierProvider<
      NotificationPermissionNotifier,
      NotificationPermissionStatus
    >(NotificationPermissionNotifier.new);
