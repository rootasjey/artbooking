import 'dart:convert';

import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/user/profile_picture.dart';
import 'package:artbooking/types/user/user_rights.dart';
import 'package:artbooking/types/user/user_social_links.dart';

class UserFirestore {
  const UserFirestore({
    required this.createdAt,
    required this.id,
    required this.profilePicture,
    required this.rights,
    required this.socialLinks,
    this.bio = "",
    this.email = "",
    this.job = "",
    this.location = "",
    this.language = 'en',
    this.name = "",
    this.nameLowerCase = "",
    this.pricing = "free",
    this.updatedAt,
  });

  /// When this account was created.
  final DateTime createdAt;

  /// User's email.
  final String email;

  /// Unique identifier.
  final String id;

  /// What they do for a living?.
  final String job;

  /// Default language.
  final String language;

  /// Where they live?
  final String location;

  /// User's name.
  final String name;

  /// User's name in lower case to check unicity.
  final String nameLowerCase;

  /// Profile picture.
  final ProfilePicture profilePicture;
  final String pricing;

  /// Social links (e.g. Twitch, discord, instagram, ...).
  final UserSocialLinks socialLinks;

  /// About this user.
  final String bio;

  /// Last time this account was updated (any field update).
  final DateTime? updatedAt;

  /// What this user can do?
  final UserRights rights;

  UserFirestore copyWith({
    DateTime? createdAt,
    String? email,
    String? id,
    String? job,
    String? language,
    String? location,
    String? name,
    String? nameLowerCase,
    ProfilePicture? profilePicture,
    String? pricing,
    String? bio,
    DateTime? updatedAt,
    UserSocialLinks? socialLinks,
    UserRights? rights,
  }) {
    return UserFirestore(
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email,
      id: id ?? this.id,
      job: job ?? this.job,
      language: language ?? this.language,
      location: location ?? this.location,
      socialLinks: socialLinks ?? this.socialLinks,
      name: name ?? this.name,
      nameLowerCase: nameLowerCase ?? this.nameLowerCase,
      profilePicture: profilePicture ?? this.profilePicture,
      pricing: pricing ?? this.pricing,
      rights: rights ?? this.rights,
      bio: bio ?? this.bio,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserFirestore.empty() {
    return UserFirestore(
      createdAt: DateTime.now(),
      email: "anonymous@rootasjey.dev",
      id: "",
      job: "Ghosting",
      language: "en",
      location: "Nowhere",
      name: "Anonymous",
      nameLowerCase: "anonymous",
      profilePicture: ProfilePicture.empty(),
      pricing: "free",
      bio: "An anonymous user ghosting decent people.",
      updatedAt: DateTime.now(),
      socialLinks: UserSocialLinks.empty(),
      rights: UserRights(),
    );
  }

  factory UserFirestore.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserFirestore.empty();
    }

    return UserFirestore(
      bio: map["bio"] ?? "",
      createdAt: Utilities.date.fromFirestore(map["created_at"]),
      email: map["email"] ?? "",
      id: map["id"] ?? "",
      job: map["job"] ?? "",
      language: map["language"] ?? "",
      location: map["location"] ?? "",
      socialLinks: UserSocialLinks.fromMap(map["social_links"]),
      name: map["name"] ?? "",
      nameLowerCase: map["name_lower_case"] ?? "",
      profilePicture: ProfilePicture.fromMap(map["profile_picture"]),
      pricing: map["pricing"] ?? "free",
      updatedAt: Utilities.date.fromFirestore(map["updated_at"]),
      rights: UserRights.fromMap(map["rights"]),
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap({bool withAllFields = false}) {
    Map<String, dynamic> map = Map();

    if (withAllFields) {
      map["email"] = email;
      map["name"] = name;
      map["name_lower_case"] = nameLowerCase;
    }

    map["bio"] = bio;
    map["job"] = job;
    map["language"] = language;
    map["location"] = location;
    map["social_links"] = socialLinks.toMap();
    map["profile_picture"] = profilePicture.toMap();
    map["pricing"] = pricing;
    map["updated_at"] = DateTime.now().millisecondsSinceEpoch;
    map["rights"] = rights.toMap();

    return map;
  }

  factory UserFirestore.fromJson(String source) =>
      UserFirestore.fromMap(json.decode(source));

  @override
  String toString() {
    return "UserFirestore(createdAt: $createdAt, email: $email,"
        " id: $id, job: $job, language: $language, location: $location, "
        "name: $name, nameLowerCase: $nameLowerCase, "
        "profilePicture: $profilePicture, pricing: $pricing, "
        "bio: $bio, "
        "updatedAt: $updatedAt, socialLinks: $socialLinks, rights: $rights)";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserFirestore &&
        other.createdAt == createdAt &&
        other.email == email &&
        other.id == id &&
        other.job == job &&
        other.language == language &&
        other.location == location &&
        other.name == name &&
        other.nameLowerCase == nameLowerCase &&
        other.profilePicture == profilePicture &&
        other.pricing == pricing &&
        other.bio == bio &&
        other.updatedAt == updatedAt &&
        other.socialLinks == socialLinks &&
        other.rights == rights;
  }

  @override
  int get hashCode {
    return createdAt.hashCode ^
        email.hashCode ^
        id.hashCode ^
        job.hashCode ^
        language.hashCode ^
        location.hashCode ^
        name.hashCode ^
        nameLowerCase.hashCode ^
        profilePicture.hashCode ^
        pricing.hashCode ^
        bio.hashCode ^
        updatedAt.hashCode ^
        socialLinks.hashCode ^
        rights.hashCode;
  }

  /// Return user's profile picture if any.
  /// If [placeholder] is `true`, the method will return
  /// a default picture if the user hasn't set one.
  String getProfilePicture() {
    final String edited = profilePicture.links.edited;

    if (edited.isNotEmpty) {
      return edited;
    }

    final String original = profilePicture.links.original;
    return original;
  }
}
