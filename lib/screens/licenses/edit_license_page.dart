import 'package:artbooking/components/dark_elevated_button.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/popup_progress_indicator.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/licenses/edit_license_page_header.dart';
import 'package:artbooking/screens/licenses/edit_license_page_urls.dart';
import 'package:artbooking/screens/licenses/edit_license_page_usage.dart';
import 'package:artbooking/types/illustration/license.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class EditLicensePage extends StatefulWidget {
  const EditLicensePage({
    Key? key,
    required this.licenseId,
  }) : super(key: key);

  final String licenseId;

  @override
  _EditLicensePageState createState() => _EditLicensePageState();
}

class _EditLicensePageState extends State<EditLicensePage> {
  bool _isSaving = false;
  bool _isLoading = false;

  var _license = IllustrationLicense.empty();
  var _nameTextController = TextEditingController();
  var _descriptionTextController = TextEditingController();
  final _clairPink = Constants.colors.clairPink;

  @override
  void initState() {
    super.initState();
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
          presentationSection(),
          EditLicensePageUsage(
            usage: _license.usage,
            onValueChange: onUsageValueChange,
          ),
          EditLicensePageUrls(
            urls: _license.urls,
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
        onPressed: tryUpdateLicense,
        child: Text("create".tr()),
      ),
    );
  }

  Widget presentationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        nameInput(),
        descriptionInput(),
      ],
    );
  }

  Widget descriptionInput() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "description".tr(),
                style: Utilities.fonts.style(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 300.0,
              child: TextFormField(
                controller: _descriptionTextController,
                decoration: InputDecoration(
                  labelText: "illustration_description_sample".tr(),
                  filled: true,
                  isDense: true,
                  fillColor: _clairPink,
                  focusColor: _clairPink,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2.0,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
                onFieldSubmitted: (value) {
                  tryUpdateLicense();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget nameInput() {
    return Container(
      width: 700.0,
      child: TextField(
        autofocus: true,
        controller: _nameTextController,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        style: Utilities.fonts.style(
          fontSize: 42.0,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: "license_title_dot".tr(),
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
        onSubmitted: (value) => tryUpdateLicense(),
      ),
    );
  }

  void tryFetchLicense() async {
    if (widget.licenseId.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

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

      setState(() {
        _license = IllustrationLicense.fromJSON(data);
      });
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void tryUpdateLicense() async {
    Utilities.logger.i('website: ${_license.urls.website}');
    Beamer.of(context).popRoute();
  }

  void onUsageValueChange() {
    setState(() {});
  }
}
