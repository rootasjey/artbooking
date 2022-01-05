import 'package:artbooking/types/globals/upload_state.dart';
import 'package:artbooking/types/user/user.dart';
import 'package:artbooking/types/globals/user_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _userNotifierProvider = StateNotifierProvider<UserNotifier, User>(
  (ref) => UserNotifier(User()),
);

class AppState {
  static final userProvider = _userNotifierProvider;
}

class GlobalsState {
  // final user = userNotiifer;
  final upload = UploadState();
}
