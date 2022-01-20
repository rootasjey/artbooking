import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:artbooking/components/animations/fade_in_x.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/licenses/selection_panel/select_license_panel_body.dart';
import 'package:artbooking/screens/licenses/selection_panel/select_license_panel_header.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:artbooking/globals/utilities/search_utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// A side panel to add art style to an illustration.
class SelectLicensePanel extends StatefulWidget {
  /// Return an panel widget showing art styles.
  const SelectLicensePanel({
    Key? key,
    required this.selectedLicense,
    this.isVisible = false,
    this.onClose,
    this.toggleLicenseAndUpdate,
    this.elevation = 4.0,
  }) : super(key: key);

  /// Aleady selected styles for the illustration.
  final License selectedLicense;

  /// True if the panel is visible.
  final bool isVisible;

  /// Function callback when the panel is closed.
  final void Function()? onClose;

  /// This callback when an item is tapped.
  final void Function(License, bool)? toggleLicenseAndUpdate;

  /// The panel elevation.
  final double elevation;

  @override
  _SelectLicensePanelState createState() => _SelectLicensePanelState();
}

class _SelectLicensePanelState extends State<SelectLicensePanel> {
  /// True if there're more data to fetch.
  bool _hasNext = false;

  /// True if loading more style from Firestore.
  bool _isLoadingMore = false;

  /// True if the style's image is visible.
  bool _showLicenseInfo = false;

  /// Last fetched document snapshot. Useful for pagination.
  DocumentSnapshot<Object>? _lastDocumentSnapshot;

  /// All available art styles.
  final List<License> _staffLicenses = [];

  /// Search results.
  final List<License> _searchResultLicenses = [];

  /// Search controller.
  final _searchTextController = TextEditingController();

  /// Maximum container's width.
  final double _containerWidth = 400.0;

  /// Maximum licenses to fetch in one request.
  int _limit = 10;

  /// Selected style for image preview.
  License _selectedLicense = License.empty();

  /// Delay search after typing input.
  Timer? _searchTimer;

  final _panelScrollController = ScrollController();

  String _searchInputValue = '';

  @override
  initState() {
    super.initState();
    _selectedLicense = widget.selectedLicense;
    fetchLicenses();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return Container();
    }

    _selectedLicense = widget.selectedLicense;

    return FadeInX(
      beginX: 16.0,
      child: Material(
        elevation: widget.elevation,
        color: Constants.colors.clairPink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          width: _containerWidth,
          height: MediaQuery.of(context).size.height - 200.0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // content(),
              SelectLicensePanelBody(
                showLicenseInfo: _showLicenseInfo,
                selectedLicense: _selectedLicense,
                licenses: _searchInputValue.isEmpty
                    ? _staffLicenses
                    : _searchResultLicenses,
                onScrollNotification: onScrollNotification,
                panelScrollController: _panelScrollController,
                onInputChanged: onInputChanged,
                searchInputValue: _searchInputValue,
                onTogglePreview: onToggleLicenseInfo,
                onSearchLicense: onSearchLicense,
                toggleLicenseAndUpdate: onToggleLicense,
              ),
              SelectLicensePanelHeader(
                onClose: widget.onClose,
                containerWidth: _containerWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fetch license on Firestore.
  void fetchLicenses() async {
    _staffLicenses.clear();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('licenses')
          .limit(_limit)
          .orderBy('name', descending: true)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
        });

        return;
      }

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        final license = License.fromJSON(data);
        _staffLicenses.add(license);
      }

      setState(() {
        _hasNext = _limit == snapshot.size;
        _lastDocumentSnapshot = snapshot.docs.last;
      });
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  /// Fetch more licenses on Firestore.
  void fetchLicensesMore() async {
    _isLoadingMore = true;

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
        _staffLicenses.add(license);
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
  bool onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.pixels < notification.metrics.maxScrollExtent) {
      return false;
    }

    if (_hasNext && !_isLoadingMore && _lastDocumentSnapshot != null) {
      fetchLicensesMore();
    }

    return false;
  }

  void onSearchLicense() async {
    _searchResultLicenses.clear();

    try {
      final AlgoliaQuery query = await SearchUtilities.algolia
          .index("licenses")
          .query(_searchTextController.text)
          .setHitsPerPage(_limit)
          .setPage(0);

      final AlgoliaQuerySnapshot snapshot = await query.getObjects();

      if (snapshot.empty) {
        return;
      }

      setState(() {
        for (final AlgoliaObjectSnapshot hit in snapshot.hits) {
          final data = hit.data;
          data['id'] = hit.objectID;

          final license = License.fromJSON(data);
          _searchResultLicenses.add(license);
        }
      });
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  void onInputChanged(String newSearchInputValue) {
    setState(() {
      _searchInputValue + newSearchInputValue;
    });
  }

  void onToggleLicenseInfo(bool visible) {
    _showLicenseInfo = visible;
  }

  void onToggleLicense(License license, bool selected) {
    widget.toggleLicenseAndUpdate?.call(license, selected);
  }
}
