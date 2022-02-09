import 'dart:convert';

import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_license_type.dart';
import 'package:artbooking/types/license/license_links.dart';
import 'package:artbooking/types/license/license_terms.dart';
import 'package:artbooking/types/license/license_usage.dart';

/// Describe how an artwork can be used.
class License {
  const License({
    this.abbreviation = '',
    required this.createdAt,
    this.createdBy = '',
    this.description = '',
    required this.id,
    this.licenseUpdatedAt,
    required this.name,
    this.notice = '',
    required this.terms,
    this.type = EnumLicenseType.user,
    required this.updatedAt,
    this.updatedBy = '',
    required this.links,
    required this.usage,
    this.version = '1.0',
  });

  /// The license short name.
  final String abbreviation;

  /// When this entry was created in Firestore.
  final DateTime createdAt;

  /// User’s id who created this license.
  final String createdBy;

  /// Information about this license.
  final String description;

  /// License's id.
  final String id;

  /// License's term of service & privacy policy update.
  final DateTime? licenseUpdatedAt;

  /// License's urls.
  final LicenseLinks links;

  /// License's name.
  final String name;

  /// Additional information about this license usage.
  final String notice;

  /// Restrictions related to usage.
  final LicenseTerms terms;

  /// Tell if this license has been created by an artist
  /// or by the platform's staff.
  final EnumLicenseType type;

  /// Last time this license was updated.
  final DateTime updatedAt;

  /// Last user’s id who updated this license.
  final String updatedBy;

  /// If [custom] is true, defined what is permitted and is not.
  final LicenseUsage usage;

  /// If this license has a specific version.
  final String version;

  factory License.empty() {
    return License(
      abbreviation: '',
      createdAt: DateTime.now(),
      createdBy: '',
      description: '',
      id: '',
      licenseUpdatedAt: DateTime.now(),
      name: '',
      notice: '',
      terms: LicenseTerms.empty(),
      type: EnumLicenseType.user,
      updatedAt: DateTime.now(),
      updatedBy: '',
      links: LicenseLinks.empty(),
      usage: LicenseUsage.empty(),
      version: '',
    );
  }

  factory License.fromMap(Map<String, dynamic> data) {
    final licenseUpdatedAt = Utilities.date.fromFirestore(
      data['license_updated_at'],
    );

    return License(
      abbreviation: data['abbreviation'] ?? '',
      createdAt: Utilities.date.fromFirestore(data['created_at']),
      createdBy: data['created_by'] ?? '',
      description: data['description'] ?? '',
      id: data['id'] ?? '',
      licenseUpdatedAt: licenseUpdatedAt,
      links: LicenseLinks.fromMap(data['links']),
      name: data['name'] ?? '',
      notice: data['notice'] ?? '',
      terms: LicenseTerms.fromMap(data['terms']),
      type: convertStringToType(data['type'] ?? ''),
      updatedAt: Utilities.date.fromFirestore(data['updated_at']),
      updatedBy: data['updated_by'] ?? '',
      usage: LicenseUsage.fromMap(data['usage']),
      version: data['version'] ?? '1.0',
    );
  }

  static EnumLicenseType convertStringToType(String typeString) {
    switch (typeString) {
      case 'staff':
        return EnumLicenseType.staff;
      case 'user':
        return EnumLicenseType.user;
      default:
        return EnumLicenseType.user;
    }
  }

  String convertFromToString() {
    switch (type) {
      case EnumLicenseType.staff:
        return 'staff';
      case EnumLicenseType.user:
        return 'user';
      default:
        return 'user';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'abbreviation': abbreviation,
      'created_by': createdBy,
      'description': description,
      'type': typeToString(),
      'id': id,
      'license_updated_at': licenseUpdatedAt?.millisecondsSinceEpoch,
      'name': name,
      'notice': notice,
      'terms': terms.toMap(),
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'updated_by': updatedBy,
      'usage': usage.toMap(),
      'links': links.toMap(),
      'version': version,
    };
  }

  String typeToString() {
    return type == EnumLicenseType.staff ? 'staff' : 'user';
  }

  License copyWith({
    String? abbreviation,
    DateTime? createdAt,
    String? createdBy,
    String? description,
    EnumLicenseType? type,
    String? id,
    DateTime? licenseUpdatedAt,
    String? name,
    String? notice,
    LicenseTerms? terms,
    DateTime? updatedAt,
    String? updatedBy,
    LicenseUsage? usage,
    LicenseLinks? links,
    String? version,
  }) {
    return License(
      abbreviation: abbreviation ?? this.abbreviation,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      description: description ?? this.description,
      type: type ?? this.type,
      id: id ?? this.id,
      licenseUpdatedAt: licenseUpdatedAt ?? this.licenseUpdatedAt,
      name: name ?? this.name,
      notice: notice ?? this.notice,
      terms: terms ?? this.terms,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      usage: usage ?? this.usage,
      links: links ?? this.links,
      version: version ?? this.version,
    );
  }

  String toJson() => json.encode(toMap());

  factory License.fromJson(String source) =>
      License.fromMap(json.decode(source));

  @override
  String toString() {
    return 'License(abbreviation: $abbreviation, createdAt: $createdAt, '
        'createdBy: $createdBy, description: $description, type: $type, id: $id, '
        'licenseUpdatedAt: $licenseUpdatedAt, name: $name, notice: $notice, '
        'terms: $terms, updatedAt: $updatedAt, updatedBy: $updatedBy, '
        'usage: $usage, links: $links, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is License &&
        other.abbreviation == abbreviation &&
        other.createdAt == createdAt &&
        other.createdBy == createdBy &&
        other.description == description &&
        other.type == type &&
        other.id == id &&
        other.licenseUpdatedAt == licenseUpdatedAt &&
        other.name == name &&
        other.notice == notice &&
        other.terms == terms &&
        other.updatedAt == updatedAt &&
        other.updatedBy == updatedBy &&
        other.usage == usage &&
        other.links == links &&
        other.version == version;
  }

  @override
  int get hashCode {
    return abbreviation.hashCode ^
        createdAt.hashCode ^
        createdBy.hashCode ^
        description.hashCode ^
        type.hashCode ^
        id.hashCode ^
        licenseUpdatedAt.hashCode ^
        name.hashCode ^
        notice.hashCode ^
        terms.hashCode ^
        updatedAt.hashCode ^
        updatedBy.hashCode ^
        usage.hashCode ^
        links.hashCode ^
        version.hashCode;
  }
}
