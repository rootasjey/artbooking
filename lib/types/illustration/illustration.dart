import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/acl.dart';
import 'package:artbooking/types/author.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/illustration/dimensions.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:artbooking/types/illustration/stats.dart';
import 'package:artbooking/types/illustration/version.dart';
import 'package:artbooking/types/illustration/urls.dart';

class Illustration {
  Illustration({
    this.acl = const [],
    required this.author,
    this.styles = const [],
    required this.createdAt,
    this.description = '',
    this.dimensions,
    this.extension = '',
    this.hasPendingCreates = false,
    this.id = '',
    required this.license,
    this.name = '',
    this.stats,
    this.size = 0,
    this.story = '',
    this.topics = const [],
    this.updatedAt,
    required this.urls,
    this.versions = const [],
    this.visibility = EnumContentVisibility.private,
  });

  /// Access Control List managing this illustration visibility to others users.
  List<ACL> acl;

  /// Author's illustration.
  final Author author;

  /// The time this illustration has been created.
  final DateTime createdAt;

  /// This illustration's description.
  String description;

  /// This Illustration's dimensions.
  Dimensions? dimensions;

  /// File's extension.
  String extension;

  /// True if this document is being created.
  /// Illustration creation has 3 steps:
  ///   1. Firestore document creation with an id.
  ///   2. File upload to Firebase Cloud Storage.
  ///   3. (Update) Populate Firestore document with new properties (& urls).
  final bool hasPendingCreates;

  /// Firestore id.
  String id;

  /// Specifies how this illustration can be used.
  License license;

  /// This illustration's name.
  String name;

  /// Detailed text explaining more about this illustration.
  String story;

  /// Cloud Storage file's size in bytes.
  final int size;

  /// Downloads, favourites, shares, views... of this illustration.
  IllustrationStats? stats;

  /// Art style (e.g. pointillism, realism) — Limited to 5.
  List<String> styles;

  /// Arbitrary subjects (e.g. video games, movies) — Limited to 5.
  List<String> topics;

  /// Last time this illustration was updated.
  final DateTime? updatedAt;

  /// This illustration's urls.
  Urls urls;

  /// All available file versions of this illusration.
  List<IllustrationVersion> versions;

  /// Access control policy.
  /// Define who can read or write this illustration.
  EnumContentVisibility visibility;

  factory Illustration.empty() {
    return Illustration(
      acl: const [],
      author: Author.empty(),
      styles: const [],
      createdAt: DateTime.now(),
      description: '',
      dimensions: Dimensions.empty(),
      extension: '',
      hasPendingCreates: false,
      id: '',
      license: License.empty(),
      name: '',
      stats: IllustrationStats.empty(),
      size: 0,
      story: '',
      topics: const [],
      updatedAt: DateTime.now(),
      urls: Urls.empty(),
      versions: const [],
      visibility: EnumContentVisibility.private,
    );
  }

  factory Illustration.fromJSON(Map<String, dynamic> data) {
    return Illustration(
      author: Author.fromJSON(data['user']),
      styles: parseStyles(data['styles']),
      createdAt: Utilities.date.fromFirestore(data['createdAt']),
      description: data['description'] ?? '',
      dimensions: Dimensions.fromJSON(data['dimensions']),
      extension: data['extension'] ?? '',
      hasPendingCreates: data['hasPendingCreates'] ?? false,
      id: data['id'] ?? '',
      license: License.fromJSON(data['license']),
      name: data['name'] ?? '',
      stats: IllustrationStats.fromJSON(data['stats']),
      size: data['size'] ?? 0,
      story: data['story'] ?? '',
      topics: parseTopics(data['topics']),
      updatedAt: Utilities.date.fromFirestore(data['updatedAt']),
      urls: Urls.fromJSON(data['urls']),
      versions: [],
      visibility: parseVisibility(data['visibility']),
    );
  }

  String getHDThumbnail() {
    final t720 = urls.thumbnails.t720;
    if (t720.isNotEmpty) {
      return t720;
    }

    final t1080 = urls.thumbnails.t1080;
    if (t1080.isNotEmpty) {
      return t1080;
    }

    return urls.original;
  }

  String getThumbnail() {
    final t360 = urls.thumbnails.t360;
    if (t360.isNotEmpty) {
      return t360;
    }

    final t480 = urls.thumbnails.t480;
    if (t480.isNotEmpty) {
      return t480;
    }

    final t720 = urls.thumbnails.t720;
    if (t720.isNotEmpty) {
      return t720;
    }

    final t1080 = urls.thumbnails.t1080;
    if (t1080.isNotEmpty) {
      return t1080;
    }

    return urls.original;
  }

  static List<String> parseStyles(Map<String, dynamic>? data) {
    final results = <String>[];

    if (data == null) {
      return results;
    }

    data.forEach((key, value) {
      results.add(key);
    });

    return results;
  }

  static List<String> parseTopics(data) {
    final results = <String>[];

    if (data == null) {
      return results;
    }

    data.forEach((key, value) {
      results.add(key);
    });

    return results;
  }

  static EnumContentVisibility parseVisibility(String? stringVisiblity) {
    switch (stringVisiblity) {
      case 'acl':
        return EnumContentVisibility.acl;
      case 'private':
        return EnumContentVisibility.private;
      case 'public':
        return EnumContentVisibility.public;
      default:
        return EnumContentVisibility.private;
    }
  }

  String visibilityToString() {
    switch (visibility) {
      case EnumContentVisibility.acl:
        return 'acl';
      case EnumContentVisibility.private:
        return 'private';
      case EnumContentVisibility.public:
        return 'public';
      default:
        return 'private';
    }
  }

  static String visibilityPropToString(EnumContentVisibility visibility) {
    switch (visibility) {
      case EnumContentVisibility.acl:
        return 'acl';
      case EnumContentVisibility.private:
        return 'private';
      case EnumContentVisibility.public:
        return 'public';
      default:
        return 'private';
    }
  }
}
