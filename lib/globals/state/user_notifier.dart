import 'package:artbooking/actions/users.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/cloud_functions/cloud_functions_error.dart';
import 'package:artbooking/types/cloud_functions/cloud_functions_response.dart';
import 'package:artbooking/types/cloud_functions/create_account_response.dart';
import 'package:artbooking/types/dialog_return_value.dart';
import 'package:artbooking/types/user/user.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserNotifier extends StateNotifier<User> {
  UserNotifier(User state) : super(state) {
    _listenToAuthChanges();
    _listenToFirestoreChanges();
  }

  Future<CloudFunctionsResponse> deleteAccount(String idToken) async {
    try {
      final callable = FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'europe-west3',
      ).httpsCallable('users-deleteAccount');

      final response = await callable.call({
        'idToken': idToken,
      });

      signOut();

      return CloudFunctionsResponse.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      Utilities.logger.e("[code: ${exception.code}] - ${exception.message}");

      return CloudFunctionsResponse(
        success: false,
        error: CloudFunctionsError(
          code: exception.details['code'],
          message: exception.details['message'],
        ),
      );
    } catch (error) {
      Utilities.logger.e(error);

      return CloudFunctionsResponse(
        success: false,
        error: CloudFunctionsError(
          code: '',
          message: error.toString(),
        ),
      );
    }
  }

  String getInitialsUsername() {
    final UserFirestore? firestoreUser = state.firestoreUser;
    if (firestoreUser == null) return '';

    final splittedUsernameArray = firestoreUser.name.split(' ');
    if (splittedUsernameArray.isEmpty) return '';

    String initials = splittedUsernameArray.length > 1
        ? splittedUsernameArray.reduce(
            (prevValue, currValue) => prevValue + currValue.substring(1))
        : splittedUsernameArray.first;

    if (initials.isNotEmpty) {
      initials = initials.substring(0, 1);
    }

    return initials;
  }

  String getPPUrl({String orElse = ''}) {
    final UserFirestore? firestoreUser = state.firestoreUser;
    if (firestoreUser == null) return orElse;

    final editedURL = firestoreUser.profilePicture.url.edited;
    if (editedURL.isNotEmpty) return editedURL;

    final originalURL = firestoreUser.profilePicture.url.original;
    if (originalURL.isNotEmpty) return originalURL;

    return orElse;
  }

  /// Return true if an user is currently authenticated.
  bool get isAuthenticated =>
      state.authUser != null && state.firestoreUser != null;

  void _listenToAuthChanges() {
    final firebaseAuthInstance = firebase_auth.FirebaseAuth.instance;

    firebaseAuthInstance.userChanges().listen(
          _onAuthData,
          onError: _onAuthError,
          onDone: _onAuthDone,
        );
  }

  void _listenToFirestoreChanges() async {
    final authUser = state.authUser;

    if (authUser == null) {
      return;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(authUser.uid)
        .snapshots()
        .listen(
          _onFirestoreData,
          onError: _onFirestoreError,
          onDone: _onFirestoreDone,
        );
  }

  void _onAuthData(firebase_auth.User? userEvent) {
    state = User(
      authUser: userEvent,
      firestoreUser: state.firestoreUser ?? UserFirestore.empty(),
    );
  }

  void _onAuthDone() {
    state = User(
      authUser: null,
      firestoreUser: state.firestoreUser,
    );
  }

  void _onAuthError(error) {
    Utilities.logger.e(error);
  }

  void _onFirestoreData(DocumentSnapshot<Map<String, dynamic>> docSnap) {
    final userData = docSnap.data();
    if (userData == null) return;

    userData.putIfAbsent('id', () => docSnap.id);
    final firestoreUser = UserFirestore.fromMap(userData);

    state = User(
      authUser: state.authUser,
      firestoreUser: firestoreUser,
    );
  }

  void _onFirestoreDone() {
    state = User(
      authUser: state.authUser,
      firestoreUser: null,
    );
  }

  void _onFirestoreError(error) {
    Utilities.logger.e(error);
  }

  Future<firebase_auth.User?> signIn({String? email, String? password}) async {
    try {
      final credentialsMap = Utilities.storage.getCredentials();

      email = email ?? credentialsMap['email'];
      password = password ?? credentialsMap['password'];

      final bool emailNullOrEmpty = email == null || email.isEmpty;
      final bool passwordNullOrEmpty = password == null || password.isEmpty;

      if (emailNullOrEmpty || passwordNullOrEmpty) {
        return null;
      }

      final firebaseAuthInstance = firebase_auth.FirebaseAuth.instance;
      final authResult = await firebaseAuthInstance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      state = User(authUser: authResult.user);

      _listenToAuthChanges();
      _listenToFirestoreChanges();

      Utilities.storage.setCredentials(
        email: email,
        password: password,
      );

      return authResult.user;
    } catch (error) {
      Utilities.logger.e(error);
      Utilities.storage.clearUserAuthData();
      return null;
    }
  }

  /// Automatically sign in the user with the last saved credentials.
  Future<void> signInOnAppStart() async {
    try {
      final userCred = await signIn();

      if (userCred == null) {
        signOut();
      }
    } catch (error) {
      Utilities.logger.e(error);
      signOut();
    }
  }

  Future<bool> signOut() async {
    try {
      await Utilities.storage.clearUserAuthData();
      await firebase_auth.FirebaseAuth.instance.signOut();
      state = User();
      return true;
    } catch (error) {
      Utilities.logger.e(error);
      return false;
    }
  }

  Future<CreateAccountResponse> signUp({
    required email,
    required username,
    required password,
  }) async {
    final createAccountResponse = await UsersActions.createAccount(
      email: email,
      username: username,
      password: password,
    );

    if (!createAccountResponse.success) {
      return createAccountResponse;
    }

    final userAuth = await signIn(email: email, password: password);
    createAccountResponse.userAuth = userAuth;
    createAccountResponse.success = userAuth != null;

    return createAccountResponse;
  }

  Future<CloudFunctionsResponse> updateEmail({
    required String password,
    required String newEmail,
  }) async {
    final authUser = state.authUser;

    try {
      if (authUser == null) {
        throw ErrorDescription(
          "User authentication is null. Maybe you're not authenticated.",
        );
      }

      final credentials = firebase_auth.EmailAuthProvider.credential(
        email: authUser.email ?? '',
        password: password,
      );

      await authUser.reauthenticateWithCredential(credentials);
      final idToken = await authUser.getIdToken();

      final response = await Utilities.cloud.fun('users-updateEmail').call({
        'newEmail': authUser.email,
        'idToken': idToken,
      });

      await signIn(email: authUser.email);

      return CloudFunctionsResponse.fromJSON(response.data);
    } catch (error) {
      return CloudFunctionsResponse(
        success: false,
        error: CloudFunctionsError(
          code: '',
          message: error.toString(),
        ),
      );
    }
  }

  Future<DialogReturnValue<String>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final authUser = state.authUser;

    try {
      if (authUser == null) {
        throw ErrorDescription(
          "User authentication is null. Maybe you're not authenticated.",
        );
      }

      final credentials = firebase_auth.EmailAuthProvider.credential(
        email: authUser.email ?? '',
        password: currentPassword,
      );

      final authResult =
          await authUser.reauthenticateWithCredential(credentials);

      if (authResult.user == null) {
        throw ErrorDescription(
          "You entered a wrong password or the user doesn't exist anymore.",
        );
      }

      await authResult.user?.updatePassword(newPassword);
      Utilities.storage.setPassword(newPassword);

      return DialogReturnValue(validated: true, value: '');
    } catch (error) {
      Utilities.logger.e(error);
      return DialogReturnValue(validated: false, value: error.toString());
    }
  }

  Future<CloudFunctionsResponse> updateUsername(String newUsername) async {
    try {
      final response = await Utilities.cloud.fun('users-updateUsername').call({
        'newUsername': newUsername,
      });

      return CloudFunctionsResponse.fromJSON(response.data);
    } catch (error) {
      return CloudFunctionsResponse(
        success: false,
        error: CloudFunctionsError(
          code: '',
          message: error.toString(),
        ),
      );
    }
  }
}
