import 'package:artbooking/types/user/user_auth.dart';
import 'package:artbooking/types/user/user_firestore.dart';

/// This app's user model.
class User {
  /// Firebase auth's user.
  final UserAuth? authUser;

  /// Firestor's user.
  final UserFirestore? firestoreUser;

  User({this.authUser, this.firestoreUser});
}
