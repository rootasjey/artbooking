import 'package:artbooking/types/user/user_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';

part 'user.g.dart';

class StateUser = StateUserBase with _$StateUser;

abstract class StateUserBase with Store {
  UserFirestore userFirestore;

  @observable
  String avatarUrl = '';

  @observable
  String lang = 'en';

  @observable
  bool isFirstLaunch = false;

  @observable
  bool isUserConnected = false;

  @observable
  String username = '';

  /// Used to sync fav. status between views,
  /// e.g. re-fetch on nav. back from quote page -> quotes list.
  /// _NOTE: Should be set to false after status sync (usually on quotes list)_.
  bool mustUpdateFav = false;

  /// Last time the favourites has been updated.
  @observable
  DateTime updatedFavAt = DateTime.now();

  @action
  void setAvatarUrl(String url) {
    avatarUrl = url;
  }

  @action
  void setFirstLaunch(bool value) {
    isFirstLaunch = value;
  }

  @action
  void setLang(String newLang) {
    lang = newLang;
  }

  @action
  void setUserConnected() {
    isUserConnected = true;
  }

  @action
  void setUserDisconnected() {
    isUserConnected = false;
  }

  @action
  void setUserName(String name) {
    username = name;
  }

  Future fetchFirestore(String id) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(id).get();

    final userData = userDoc.data();
    userFirestore = UserFirestore.fromJSON(userData);
  }

  @action
  Future signOut() async {
    await FirebaseAuth.instance.signOut();
    setUserDisconnected();
  }

  @action
  void updateFavDate() {
    updatedFavAt = DateTime.now();
  }
}

final stateUser = StateUser();
