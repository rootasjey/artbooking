import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/create_account_resp.dart';
import 'package:artbooking/types/update_email_resp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:artbooking/screens/home/home.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/utils/app_storage.dart';
import 'package:flutter/services.dart';

Future<bool> checkEmailAvailability(String email) async {
  try {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'europe-west3',
    ).httpsCallable(
      'users-checkEmailAvailability',
    );

    final resp = await callable.call({'email': email});
    final isOk = resp.data['isAvailable'] as bool;
    return isOk;
  } on FirebaseFunctionsException catch (exception) {
    debugPrint("[code: ${exception.code}] - ${exception.message}");
    return false;
  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}

Future<CreateAccountResp> createAccount({
  @required String email,
  @required String username,
  @required String password,
}) async {
  try {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'europe-west3',
    ).httpsCallable(
      'users-createAccount',
    );

    final response = await callable.call({
      'username': username,
      'password': password,
      'email': email,
    });

    return CreateAccountResp.fromJSON(response.data);
  } on FirebaseFunctionsException catch (exception) {
    debugPrint("[code: ${exception.code}] - ${exception.message}");
    return CreateAccountResp(
      success: false,
      error: CloudFuncError(
        code: exception.code,
        message: exception.message,
      ),
    );
  } catch (error) {
    return CreateAccountResp(
      success: false,
      error: CloudFuncError(
        code: '',
        message: error.toString(),
      ),
    );
  }
}

bool checkEmailFormat(String email) {
  return RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}")
      .hasMatch(email);
}

Future<bool> checkNameAvailability(String username) async {
  try {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'europe-west3',
    ).httpsCallable(
      'users-checkNameAvailability',
    );

    final resp = await callable.call({'name': username});
    final isOk = resp.data['isAvailable'] as bool;
    return isOk;
  } on FirebaseFunctionsException catch (exception) {
    debugPrint("[code: ${exception.code}] - ${exception.message}");
    return false;
  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}

bool checkUsernameFormat(String username) {
  final str = RegExp("[a-zA-Z0-9_]{3,}").stringMatch(username);
  return username == str;
}

Future<bool> canUserManage() async {
  try {
    final userAuth = FirebaseAuth.instance.currentUser;

    if (userAuth == null) {
      return false;
    }

    final user = await FirebaseFirestore.instance
        .collection('users')
        .doc(userAuth.uid)
        .get();

    if (user == null) {
      return false;
    }

    final bool canManage = user.data()['rights']['user:managequotidian'];
    return canManage;
  } on FirebaseFunctionsException catch (exception) {
    debugPrint("[code: ${exception.code}] - ${exception.message}");
    return false;
  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}

Future<UpdateEmailResp> deleteAccount(String idToken) async {
  try {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'europe-west3',
    ).httpsCallable(
      'users-deleteAccount',
    );

    final response = await callable.call({
      'idToken': idToken,
    });

    return UpdateEmailResp.fromJSON(response.data);
  } on FirebaseFunctionsException catch (exception) {
    debugPrint("[code: ${exception.code}] - ${exception.message}");

    return UpdateEmailResp(
      success: false,
      error: CloudFuncError(
        code: exception.details['code'],
        message: exception.details['message'],
      ),
    );
  } on PlatformException catch (exception) {
    debugPrint(exception.toString());

    return UpdateEmailResp(
      success: false,
      error: CloudFuncError(
        code: exception.details['code'],
        message: exception.details['message'],
      ),
    );
  } catch (error) {
    debugPrint(error.toString());

    return UpdateEmailResp(
      success: false,
      error: CloudFuncError(
        code: '',
        message: error.toString(),
      ),
    );
  }
}

Future<UpdateEmailResp> updateEmail(String email, String idToken) async {
  try {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'europe-west3',
    ).httpsCallable(
      'users-updateEmail',
    );

    final response = await callable.call({
      'newEmail': email,
      'idToken': idToken,
    });

    appStorage.setEmail(email);
    await userSignin();

    return UpdateEmailResp.fromJSON(response.data);
  } on FirebaseFunctionsException catch (exception) {
    debugPrint("[code: ${exception.code}] - ${exception.message}");
    return UpdateEmailResp(
      success: false,
      error: CloudFuncError(
        code: exception.details['code'],
        message: exception.details['message'],
      ),
    );
  } on PlatformException catch (exception) {
    debugPrint(exception.toString());
    return UpdateEmailResp(
      success: false,
      error: CloudFuncError(
        code: exception.details['code'],
        message: exception.details['message'],
      ),
    );
  } catch (error) {
    debugPrint(error.toString());

    return UpdateEmailResp(
      success: false,
      error: CloudFuncError(
        code: '',
        message: error.toString(),
      ),
    );
  }
}

Future<UpdateEmailResp> updateUsername(String newUsername) async {
  try {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'europe-west3',
    ).httpsCallable(
      'users-updateUsername',
    );

    final response = await callable.call({
      'newUsername': newUsername,
    });

    return UpdateEmailResp.fromJSON(response.data);
  } on FirebaseFunctionsException catch (exception) {
    debugPrint("[code: ${exception.code}] - ${exception.message}");
    return UpdateEmailResp(
      success: false,
      error: CloudFuncError(
        code: exception.details['code'],
        message: exception.details['message'],
      ),
    );
  } on PlatformException catch (exception) {
    debugPrint(exception.toString());

    return UpdateEmailResp(
      success: false,
      error: CloudFuncError(
        code: exception.details['code'],
        message: exception.details['message'],
      ),
    );
  } catch (error) {
    debugPrint(error.toString());

    return UpdateEmailResp(
      success: false,
      error: CloudFuncError(
        code: '',
        message: error.toString(),
      ),
    );
  }
}

Future<UserCredential> userSignin({String email, String password}) async {
  final credentials = appStorage.getCredentials();

  email = email == null ? credentials['email'] : email;
  password = password == null ? credentials['password'] : password;

  if ((email == null || email.isEmpty) ||
      (password == null || password.isEmpty)) {
    return null;
  }

  final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  if (userCred.user == null) {
    return null;
  }

  appStorage.setUserName(userCred.user.displayName);
  await userGetAndSetAvatarUrl(userCred);
  // PushNotifications.linkAuthUser(userCred.user.uid);

  stateUser.setUserConnected();
  stateUser.setUserName(userCred.user.displayName);

  return userCred;
}

void userSignOut({
  BuildContext context,
  bool autoNavigateAfter = true,
}) async {
  await appStorage.clearUserAuthData();
  await stateUser.signOut();

  // PushNotifications.unlinkAuthUser();

  if (autoNavigateAfter) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => Home()),
    );
  }
}

Future userGetAndSetAvatarUrl(UserCredential authResult) async {
  final user = await FirebaseFirestore.instance
      .collection('users')
      .doc(authResult.user.uid)
      .get();

  final data = user.data;
  final avatarUrl = data()['urls']['image'];

  String imageName = avatarUrl.replaceFirst('local:', '');
  String path = 'assets/images/$imageName-${stateColors.iconExt}.png';

  stateUser.setAvatarUrl(path);
}
