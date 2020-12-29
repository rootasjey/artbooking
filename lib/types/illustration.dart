import 'package:artbooking/types/author.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/types/image_version.dart';
import 'package:artbooking/types/urls.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Illustration {
  Author author;
  DateTime createdAt;
  String description;
  String id;
  String name;
  bool private;
  DateTime updatedAt;
  Urls urls;
  List<ImageVersion> versions;
  ImageVisibility visibility;

  Illustration({
    this.author,
    this.createdAt,
    this.description = '',
    this.id = '',
    this.private,
    this.name = '',
    this.updatedAt,
    this.urls,
    this.versions = const [],
    this.visibility,
  });

  factory Illustration.fromJSON(Map<String, dynamic> json) {
    ImageVisibility imageVisibility;

    switch (json['visibility']) {
      case 'acl':
        imageVisibility = ImageVisibility.acl;
        break;
      case 'challenge':
        imageVisibility = ImageVisibility.challenge;
        break;
      case 'contest':
        imageVisibility = ImageVisibility.contest;
        break;
      case 'gallery':
        imageVisibility = ImageVisibility.gallery;
        break;
      case 'private':
        imageVisibility = ImageVisibility.private;
        break;
      case 'public':
        imageVisibility = ImageVisibility.public;
        break;
      default:
        imageVisibility = ImageVisibility.private;
    }

    return Illustration(
      author: Author(id: json['author']['id']),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      description: json['description'],
      id: json['id'],
      name: json['name'],
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      urls: Urls.fromJSON(json['urls']),
      versions: [],
      visibility: imageVisibility,
    );
  }

  String getThumbnail() {
    return urls.thumbnails.t512 ?? urls.thumbnails.t1024 ?? urls.original;
  }
}
