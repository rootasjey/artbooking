import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/components/themed_dialog.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/screens/licenses/edit/edit_license_page.dart';
import 'package:artbooking/screens/licenses/one/license_page_body.dart';
import 'package:artbooking/screens/licenses/one/license_page_header.dart';
import 'package:artbooking/types/cloud_functions/license_response.dart';
import 'package:artbooking/types/firestore/doc_snapshot_stream_subscription.dart';
import 'package:artbooking/types/firestore/document_map.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:artbooking/types/enums/enum_license_type.dart';
import 'package:artbooking/types/user/user.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unicons/unicons.dart';

class LicensePage extends ConsumerStatefulWidget {
  const LicensePage({
    Key? key,
    required this.licenseId,
    required this.type,
  }) : super(key: key);

  final String licenseId;
  final EnumLicenseType type;

  @override
  ConsumerState<LicensePage> createState() => _LicensePageState();
}

class _LicensePageState extends ConsumerState<LicensePage> {
  bool _isDeleting = false;
  bool _isLoading = false;

  DocSnapshotStreamSubscription? _streamSubscription;

  var _license = License.empty();

  @override
  void initState() {
    super.initState();
    fetchLicense();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = ref.watch(AppState.userProvider);
    final bool canManageLicense =
        user.firestoreUser?.rights.canManageLicense ?? false;

    return Scaffold(
      floatingActionButton: fab(canManageLicense),
      body: CustomScrollView(
        slivers: [
          SliverEdgePadding(),
          ApplicationBar(),
          LicensePageHeader(),
          LicensePageBody(
            isLoading: _isLoading,
            isDeleting: _isDeleting,
            license: _license,
            onEditLicense: onEditLicense,
            onDeleteLicense: onDeleteLicense,
            canManageLicense: canManageLicense,
          ),
          SliverEdgePadding(
            padding: const EdgeInsets.only(bottom: 200),
          ),
        ],
      ),
    );
  }

  Widget? fab(bool canManageLicense) {
    if (!canManageLicense) {
      return null;
    }

    return FloatingActionButton(
      onPressed: onEditLicense,
      child: Icon(UniconsLine.edit),
      backgroundColor: Theme.of(context).secondaryHeaderColor,
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

  void fetchLicense() async {
    setState(() => _isLoading = true);

    try {
      final query = getLicenseQuery();

      final docSnapshot = await query.get();
      final data = docSnapshot.data();

      if (!docSnapshot.exists || data == null) {
        return;
      }

      startListeningToDocument(query);

      data['id'] = docSnapshot.id;
      setState(() => _license = License.fromJSON(data));
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void onDeleteLicense() {
    showDeleteConfirmDialog(_license);
  }

  void onEditLicense() {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => EditLicensePage(
        licenseId: _license.id,
        type: _license.type,
      ),
    );
  }

  void showDeleteConfirmDialog(License license) {
    showDialog(
      context: context,
      builder: (context) {
        return ThemedDialog(
          spaceActive: false,
          centerTitle: false,
          autofocus: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                "license_delete".tr().toUpperCase(),
                style: Utilities.fonts.style(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          body: Container(
            width: 300.0,
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text.rich(
                  TextSpan(
                    text: "license_delete_are_you_sure".tr(),
                    style: Utilities.fonts.style(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: license.name,
                        style: Utilities.fonts.style(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                      TextSpan(text: " ?"),
                    ],
                  ),
                ),
              ),
            ),
          ),
          textButtonValidation: "delete".tr(),
          onValidate: () {
            tryDeleteLicense(license);
            Beamer.of(context).popRoute();
          },
          onCancel: Beamer.of(context).popRoute,
        );
      },
    );
  }

  void tryDeleteLicense(License license) async {
    setState(() => _isDeleting = true);

    try {
      final response = await Utilities.cloud.fun('licenses-deleteOne').call({
        'licenseId': license.id,
        'type': license.typeToString(),
      });

      final data = LicenseResponse.fromJSON(response.data);
      if (data.success) {
        return;
      }

      throw ErrorDescription("license_delete_failed".tr());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  void startListeningToDocument(DocumentReference<Map<String, dynamic>> query) {
    _streamSubscription = query.snapshots().skip(1).listen((docSnapshot) {
      final Json? data = docSnapshot.data();

      if (!docSnapshot.exists || data == null) {
        context.canBeamBack
            ? Beamer.of(context).popRoute()
            : Beamer.of(context).beamToNamed(HomeLocation.route);

        return;
      }

      setState(() {
        data['id'] = docSnapshot.id;
        _license = License.fromJSON(data);
      });
    });
  }
}
