import 'package:artbooking/globals/utilities/cloud_utilities.dart';
import 'package:artbooking/globals/utilities/crop_editor_utilities.dart';
import 'package:artbooking/globals/utilities/date_utilities.dart';
import 'package:artbooking/globals/utilities/flash_utilities.dart';
import 'package:artbooking/globals/utilities/fonts_utilities.dart';
import 'package:artbooking/globals/utilities/search_utilities.dart';
import 'package:artbooking/globals/utilities/storage_utilities.dart';
import 'package:artbooking/globals/utilities/language_utilities.dart';
import 'package:artbooking/globals/utilities/size_utilities.dart';
import 'package:artbooking/types/book/book_illustration.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class Utilities {
  /// Beautiful logger.
  static Logger logger = Logger();

  static const cloud = const CloudUtilities();
  static const cropEditor = const CropEditorUtilities();
  static const date = const DateUtilities();
  static const flash = const FlashUtilities();
  static const fonts = const FontsUtilities();
  static const lang = const LanguageUtilities();
  static const search = const SearchUtilities();
  static const size = const SizeUtils();
  static const storage = const StorageUtilities();

  /// Generate an unique key for illustrations in book (frontend).
  static String generateIllustrationKey(BookIllustration bookIllustration) {
    final String id = bookIllustration.id;
    DateTime createdAt = bookIllustration.createdAt;

    return "$id--${createdAt.millisecondsSinceEpoch}";
  }

  static String getStringWithUnit(int usedBytes) {
    if (usedBytes < 1000) {
      return '$usedBytes bytes';
    }

    if (usedBytes < 1000000) {
      return '${usedBytes / 1000} KB';
    }

    if (usedBytes < 1000000000) {
      return '${usedBytes / 1000000} MB';
    }

    if (usedBytes < 1000000000000) {
      return '${usedBytes / 1000000000} GB';
    }

    if (usedBytes < 1000000000000000) {
      return '${usedBytes / 1000000000000} TB';
    }

    return '${usedBytes / 1000000000000000} PB';
  }

  static Future<User?> getFireAuthUser() async {
    final credentialsMap = Utilities.storage.getCredentials();

    final String email = credentialsMap['email'] ?? '';
    final String password = credentialsMap['password'] ?? '';

    if (email.isEmpty || password.isEmpty) {
      return Future.value(null);
    }

    final firebaseAuthInstance = FirebaseAuth.instance;
    final authResult = await firebaseAuthInstance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return authResult.user;
  }

  static Future<UserFirestore?> getFirestoreUser(String userId) async {
    final docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    final data = docSnapshot.data();
    if (!docSnapshot.exists || data == null) {
      return null;
    }

    data['id'] = docSnapshot.id;
    return UserFirestore.fromMap(data);
  }

  static String getPageTitle(String trailingText) {
    final base = "ArtBooking •";
    return "$base $trailingText";
  }
}
