import 'package:artbooking/components/dark_elevated_button.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/popup_progress_indicator.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/licenses/edit_license_page_header.dart';
import 'package:artbooking/screens/licenses/edit_license_page_urls.dart';
import 'package:artbooking/screens/licenses/edit_license_page_usage.dart';
import 'package:artbooking/screens/licenses/edit_license_page_text_inputs.dart';
import 'package:artbooking/types/cloud_functions/license_response.dart';
import 'package:artbooking/types/illustration/license.dart';
import 'package:artbooking/types/illustration/license_from.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';

class EditLicensePage extends StatefulWidget {
  const EditLicensePage({
    Key? key,
    required this.licenseId,
    required this.from,
  }) : super(key: key);

  final String licenseId;
  final LicenseFrom from;

  @override
  _EditLicensePageState createState() => _EditLicensePageState();
}

class _EditLicensePageState extends State<EditLicensePage> {
  bool _isSaving = false;
  bool _isLoading = false;

  var _license = IllustrationLicense.empty();

  @override
  void initState() {
    super.initState();
    _license.setFrom(widget.from);
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
                  body(),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40.0,
            right: 24.0,
            child: PopupProgressIndicator(
              show: _isSaving,
              message: '${"license_updating".tr()}...',
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (_isLoading) {
      return LoadingView(
        title: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Opacity(
            opacity: 0.6,
            child: Text("loading".tr()),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 90.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditLicensePageTextInputs(
            license: _license,
            onValueChange: onUsageValueChange,
          ),
          EditLicensePageUsage(
            usage: _license.usage,
            onValueChange: onUsageValueChange,
          ),
          EditLicensePageUrls(
            urls: _license.urls,
            onValueChange: onUsageValueChange,
          ),
          validationButton(),
        ],
      ),
    );
  }

  Widget validationButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 80.0),
      child: DarkElevatedButton.large(
        onPressed: _isSaving ? null : tryCreateOrUpdateLicense,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64.0),
          child: Text(
            widget.licenseId.isEmpty ? "create".tr() : "update".tr(),
          ),
        ),
      ),
    );
  }

  void tryFetchLicense() async {
    if (widget.licenseId.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('licenses')
          .doc(widget.licenseId)
          .get();

      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return;
      }

      data['id'] = snapshot.id;
      setState(() => _license = IllustrationLicense.fromJSON(data));
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

      final data = CloudFunctionsLicenseResponse.fromJSON(response.data);

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
      Utilities.logger.i(
        "(update) wiki: ${_license.urls.wikipedia}",
      );
      final HttpsCallableResult<dynamic> response =
          await Utilities.cloud.fun("licenses-updateOne").call({
        "license": _license.toJSON(),
      });

      final data = CloudFunctionsLicenseResponse.fromJSON(response.data);

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

  void onUsageValueChange() {
    setState(() {});
  }
}
