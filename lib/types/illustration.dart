import 'package:artbooking/types/author.dart';
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

  Illustration({
    this.author,
    this.createdAt,
    this.description = '',
    this.id = '',
    this.private,
    this.name = '',
    this.updatedAt,
    this.urls,
  });

  factory Illustration.fromJSON(Map<String, dynamic> json) {
    return Illustration(
      author      : Author(id: json['author']['id']),
      createdAt   : (json['createdAt'] as Timestamp).toDate(),
      description : json['description'],
      id          : json['id'],
      private   : json['isPrivate'],
      name        : json['name'],
      updatedAt   : (json['updatedAt'] as Timestamp).toDate(),
      urls        : Urls.fromJSON(json['urls']),
    );
  }
}

