import 'package:artbooking/types/globals/upload_state.dart';
import 'package:artbooking/types/user/user.dart';
import 'package:artbooking/types/user/user_auth.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:artbooking/types/globals/user_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalsState {
  final user = StateNotifierProvider<UserNotifier, User>(
    (ref) => UserNotifier(User()),
  );

  UserFirestore getUserFirestore() {
    final containerProvider = ProviderContainer();
    return containerProvider.read(user).firestoreUser ?? UserFirestore.empty();
  }

  UserAuth? getUserAuth() {
    final containerProvider = ProviderContainer();
    return containerProvider.read(user).authUser;
  }

  UserNotifier getUserNotifier() {
    final containerProvider = ProviderContainer();
    return containerProvider.read(user.notifier);
  }

  final upload = UploadState();
}
