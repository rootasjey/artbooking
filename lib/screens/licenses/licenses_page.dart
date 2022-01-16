import 'dart:async';

import 'package:artbooking/components/main_app_bar/main_app_bar.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/components/themed_dialog.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/licenses/edit_license_page.dart';
import 'package:artbooking/screens/licenses/licenses_page_header.dart';
import 'package:artbooking/screens/licenses/licenses_page_body.dart';
import 'package:artbooking/types/cloud_functions/license_response.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:artbooking/types/license/license_from.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unicons/unicons.dart';

class LicensesPage extends StatefulWidget {
  const LicensesPage({Key? key}) : super(key: key);

  @override
  State<LicensesPage> createState() => _LicensesPageState();
}

class _LicensesPageState extends State<LicensesPage> {
  /// True if there're more data to fetch.
  bool _hasNext = false;

  /// True if loading more style from Firestore.
  bool _isLoadingMore = false;

  bool _descending = true;
  bool _isLoading = false;

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

  QuerySnapshotStreamSubscription? _streamSubscription;

  /// Delay search after typing input.
  Timer? _searchTimer;

  @override
  initState() {
    super.initState();
    fetchLicenses();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchTextController.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: openNewLicenseDialog,
        child: Icon(UniconsLine.plus),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverEdgePadding(),
          MainAppBar(),
          LicensesPageHeader(),
          LicensesPageBody(
              licenses: _licenses,
              isLoading: _isLoading,
              onDeleteLicense: (targetLicense, targetIndex) {
                showDeleteConfirmDialog(targetLicense, targetIndex);
              },
              onEditLicense: (targetLicense, targetIndex) {
                showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) => EditLicensePage(
                    licenseId: targetLicense.id,
                    from: LicenseFrom.staff,
                  ),
                );
              })
        ],
      ),
    );
  }

  /// Fetch license on Firestore.
  void fetchLicenses() async {
    setState(() {
      _licenses.clear();
      _isLoading = true;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection('licenses')
          .orderBy('createdAt', descending: _descending)
          .limit(_limit);

      startListenningToCollection(query);
      final snapshot = await query.get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _isLoading = false;
        });

        return;
      }

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        final license = License.fromJSON(data);
        _licenses.add(license);
      }

      setState(() {
        _hasNext = _limit == snapshot.size;
        _lastDocumentSnapshot = snapshot.docs.last;
      });
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Fetch more licenses on Firestore.
  void fetchLicensesMore() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('licenses')
          .limit(_limit)
          .orderBy('name', descending: true)
          .startAfterDocument(_lastDocumentSnapshot!)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _lastDocumentSnapshot = null;
        });

        return;
      }

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        final license = License.fromJSON(data);
        _licenses.add(license);
      }

      setState(() {
        _hasNext = _limit == snapshot.size;
        _lastDocumentSnapshot = snapshot.docs.last;
      });
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  /// On scroll notification
  bool onNotification(ScrollNotification notification) {
    if (notification.metrics.pixels < notification.metrics.maxScrollExtent) {
      return false;
    }

    if (_hasNext && !_isLoadingMore && _lastDocumentSnapshot != null) {
      fetchLicensesMore();
    }

    return false;
  }

  void openNewLicenseDialog() async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => EditLicensePage(
        licenseId: '',
        from: LicenseFrom.staff,
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

  /// Listen to the last Firestore query of this page.
  void startListenningToCollection(QueryMap query) {
    _streamSubscription = query.snapshots().skip(1).listen(
      (snapshot) {
        for (DocumentChangeMap documentChange in snapshot.docChanges) {
          switch (documentChange.type) {
            case DocumentChangeType.added:
              addStreamingDoc(documentChange);
              break;
            case DocumentChangeType.modified:
              updateStreamingDoc(documentChange);
              break;
            case DocumentChangeType.removed:
              removeStreamingDoc(documentChange);
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
  void addStreamingDoc(DocumentChangeMap documentChange) {
    final data = documentChange.doc.data();

    if (data == null) {
      return;
    }

    setState(() {
      data['id'] = documentChange.doc.id;
      final illustration = License.fromJSON(data);
      _licenses.insert(0, illustration);
    });
  }

  /// Fire when a new document has been delete from Firestore.
  /// Delete the corresponding document from the UI.
  void removeStreamingDoc(DocumentChangeMap documentChange) {
    setState(() {
      _licenses.removeWhere(
        (license) => license.id == documentChange.doc.id,
      );
    });
  }

  void tryDeleteLicense(License license, int index) async {
    setState(() => _licenses.removeAt(index));

    try {
      final response = await Utilities.cloud.fun('licenses-deleteOne').call({
        'licenseId': license.id,
        'from': 'staff',
      });

      final data = CloudFunctionsLicenseResponse.fromJSON(response.data);
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

  /// Fire when a new document has been updated in Firestore.
  /// Update the corresponding document in the UI.
  void updateStreamingDoc(DocumentChangeMap documentChange) {
    try {
      final data = documentChange.doc.data();
      if (data == null) {
        return;
      }

      final int index = _licenses.indexWhere(
        (illustration) => illustration.id == documentChange.doc.id,
      );

      data['id'] = documentChange.doc.id;
      final updatedIllustration = License.fromJSON(data);

      setState(() {
        _licenses.removeAt(index);
        _licenses.insert(index, updatedIllustration);
      });
    } on Exception catch (error) {
      Utilities.logger.e(
        "The document with the id ${documentChange.doc.id} "
        "doesn't exist in the illustrations list.",
      );

      Utilities.logger.e(error);
    }
  }
}
