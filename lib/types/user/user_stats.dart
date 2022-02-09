import 'dart:convert';

import 'package:artbooking/types/user/user_book_stats.dart';
import 'package:artbooking/types/user/user_challenges_stats.dart';
import 'package:artbooking/types/user/user_contest_stats.dart';
import 'package:artbooking/types/user/user_gallery_stats.dart';
import 'package:artbooking/types/user/user_illustration_stats.dart';
import 'package:artbooking/types/user/user_notification_stats.dart';
import 'package:artbooking/types/user/user_storage_stats.dart';

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

  UserBookStats books;
  UserChallengeStats challenges;
  UserContestStats constests;
  UserGalleryStats galleries;
  UserIllustrationStats illustrations;
  UserNotificationStats notifications;
  UserStorageStats storage;

  UserStats copyWith({
    UserBookStats? books,
    UserChallengeStats? challenges,
    UserContestStats? constests,
    UserGalleryStats? galleries,
    UserIllustrationStats? illustrations,
    UserNotificationStats? notifications,
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
      books: UserBookStats.empty(),
      challenges: UserChallengeStats.empty(),
      constests: UserContestStats.empty(),
      galleries: UserGalleryStats.empty(),
      illustrations: UserIllustrationStats.empty(),
      notifications: UserNotificationStats.empty(),
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
      books: UserBookStats.fromMap(map['books']),
      challenges: UserChallengeStats.fromMap(map['challenges']),
      constests: UserContestStats.fromMap(map['constests']),
      galleries: UserGalleryStats.fromMap(map['galleries']),
      illustrations: UserIllustrationStats.fromMap(map['illustrations']),
      notifications: UserNotificationStats.fromMap(map['notifications']),
      storage: UserStorageStats.fromMap(map['storage']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserStats.fromJson(String source) =>
      UserStats.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserStats(books: $books, challenges: $challenges, '
        'constests: $constests, galleries: $galleries, '
        'illustrations: $illustrations, notifications: $notifications, '
        'storage: $storage)';
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
