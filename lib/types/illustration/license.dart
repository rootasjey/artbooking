import 'package:artbooking/types/created_by.dart';
import 'package:artbooking/types/illustration/license_terms.dart';
import 'package:artbooking/types/illustration/license_urls.dart';
import 'package:artbooking/types/illustration/license_usage.dart';
import 'package:artbooking/types/updated_by.dart';
import 'package:artbooking/utils/date_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Describe how an artwork can be used.
class IllustrationLicense {
  /// The license short name.
  final String? abbreviation;

  /// When this entry was created in Firestore.
  final DateTime? createdAt;

  final CreatedBy? createdBy;

  /// Information about this license.
  final String description;

  /// Tell if this license has been created by an artist
  /// or by the platform's staff.
  final String? from;

  /// License's id.
  final String? id;

  /// License's term of service & privacy policy update.
  final DateTime? licenseUpdatedAt;

  /// License's name.
  final String? name;

  /// Additional information about this license usage.
  final String? notice;

  /// Restrictions related to usage.
  final LicenseTerms? terms;

  /// When this entry was last updated in Firestore.
  final DateTime? updatedAt;

  final UpdatedBy? updatedBy;

  /// If [custom] is true, defined what is permitted and is not.
  final LicenseUsage? usage;

  /// License's urls.
  final LicenseUrls? urls;

  /// If this license has a specific version.
  final String? version;

  IllustrationLicense({
    this.abbreviation,
    this.createdAt,
    this.createdBy,
    this.description = '',
    this.from = '',
    this.id,
    this.licenseUpdatedAt,
    this.name,
    this.notice,
    this.terms,
    this.updatedAt,
    this.updatedBy,
    this.urls,
    this.usage,
    this.version,
  });

  factory IllustrationLicense.empty() {
    return IllustrationLicense(
      abbreviation: '',
      createdAt: DateTime.now(),
      createdBy: CreatedBy.empty(),
      description: '',
      from: '',
      id: '',
      licenseUpdatedAt: DateTime.now(),
      name: '',
      notice: '',
      terms: LicenseTerms.empty(),
      updatedAt: DateTime.now(),
      updatedBy: UpdatedBy.empty(),
      urls: LicenseUrls.empty(),
      usage: LicenseUsage.empty(),
      version: '',
    );
  }
  factory IllustrationLicense.fromJSON(Map<String, dynamic> data) {
    return IllustrationLicense(
      abbreviation: data['abbreviation'] ?? '',
      createdAt: DateHelper.fromFirestore(data['createdAt']),
      createdBy: CreatedBy.fromJSON(data['createdBy']),
      description: data['description'] ?? '',
      from: data['from'],
      id: data['id'] ?? '',
      licenseUpdatedAt: DateHelper.fromFirestore(data['licenseUpdatedAt']),
      name: data['name'] ?? '',
      notice: data['notice'] ?? '',
      terms: LicenseTerms.fromJSON(data['terms']),
      updatedAt: DateHelper.fromFirestore(data['updatedAt']),
      updatedBy: UpdatedBy.fromJSON(data['updatedBy']),
      urls: LicenseUrls.fromJSON(data['urls']),
      usage: LicenseUsage.fromJSON(data['usage']),
      version: data['version'] ?? '',
    );
  }

  Map<String, dynamic> toJSON() {
    final data = Map<String, dynamic>();

    data['abbreviation'] = abbreviation;
    data['createdAt'] = Timestamp.fromDate(createdAt!);
    data['description'] = description;
    data['from'] = from;
    data['id'] = id;
    data['licenseUpdatedAt'] = Timestamp.fromDate(licenseUpdatedAt!);
    data['name'] = name;
    data['notice'] = notice;
    data['terms'] = terms!.toJSON();
    data['urls'] = urls!.toJSON();
    data['usage'] = usage!.toJSON();
    data['updatedAt'] = Timestamp.fromDate(updatedAt!);
    data['version'] = version;

    return data;
  }
}
