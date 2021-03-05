import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';

class CloudHelper {
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
}
