import 'package:artbooking/types/user/stats.dart';
import 'package:artbooking/types/user/settings.dart';
import 'package:artbooking/types/user/urls.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserFirestore {
  DateTime createdAt;
  String email;
  String lang;
  String name;
  String nameLowerCase;
  String pricing;
  UserSettings settings;
  UserStats stats;
  String uid;
  DateTime updatedAt;
  UserUrls urls;

  UserFirestore({
    this.createdAt,
    this.email = '',
    this.lang = 'en',
    this.name = '',
    this.nameLowerCase = '',
    this.pricing = 'free',
    this.settings,
    this.stats,
    this.uid,
    this.updatedAt,
    this.urls,
  });

  factory UserFirestore.fromJSON(Map<String, dynamic> data) {
    return UserFirestore(
      createdAt: (data['createdAt'] as Timestamp)?.toDate(),
      email: data['email'],
      lang: data['lang'],
      name: data['name'],
      nameLowerCase: data['nameLowerCase'],
      pricing: data['pricing'],
      settings: UserSettings.fromJSON(data['settings']),
      stats: UserStats.fromJSON(data['stats']),
      uid: data['uid'],
      updatedAt: (data['updatedAt'] as Timestamp)?.toDate(),
      urls: UserUrls.fromJSON(data['urls']),
    );
  }
}
