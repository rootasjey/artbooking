import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/created_by.dart';
import 'package:artbooking/types/enums/enum_license_type.dart';
import 'package:artbooking/types/license/license_terms.dart';
import 'package:artbooking/types/license/license_urls.dart';
import 'package:artbooking/types/license/license_usage.dart';
import 'package:artbooking/types/license/license_updated_by.dart';

/// Describe how an artwork can be used.
class License {
  License({
    this.abbreviation = '',
    required this.createdAt,
    this.createdBy = const CreatedBy(),
    this.description = '',
    required this.id,
    this.licenseUpdatedAt,
    required this.name,
    this.notice = '',
    required this.terms,
    this.type = EnumLicenseType.user,
    required this.updatedAt,
    this.updatedBy = const LicenseUpdatedBy(),
    required this.urls,
    required this.usage,
    this.version = '1.0',
  });

  /// The license short name.
  final String abbreviation;

  /// When this entry was created in Firestore.
  final DateTime createdAt;

  final CreatedBy createdBy;

  /// Information about this license.
  String description;

  /// Tell if this license has been created by an artist
  /// or by the platform's staff.
  EnumLicenseType type;

  /// License's id.
  final String id;

  /// License's term of service & privacy policy update.
  final DateTime? licenseUpdatedAt;

  /// License's name.
  String name;

  /// Additional information about this license usage.
  final String notice;

  /// Restrictions related to usage.
  final LicenseTerms terms;

  /// When this entry was last updated in Firestore.
  final DateTime updatedAt;

  final LicenseUpdatedBy updatedBy;

  /// If [custom] is true, defined what is permitted and is not.
  final LicenseUsage usage;

  /// License's urls.
  final LicenseUrls urls;

  /// If this license has a specific version.
  final String version;

  factory License.empty() {
    return License(
      abbreviation: '',
      createdAt: DateTime.now(),
      createdBy: CreatedBy.empty(),
      description: '',
      id: '',
      licenseUpdatedAt: DateTime.now(),
      name: '',
      notice: '',
      terms: LicenseTerms.empty(),
      type: EnumLicenseType.user,
      updatedAt: DateTime.now(),
      updatedBy: LicenseUpdatedBy.empty(),
      urls: LicenseUrls.empty(),
      usage: LicenseUsage.empty(),
      version: '',
    );
  }

  factory License.fromJSON(Map<String, dynamic> data) {
    return License(
      abbreviation: data['abbreviation'] ?? '',
      createdAt: Utilities.date.fromFirestore(data['createdAt']),
      createdBy: CreatedBy.fromJSON(data['createdBy']),
      description: data['description'] ?? '',
      id: data['id'] ?? '',
      licenseUpdatedAt: Utilities.date.fromFirestore(data['licenseUpdatedAt']),
      name: data['name'] ?? '',
      notice: data['notice'] ?? '',
      terms: LicenseTerms.fromJSON(data['terms']),
      type: convertStringToType(data['type'] ?? ''),
      updatedAt: Utilities.date.fromFirestore(data['updatedAt']),
      updatedBy: LicenseUpdatedBy.fromJSON(data['updatedBy']),
      urls: LicenseUrls.fromJSON(data['urls']),
      usage: LicenseUsage.fromJSON(data['usage']),
      version: data['version'] ?? '',
    );
  }

  void setType(EnumLicenseType newFrom) {
    this.type = newFrom;
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

  Map<String, dynamic> toJSON() {
    final data = Map<String, dynamic>();

    data['abbreviation'] = abbreviation;
    data['description'] = description;
    data['id'] = id;
    data['name'] = name;
    data['notice'] = notice;
    data['terms'] = terms.toJSON();
    data['type'] = convertFromToString();
    data['urls'] = urls.toJSON();
    data['usage'] = usage.toJSON();
    data['version'] = version;

    return data;
  }

  String typeToString() {
    return type == EnumLicenseType.staff ? 'staff' : 'user';
  }
}
