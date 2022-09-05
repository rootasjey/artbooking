import 'dart:async';

import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/bottom_sheet/delete_content_bottom_sheet.dart';
import 'package:artbooking/components/custom_scroll_behavior.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/screens/licenses/edit/edit_license_page.dart';
import 'package:artbooking/components/buttons/double_action_fab.dart';
import 'package:artbooking/screens/licenses/many/licenses_page_header.dart';
import 'package:artbooking/screens/licenses/many/licenses_page_body.dart';
import 'package:artbooking/types/cloud_functions/license_response.dart';
import 'package:artbooking/types/enums/enum_license_item_action.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snap_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:artbooking/types/enums/enum_license_type.dart';
import 'package:artbooking/types/user/user.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unicons/unicons.dart';

class LicensesPage extends ConsumerStatefulWidget {
  const LicensesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LicensesPage> createState() => _LicensesPageState();
}

class _LicensesPageState extends ConsumerState<LicensesPage> {
  /// Order results from most recent or oldest.
  bool _descending = true;

  /// If true, there are more licenses to fetch.
  bool _hasNext = true;

  /// Loading the current page if true.
  bool _loading = false;

  /// True if loading more style from Firestore.
  bool _loadingMore = false;

  /// Show this page floating action button if true.
  bool _showFabCreate = true;

  /// Show FAB to scroll to the top of the page if true.
  bool _showFabToTop = false;

  /// Last fetched document snapshot. Used for pagination.
  DocumentSnapshot<Object>? _lastDocument;

  /// Last saved Y offset.
  /// Used while scrolling to know the direction.
  double _previousOffset = 0.0;

  /// Selected tab to show license (staff or user).
  var _selectedTab = EnumLicenseType.staff;

  /// Staff's available licenses.
  final List<License> _licenses = [];

  /// Search results.
  // final List<IllustrationLicense> _suggestionsLicenses = [];

  /// Maximum licenses to fetch in one request.
  final int _limit = 20;

  /// Items when the current authenticated user own these illustrations.
  final List<PopupMenuItemIcon<EnumLicenseItemAction>> _popupMenuEntries = [
    PopupMenuItemIcon(
      delay: Duration(milliseconds: 0),
      icon: PopupMenuIcon(UniconsLine.trash),
      textLabel: "delete".tr(),
      value: EnumLicenseItemAction.delete,
    ),
    PopupMenuItemIcon(
      delay: Duration(milliseconds: 25),
      icon: PopupMenuIcon(UniconsLine.edit),
      textLabel: "edit".tr(),
      value: EnumLicenseItemAction.edit,
    ),
  ];

  /// Subscribe to license collection updates.
  QuerySnapshotStreamSubscription? _licenseSubscription;

  /// Page scroll controller.
  final ScrollController _pageScrollController = ScrollController();

  /// Search controller.
  final TextEditingController _searchTextController = TextEditingController();

  /// Delay search after typing input.
  Timer? _searchTimer;

