import 'dart:async';

import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/screens/licenses/edit/edit_license_page.dart';
import 'package:artbooking/screens/licenses/many/licenses_page_fab.dart';
import 'package:artbooking/screens/licenses/many/licenses_page_header.dart';
import 'package:artbooking/screens/licenses/many/licenses_page_body.dart';
import 'package:artbooking/types/cloud_functions/license_response.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:artbooking/types/enums/enum_license_type.dart';
import 'package:artbooking/types/user/user.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class LicensesPage extends ConsumerStatefulWidget {
  const LicensesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LicensesPage> createState() => _LicensesPageState();
}

class _LicensesPageState extends ConsumerState<LicensesPage> {
  /// True if there're more data to fetch.
  bool _hasNext = true;

  /// True if loading more style from Firestore.
  bool _loadingMore = false;

  bool _descending = true;
  bool _loading = false;

  /// Last fetched document snapshot. Used for pagination.
  DocumentSnapshot<Object>? _lastDocumentSnapshot;

  /// Staff's available licenses.
  final List<License> _licenses = [];

  /// Search results.
  // final List<IllustrationLicense> _suggestionsLicenses = [];

  /// Search controller.
  final _searchTextController = TextEditingController();

  /// Maximum licenses to fetch in one request.
  int _limit = 20;

  QuerySnapshotStreamSubscription? _licenseSubscription;

  /// Delay search after typing input.
  Timer? _searchTimer;

  /// Selected tab to show license (staff or user).
  var _selectedTab = EnumLicenseType.staff;

