import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';

class Cloud {
  static Map<String, dynamic> convertFromFun(
      LinkedHashMap<dynamic, dynamic> raw) {
    final hashMap = LinkedHashMap.from(raw);

    final Map<String, dynamic> converted = hashMap.map((key, value) {
      if (value is String ||
          value is num ||
          value is bool ||
          value is Timestamp ||
          value == null) {
        return MapEntry(key, value);
      }

      final d2 = convertFromFun(value);
      return MapEntry(key, d2);
    });

    return converted;
  }

  /// Call cloud functions related to tihs app on the right region.
  static HttpsCallable fun(
    String functionName, {
    HttpsCallableOptions options,
  }) {
    return FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'europe-west3',
    ).httpsCallable(
      functionName,
      options: options,
    );
  }

  /// Call cloud functions related to illustrations.
  /// Only the suffix is necessary,
  /// e.g. if the function's name is `illustrations-updateMetadata`,
  /// You only need to specify `updateMetadata`.
  static HttpsCallable illustrations(
    String functionName, {
    HttpsCallableOptions options,
  }) {
    return FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'europe-west3',
    ).httpsCallable(
      "illustrations-$functionName",
      options: options,
    );
  }
}
