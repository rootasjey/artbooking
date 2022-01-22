import 'package:artbooking/components/popup_progress_indicator.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/licenses/edit/edit_license_page_body.dart';
import 'package:artbooking/screens/licenses/edit/edit_license_page_header.dart';
import 'package:artbooking/types/cloud_functions/license_response.dart';
import 'package:artbooking/types/firestore/document_map.dart';
import 'package:artbooking/types/firestore/document_snapshot_map.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:artbooking/types/enums/enum_license_type.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditLicensePage extends ConsumerStatefulWidget {
  const EditLicensePage({
    Key? key,
    required this.licenseId,
    required this.type,
  }) : super(key: key);

  final String licenseId;
  final EnumLicenseType type;

  @override
  _EditLicensePageState createState() => _EditLicensePageState();
}

class _EditLicensePageState extends ConsumerState<EditLicensePage> {
  bool _isSaving = false;
  bool _isLoading = false;

  var _license = License.empty();

  @override
  void initState() {
    super.initState();
    _license.setType(widget.type);
    tryFetchLicense();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(60.0),
              child: Column(
                children: [
                  EditLicensePageHeader(
                    licenseId: _license.id,
                    licenseName: _license.name,
                  ),
                  EditLicensePageBody(
                    license: _license,
                    isLoading: _isLoading,
                    isSaving: _isSaving,
                    isNewLicense: widget.licenseId.isEmpty,
                    onValidate: tryCreateOrUpdateLicense,
                    onUsageValueChange: onUsageValueChanged,
                    onDescriptionChanged: onDescriptionChanged,
                    onTitleChanged: onTitleChanged,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40.0,
            right: 24.0,
            child: PopupProgressIndicator(
              show: _isSaving,
              message: widget.licenseId.isEmpty
                  ? '${"license_creating".tr()}...'
                  : '${"license_updating".tr()}...',
            ),
          ),
        ],
      ),
    );
  }

  DocumentMap getLicenseQuery() {
    if (widget.type == EnumLicenseType.staff) {
      return FirebaseFirestore.instance
          .collection('licenses')
          .doc(widget.licenseId);
    }

    final String? uid = ref.read(AppState.userProvider).authUser?.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('licenses')
        .doc(widget.licenseId);
  }

  void tryFetchLicense() async {
    if (widget.licenseId.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final DocumentMap query = getLicenseQuery();
      final DocumentSnapshotMap snapshot = await query.get();

      final Json? data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return;
      }

      data['id'] = snapshot.id;
      setState(() => _license = License.fromJSON(data));
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void tryCreateOrUpdateLicense() {
    if (widget.licenseId.isEmpty) {
      tryCreateLicense();
      return;
    }

    tryUpdateLicense();
  }

  void tryCreateLicense() async {
    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final HttpsCallableResult<dynamic> response =
          await Utilities.cloud.fun("licenses-createOne").call({
        "license": _license.toJSON(),
      });

      final data = LicenseResponse.fromJSON(response.data);

      if (data.success) {
        Beamer.of(context).popRoute();
        return;
      }

      context.showErrorBar(content: Text("license_create_error".tr()));
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void tryUpdateLicense() async {
    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final HttpsCallableResult<dynamic> response =
          await Utilities.cloud.fun("licenses-updateOne").call({
        "license": _license.toJSON(),
      });

      final data = LicenseResponse.fromJSON(response.data);

      if (data.success) {
        Beamer.of(context).popRoute();
        return;
      }

      context.showErrorBar(content: Text("license_update_fail".tr()));
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void onUsageValueChanged() {
    setState(() {});
  }

  void onDescriptionChanged(String newDescription) {
    _license.description = newDescription;
  }

  void onTitleChanged(String newName) {
    _license.name = newName;
  }
}
