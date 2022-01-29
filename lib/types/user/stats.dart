import 'dart:convert';

import 'package:artbooking/types/user/book_stats.dart';
import 'package:artbooking/types/user/challenges_stats.dart';
import 'package:artbooking/types/user/contests_stats.dart';
import 'package:artbooking/types/user/galleries_stats.dart';
import 'package:artbooking/types/user/illustrations_stats.dart';
import 'package:artbooking/types/user/notifications_stats.dart';
import 'package:artbooking/types/user/storage_stats.dart';

class UserStats {
  UserStats({
    required this.books,
    required this.challenges,
    required this.constests,
    required this.galleries,
    required this.illustrations,
    required this.notifications,
    required this.storage,
  });

  UserBooksStats books;
  UserChallengesStats challenges;
  UserContestsStats constests;
  UserGalleriesStats galleries;
  UserIllustrationsStats illustrations;
  UserNotificationsStats notifications;
  UserStorageStats storage;

  UserStats copyWith({
    UserBooksStats? books,
    UserChallengesStats? challenges,
    UserContestsStats? constests,
    UserGalleriesStats? galleries,
    UserIllustrationsStats? illustrations,
    UserNotificationsStats? notifications,
    UserStorageStats? storage,
  }) {
    return UserStats(
      books: books ?? this.books,
      challenges: challenges ?? this.challenges,
      constests: constests ?? this.constests,
      galleries: galleries ?? this.galleries,
      illustrations: illustrations ?? this.illustrations,
      notifications: notifications ?? this.notifications,
      storage: storage ?? this.storage,
    );
  }

  factory UserStats.empty() {
    return UserStats(
      books: UserBooksStats.empty(),
      challenges: UserChallengesStats.empty(),
      constests: UserContestsStats.empty(),
      galleries: UserGalleriesStats.empty(),
      illustrations: UserIllustrationsStats.empty(),
      notifications: UserNotificationsStats.empty(),
      storage: UserStorageStats.empty(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'books': books.toMap(),
      'challenges': challenges.toMap(),
      'constests': constests.toMap(),
      'galleries': galleries.toMap(),
      'illustrations': illustrations.toMap(),
      'notifications': notifications.toMap(),
      'storage': storage.toMap(),
    };
  }

  factory UserStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserStats.empty();
    }

    return UserStats(
      books: UserBooksStats.fromMap(map['books']),
      challenges: UserChallengesStats.fromMap(map['challenges']),
      constests: UserContestsStats.fromMap(map['constests']),
      galleries: UserGalleriesStats.fromMap(map['galleries']),
      illustrations: UserIllustrationsStats.fromMap(map['illustrations']),
      notifications: UserNotificationsStats.fromMap(map['notifications']),
      storage: UserStorageStats.fromMap(map['storage']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserStats.fromJson(String source) =>
      UserStats.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserStats(books: $books, challenges: $challenges, constests: $constests, galleries: $galleries, illustrations: $illustrations, notifications: $notifications, storage: $storage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserStats &&
        other.books == books &&
        other.challenges == challenges &&
        other.constests == constests &&
        other.galleries == galleries &&
        other.illustrations == illustrations &&
        other.notifications == notifications &&
        other.storage == storage;
  }

  @override
  int get hashCode {
    return books.hashCode ^
        challenges.hashCode ^
        constests.hashCode ^
        galleries.hashCode ^
        illustrations.hashCode ^
        notifications.hashCode ^
        storage.hashCode;
  }
}
