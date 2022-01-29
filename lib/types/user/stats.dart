import 'package:artbooking/types/user/book_stats.dart';
import 'package:artbooking/types/user/challenges_stats.dart';
import 'package:artbooking/types/user/contests_stats.dart';
import 'package:artbooking/types/user/galleries_stats.dart';
import 'package:artbooking/types/user/illustrations_stats.dart';
import 'package:artbooking/types/user/notifications_stats.dart';
import 'package:artbooking/types/user/storage_stats.dart';

class UserStats {
  UserBooksStats books;
  UserChallengesStats challenges;
  UserContestsStats constests;
  UserGalleriesStats galleries;
  UserIllustrationsStats illustrations;
  UserNotificationsStats notifications;
  UserStorageStats storage;

  UserStats({
    required this.books,
    required this.challenges,
    required this.constests,
    required this.galleries,
    required this.illustrations,
    required this.notifications,
    required this.storage,
  });

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

  factory UserStats.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return UserStats.empty();
    }

    return UserStats(
      books: UserBooksStats.fromJSON(data['books']),
      challenges: UserChallengesStats.fromJSON(data['challenges']),
      constests: UserContestsStats.fromJSON(data['contests']),
      galleries: UserGalleriesStats.fromJSON(data['galleries']),
      illustrations: UserIllustrationsStats.fromJSON(data['illustrations']),
      notifications: UserNotificationsStats.fromJSON(data['notifications']),
      storage: UserStorageStats.fromJSON(data['storage']),
    );
  }
}
