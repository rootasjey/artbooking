import 'dart:convert';
import 'dart:math';

import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/user/profile_picture.dart';
import 'package:artbooking/types/user/settings.dart';
import 'package:artbooking/types/user/stats.dart';
import 'package:artbooking/types/user/user_rights.dart';
import 'package:artbooking/types/user/user_urls.dart';

class UserFirestore {
  UserFirestore({
    this.createdAt,
    this.email = '',
    required this.id,
    this.job = '',
    this.location = '',
    this.lang = 'en',
    this.name = '',
    this.nameLowerCase = '',
    required this.profilePicture,
    this.pricing = 'free',
    required this.settings,
    required this.stats,
    this.summary = '',
    this.uid = '',
    this.updatedAt,
    required this.urls,
    required this.rights,
  });

  DateTime? createdAt;
  String email;
  final String id;
  String job;
  String lang;
  String location;
  String name;
  String nameLowerCase;
  final ProfilePicture profilePicture;
  String pricing;
  UserSettings settings;
  UserStats stats;
  String summary;
  String uid;
  DateTime? updatedAt;
  UserUrls urls;
  UserRights rights;

  UserFirestore copyWith({
    DateTime? createdAt,
    String? email,
    String? id,
    String? job,
    String? lang,
    String? location,
    String? name,
    String? nameLowerCase,
    ProfilePicture? profilePicture,
    String? pricing,
    UserSettings? settings,
    UserStats? stats,
    String? summary,
    String? uid,
    DateTime? updatedAt,
    UserUrls? urls,
    UserRights? rights,
  }) {
    return UserFirestore(
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email,
      id: id ?? this.id,
      job: job ?? this.job,
      lang: lang ?? this.lang,
      location: location ?? this.location,
      name: name ?? this.name,
      nameLowerCase: nameLowerCase ?? this.nameLowerCase,
      profilePicture: profilePicture ?? this.profilePicture,
      pricing: pricing ?? this.pricing,
      settings: settings ?? this.settings,
      stats: stats ?? this.stats,
      summary: summary ?? this.summary,
      uid: uid ?? this.uid,
      updatedAt: updatedAt ?? this.updatedAt,
      urls: urls ?? this.urls,
      rights: rights ?? this.rights,
    );
  }

  static const List<String> _sampleAvatars = [
    "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Favatar_female.png?alt=media&token=24de34ec-71a6-44d0-8324-50c77e848dee",
    "https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/static%2Fimages%2Favatar_male.png?alt=media&token=326302d9-912d-4923-9bec-94c6bb9892ae",
  ];

  Map<String, dynamic> toMap({bool withAllFields = false}) {
    Map<String, dynamic> map = Map();

    if (withAllFields) {
      map['email'] = email;
      map['name'] = name;
      map['nameLowerCase'] = nameLowerCase;
    }

    map['job'] = job;
    map['lang'] = lang;
    map['location'] = location;
    map['profilePicture'] = profilePicture.toMap();
    map['pricing'] = pricing;
    map['summary'] = summary;
    map['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
    map['urls'] = urls.toMap();
    map['rights'] = rights.toMap();

    return map;
  }

  factory UserFirestore.empty() {
    return UserFirestore(
      createdAt: DateTime.now(),
      email: 'anonymous@rootasjey.dev',
      id: '',
      job: 'Ghosting',
      lang: 'en',
      location: 'Nowhere',
      name: 'Anonymous',
      nameLowerCase: 'anonymous',
      profilePicture: ProfilePicture.empty(),
      pricing: 'free',
      settings: UserSettings.empty(),
      summary: 'An anonymous user ghosting decent people.',
      stats: UserStats.empty(),
      updatedAt: DateTime.now(),
      urls: UserUrls.empty(),
      rights: UserRights(),
    );
  }

  factory UserFirestore.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserFirestore.empty();
    }

    return UserFirestore(
      createdAt: Utilities.date.fromFirestore(map['createdAt']),
      email: map['email'] ?? '',
      id: map['id'] ?? '',
      job: map['job'] ?? '',
      lang: map['lang'] ?? '',
      location: map['location'] ?? '',
      name: map['name'] ?? '',
      nameLowerCase: map['nameLowerCase'] ?? '',
      profilePicture: ProfilePicture.fromMap(map['profilePicture']),
      pricing: map['pricing'] ?? '',
      settings: UserSettings.fromMap(map['settings']),
      stats: UserStats.fromMap(map['stats']),
      summary: map['summary'] ?? '',
      uid: map['uid'] ?? '',
      updatedAt: Utilities.date.fromFirestore(map['updatedAt']),
      urls: UserUrls.fromMap(map['urls']),
      rights: UserRights.fromMap(map['rights']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserFirestore.fromJson(String source) =>
      UserFirestore.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserFirestore(createdAt: $createdAt, email: $email,'
        ' id: $id, job: $job, lang: $lang, location: $location, '
        'name: $name, nameLowerCase: $nameLowerCase, '
        'profilePicture: $profilePicture, pricing: $pricing, '
        'settings: $settings, stats: $stats, summary: $summary, uid: $uid, '
        'updatedAt: $updatedAt, urls: $urls, rights: $rights)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserFirestore &&
        other.createdAt == createdAt &&
        other.email == email &&
        other.id == id &&
        other.job == job &&
        other.lang == lang &&
        other.location == location &&
        other.name == name &&
        other.nameLowerCase == nameLowerCase &&
        other.profilePicture == profilePicture &&
        other.pricing == pricing &&
        other.settings == settings &&
        other.stats == stats &&
        other.summary == summary &&
        other.uid == uid &&
        other.updatedAt == updatedAt &&
        other.urls == urls &&
        other.rights == rights;
  }

  @override
  int get hashCode {
    return createdAt.hashCode ^
        email.hashCode ^
        id.hashCode ^
        job.hashCode ^
        lang.hashCode ^
        location.hashCode ^
        name.hashCode ^
        nameLowerCase.hashCode ^
        profilePicture.hashCode ^
        pricing.hashCode ^
        settings.hashCode ^
        stats.hashCode ^
        summary.hashCode ^
        uid.hashCode ^
        updatedAt.hashCode ^
        urls.hashCode ^
        rights.hashCode;
  }

  /// Return user's profile picture if any.
  /// If [placeholder] is `true`, the method will return
  /// a default picture if the user hasn't set one.
  String getProfilePicture() {
    final edited = profilePicture.url.edited;
    final original = profilePicture.url.original;
    final defaultUrl =
        _sampleAvatars.elementAt(Random().nextInt(_sampleAvatars.length));

    if (edited.isNotEmpty) {
      return edited;
    }

    if (original.isNotEmpty) {
      return original;
    }

    return defaultUrl;
  }
}