  @override
  initState() {
    super.initState();
    loadPreferences();
    fetchLicenses();
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
    final bool isMobileSize = Utilities.size.isMobileSize(context);
    final User user = ref.watch(AppState.userProvider);
    final bool canManageStaffLicense =
        user.firestoreUser?.rights.canManageLicenses ?? false;

    final bool canManageLicense =
        _selectedTab == EnumLicenseType.staff ? canManageStaffLicense : true;

    return Scaffold(
      floatingActionButton: DoubleActionFAB(
        icon: Icon(UniconsLine.plus),
        isMainActionAvailable: canManageLicense,
        labelValue: "license_create".tr(),
        onMainActionPressed: openNewLicenseDialog,
        pageScrollController: _pageScrollController,
        showMainFab: _showFabCreate,
        showFabToTop: _showFabToTop,
      ),
      body: ImprovedScrolling(
        scrollController: _pageScrollController,
        enableKeyboardScrolling: true,
        onScroll: onPageScroll,
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: CustomScrollView(
            controller: _pageScrollController,
            slivers: <Widget>[
              ApplicationBar(
                bottom: PreferredSize(
                  child: LicensesPageHeader(
                    isMobileSize: isMobileSize,
                    selectedTab: _selectedTab,
                    onChangedTab: onChangedTab,
                  ),
                  preferredSize: Size.fromHeight(160.0),
                ),
                minimal: true,
                pinned: false,
              ),
              LicensesPageBody(
                isMobileSize: isMobileSize,
                licenses: _licenses,
                loading: _loading,
                onCreateLicense: openNewLicenseDialog,
                onDeleteLicense: canManageLicense ? onDeleteLicense : null,
                onEditLicense: canManageLicense ? onEditLicense : null,
                onPopupMenuItemSelected: onPopupMenuItemSelected,
                onTap: onTapLicense,
                popupMenuEntries: _popupMenuEntries,
                selectedTab: _selectedTab,
              )
            ],
          ),
        ),
      ),
    );
  }

  void fetchLicenses() {
    if (_selectedTab == EnumLicenseType.staff) {
      return fetchStaffLicenses();
    }

    return fetchUserLicenses();
  }

  /// Fetch staff license on Firestore.
  void fetchStaffLicenses() async {
    setState(() {
      _lastDocument = null;
      _licenses.clear();
      _loading = true;
    });

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("licenses")
          .orderBy("created_at", descending: _descending)
          .limit(_limit)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _loading = false;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;

        final License license = License.fromMap(data);
        _licenses.add(license);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocument = snapshot.docs.last;

      listenLicenseEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Fetch more staff licenses on Firestore.
  void fetchMoreStaffLicenses() async {
    final lastDocumentSnapshot = _lastDocument;
    if (_loadingMore || !_hasNext || lastDocumentSnapshot == null) {
      return;
    }

    setState(() => _loadingMore = true);

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("licenses")
          .limit(_limit)
          .orderBy("created_at", descending: _descending)
          .startAfterDocument(lastDocumentSnapshot)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _loadingMore = false;
          _lastDocument = null;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;

        final License license = License.fromMap(data);
        _licenses.add(license);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocument = snapshot.docs.last;

      listenLicenseEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  /// Fetch user's license on Firestore.
  void fetchUserLicenses() async {
    setState(() {
      _lastDocument = null;
      _licenses.clear();
      _loading = true;
    });

    try {
      final String? uid = ref.read(AppState.userProvider).authUser?.uid;

      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("user_licenses")
          .orderBy("created_at", descending: _descending)
          .limit(_limit)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _loading = false;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;

        final License license = License.fromMap(data);
        _licenses.add(license);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocument = snapshot.docs.last;

      listenLicenseEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Fetch more user's licenses on Firestore.
  void fetchMoreUserLicenses() async {
    final DocumentSnapshot? lastDocumentSnapshot = _lastDocument;
    if (_loadingMore || !_hasNext || lastDocumentSnapshot == null) {
      return;
    }

    setState(() => _loadingMore = true);

    try {
      final String? uid = ref.read(AppState.userProvider).authUser?.uid;

      final QuerySnapMap snapshot = await FirebaseFirestore.instance
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
          _lastDocument = null;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;

        final License license = License.fromMap(data);
        _licenses.add(license);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocument = snapshot.docs.last;

      listenLicenseEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  /// Return the query to listen changes to.
  QueryMap? getListenQuery() {
    final DocumentSnapshot? lastDocument = _lastDocument;
    if (lastDocument == null) {
      return null;
    }

    if (_selectedTab == EnumLicenseType.staff) {
      return FirebaseFirestore.instance
          .collection("licenses")
          .orderBy("created_at", descending: _descending)
          .endAtDocument(lastDocument);
    }

    final String? uid = ref.read(AppState.userProvider).authUser?.uid;

    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("user_licenses")
        .orderBy("created_at", descending: _descending)
        .endAtDocument(lastDocument);
  }

  void loadPreferences() {
    _selectedTab = Utilities.storage.getLicenseTab();
  }

  void maybeFetchMore(double offset) {
    if (_pageScrollController.position.atEdge &&
        offset > 50 &&
        _hasNext &&
        !_loadingMore) {
      _selectedTab == EnumLicenseType.staff
          ? fetchMoreStaffLicenses()
          : fetchMoreUserLicenses();
    }
  }

  void maybeShowFab(double offset) {
    final bool scrollingDown = offset - _previousOffset > 0;
    _previousOffset = offset;

    _showFabToTop = offset == 0.0 ? false : true;

    if (scrollingDown) {
      if (!_showFabCreate) {
        return;
      }

      setState(() => _showFabCreate = false);
      return;
    }

    if (offset == 0.0) {
      setState(() => _showFabToTop = false);
    }

    if (_showFabCreate) {
      return;
    }

    setState(() => _showFabCreate = true);
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

  /// Callback when the page scrolls up and down.
  void onPageScroll(double offset) {
    maybeShowFab(offset);
    maybeFetchMore(offset);
  }

  void onPopupMenuItemSelected(
    EnumLicenseItemAction action,
    int index,
    License license,
  ) {
    switch (action) {
      case EnumLicenseItemAction.delete:
        showConfirmDeleteLicense(license, index);
        break;
      case EnumLicenseItemAction.edit:
        onEditLicense(license, index);
        break;
      default:
        break;
    }
  }

  /// Listen to the last Firestore query of this page.
  void listenLicenseEvents(QueryMap? query) {
    if (query == null) {
      return;
    }

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
    showConfirmDeleteLicense(targetLicense, targetIndex);
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
    final String route = AtelierLocationContent.licenseRoute
        .replaceFirst(':licenseId', license.id);

    Beamer.of(context).beamToNamed(
      route,
      data: {
        "licenseId": license.id,
      },
      routeState: {
        "type": license.typeToString(),
      },
    );
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

  void showConfirmDeleteLicense(License license, int index) {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    Utilities.ui.showAdaptiveDialog(
      context,
      isMobileSize: isMobileSize,
      builder: (BuildContext context) {
        if (isMobileSize) {
          return DeleteContentBottomSheet(
            confirmButtonValue: "delete".tr(),
            onConfirm: () => tryDeleteLicense(license, index),
            showDivider: false,
            subtitleValue:
                "${'license_delete_are_you_sure'.tr()} ${license.name}} ?",
            titleValue: "license_delete".tr().toUpperCase(),
          );
        }

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
                style: Utilities.fonts.body(
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
                    style: Utilities.fonts.body(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: license.name,
                        style: Utilities.fonts.body(
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