  @override
  initState() {
    super.initState();
    loadPreferences();
    fetchLicense();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchTextController.dispose();
    _licenseSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = ref.watch(AppState.userProvider);
    final bool canManageStaffLicense =
        user.firestoreUser?.rights.canManageLicenses ?? false;

    final bool canManageLicense =
        _selectedTab == EnumLicenseType.staff ? canManageStaffLicense : true;

    return Scaffold(
      floatingActionButton: LicensesPageFab(
        show: canManageLicense,
        onPressed: openNewLicenseDialog,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          ApplicationBar(),
          LicensesPageHeader(
            selectedTab: _selectedTab,
            onChangedTab: onChangedTab,
          ),
          LicensesPageBody(
            licenses: _licenses,
            isLoading: _loading,
            onTap: onTapLicense,
            selectedTab: _selectedTab,
            onDeleteLicense: canManageLicense ? onDeleteLicense : null,
            onEditLicense: canManageLicense ? onEditLicense : null,
            onCreateLicense: openNewLicenseDialog,
          )
        ],
      ),
    );
  }

  void fetchLicense() {
    if (_selectedTab == EnumLicenseType.staff) {
      return fetchStaffLicenses();
    }

    return fetchUserLicenses();
  }

  /// Fetch staff license on Firestore.
  void fetchStaffLicenses() async {
    _licenseSubscription?.cancel();

    setState(() {
      _lastDocumentSnapshot = null;
      _licenses.clear();
      _loading = true;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection("licenses")
          .orderBy("created_at", descending: _descending)
          .limit(_limit);

      listenLicenseEvents(query);
      final snapshot = await query.get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _loading = false;
        });

        return;
      }

      for (QueryDocSnapMap doc in snapshot.docs) {
        final data = doc.data();
        data["id"] = doc.id;

        final license = License.fromMap(data);
        _licenses.add(license);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocumentSnapshot = snapshot.docs.last;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Fetch more staff licenses on Firestore.
  void fetchMoreStaffLicenses() async {
    final lastDocumentSnapshot = _lastDocumentSnapshot;
    if (_loadingMore || !_hasNext || lastDocumentSnapshot == null) {
      return;
    }

    setState(() => _loadingMore = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("licenses")
          .limit(_limit)
          .orderBy("created_at", descending: _descending)
          .startAfterDocument(lastDocumentSnapshot)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _loadingMore = false;
          _lastDocumentSnapshot = null;
        });

        return;
      }

      for (QueryDocSnapMap doc in snapshot.docs) {
        final data = doc.data();
        data["id"] = doc.id;

        final license = License.fromMap(data);
        _licenses.add(license);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocumentSnapshot = snapshot.docs.last;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  /// Fetch user's license on Firestore.
  void fetchUserLicenses() async {
    _licenseSubscription?.cancel();

    setState(() {
      _lastDocumentSnapshot = null;
      _licenses.clear();
      _loading = true;
    });

    try {
      final String? uid = ref.read(AppState.userProvider).authUser?.uid;

      final query = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("user_licenses")
          .orderBy("created_at", descending: _descending)
          .limit(_limit);

      listenLicenseEvents(query);
      final snapshot = await query.get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _loading = false;
        });

        return;
      }

      for (QueryDocSnapMap doc in snapshot.docs) {
        final data = doc.data();
        data["id"] = doc.id;

        final license = License.fromMap(data);
        _licenses.add(license);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocumentSnapshot = snapshot.docs.last;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Fetch more user's licenses on Firestore.
  void fetchMoreUserLicenses() async {
    final lastDocumentSnapshot = _lastDocumentSnapshot;
    if (_loadingMore || !_hasNext || lastDocumentSnapshot == null) {
      return;
    }

    setState(() => _loadingMore = true);

    try {
      final String? uid = ref.read(AppState.userProvider).authUser?.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("user_licenses")
          .limit(_limit)
          .orderBy("created_at", descending: _descending)
          .startAfterDocument(lastDocumentSnapshot)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _loadingMore = false;
          _lastDocumentSnapshot = null;
        });

        return;
      }

      for (QueryDocSnapMap doc in snapshot.docs) {
        final data = doc.data();
        data["id"] = doc.id;

        final license = License.fromMap(data);
        _licenses.add(license);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocumentSnapshot = snapshot.docs.last;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  void loadPreferences() {
    _selectedTab = Utilities.storage.getLicenseTab();
  }

  void onChangedTab(EnumLicenseType licenseTab) {
    Utilities.storage.saveLicenseTab(licenseTab);

    setState(() {
      _selectedTab = licenseTab;
    });

    switch (licenseTab) {
      case EnumLicenseType.staff:
        fetchStaffLicenses();
        break;
      case EnumLicenseType.user:
        fetchUserLicenses();
        break;
      default:
    }
  }

  /// On scroll notification
  bool onNotification(ScrollNotification notification) {
    if (notification.metrics.pixels < notification.metrics.maxScrollExtent) {
      return false;
    }

    if (_hasNext && !_loadingMore && _lastDocumentSnapshot != null) {
      fetchMoreStaffLicenses();
    }

    return false;
  }

  /// Listen to the last Firestore query of this page.
  void listenLicenseEvents(QueryMap query) {
    _licenseSubscription?.cancel();
    _licenseSubscription = query.snapshots().skip(1).listen(
      (snapshot) {
        for (DocumentChangeMap documentChange in snapshot.docChanges) {
          switch (documentChange.type) {
            case DocumentChangeType.added:
              onAddStreamingLicense(documentChange);
              break;
            case DocumentChangeType.modified:
              onUpdateStreamingLicense(documentChange);
              break;
            case DocumentChangeType.removed:
              onRemoveStreamingLicense(documentChange);
              break;
          }
        }
      },
      onError: (error) {
        Utilities.logger.e(error);
      },
    );
  }

  /// Fire when a new document has been created in Firestore.
  /// Add the corresponding document in the UI.
  void onAddStreamingLicense(DocumentChangeMap documentChange) {
    final data = documentChange.doc.data();

    if (data == null) {
      return;
    }

    setState(() {
      data["id"] = documentChange.doc.id;
      final license = License.fromMap(data);
      _licenses.insert(0, license);
    });
  }

  void onDeleteLicense(targetLicense, targetIndex) {
    showDeleteConfirmDialog(targetLicense, targetIndex);
  }

  void onEditLicense(License targetLicense, int targetIndex) {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => EditLicensePage(
        licenseId: targetLicense.id,
        type: targetLicense.type,
      ),
    );
  }

  /// Fire when a new document has been delete from Firestore.
  /// Delete the corresponding document from the UI.
  void onRemoveStreamingLicense(DocumentChangeMap documentChange) {
    setState(() {
      _licenses.removeWhere(
        (license) => license.id == documentChange.doc.id,
      );
    });
  }

  void onTapLicense(License license) {
    final route = AtelierLocationContent.licenseRoute
        .replaceFirst(':licenseId', license.id);

    Beamer.of(context).beamToNamed(route, data: {
      'licenseId': license.id,
    }, routeState: {
      'type': license.typeToString(),
    });
  }

  /// Fire when a new document has been updated in Firestore.
  /// Update the corresponding document in the UI.
  void onUpdateStreamingLicense(DocumentChangeMap documentChange) {
    try {
      final data = documentChange.doc.data();
      if (data == null || !documentChange.doc.exists) {
        return;
      }

      final int index = _licenses.indexWhere(
        (x) => x.id == documentChange.doc.id,
      );

      data["id"] = documentChange.doc.id;
      final updatedLicense = License.fromMap(data);

      setState(() {
        _licenses.removeAt(index);
        _licenses.insert(index, updatedLicense);
      });
    } on Exception catch (error) {
      Utilities.logger.e(
        "The document with the id ${documentChange.doc.id} "
        "doesn't exist in the illustrations list.",
      );

      Utilities.logger.e(error);
    }
  }

  void openNewLicenseDialog() async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => EditLicensePage(
        licenseId: "",
        type: _selectedTab,
      ),
    );
  }

  void showDeleteConfirmDialog(License license, int index) {
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
            tryDeleteLicense(license, index);
            Beamer.of(context).popRoute();
          },
          onCancel: Beamer.of(context).popRoute,
        );
      },
    );
  }

  void tryDeleteLicense(License license, int index) async {
    setState(() => _licenses.removeAt(index));

    try {
      final response = await Utilities.cloud.fun('licenses-deleteOne').call({
        'license_id': license.id,
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
      setState(() => _licenses.insert(index, license));
    }
  }
}
