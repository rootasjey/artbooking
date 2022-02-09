import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:artbooking/components/animations/fade_in_x.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/licenses/selection_panel/select_license_panel_body.dart';
import 'package:artbooking/screens/licenses/selection_panel/select_license_panel_header.dart';
import 'package:artbooking/types/enums/enum_license_type.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:artbooking/globals/utilities/search_utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

/// A side panel to add art style to an illustration.
class SelectLicensePanel extends ConsumerStatefulWidget {
  /// Return an panel widget showing art styles.
  const SelectLicensePanel({
    Key? key,
    required this.selectedLicense,
    this.isVisible = false,
    this.onClose,
    this.onToggleLicenseAndUpdate,
    this.elevation = 4.0,
  }) : super(key: key);

  /// Aleady selected styles for the illustration.
  final License selectedLicense;

  /// True if the panel is visible.
  final bool isVisible;

  /// Function callback when the panel is closed.
  final void Function()? onClose;

  /// This callback when an item is tapped.
  final void Function(License, bool)? onToggleLicenseAndUpdate;

  /// The panel elevation.
  final double elevation;

  @override
  _SelectLicensePanelState createState() => _SelectLicensePanelState();
}

class _SelectLicensePanelState extends ConsumerState<SelectLicensePanel> {
  /// True if there're more data to fetch.
  bool _hasNext = false;

  /// True if loading licenses.
  bool _isLoading = false;

  /// True if loading more licenses.
  bool _isLoadingMore = false;

  /// True if the style's image is visible.
  bool _showLicenseInfo = false;

  /// Last fetched document snapshot. Useful for pagination.
  DocumentSnapshot<Object>? _lastDocumentSnapshot;

  /// Maximum container's width.
  final double _containerWidth = 400.0;

  /// Staff licenses.
  final List<License> _staffLicenses = [];

  /// The current authenticated user licenses.
  final List<License> _userLicenses = [];

  /// Search results.
  final List<License> _searchResultLicenses = [];

  final _panelScrollController = ScrollController();

  /// Maximum licenses to fetch in one request.
  int _limit = 10;

  /// Selected style for image preview.
  License _selectedLicense = License.empty();

  /// License we want to show information preview.
  License _moreInfoLicense = License.empty();

  String _searchInputValue = '';

  /// Delay search after typing input.
  Timer? _searchTimer;

  var _selectedTab = EnumLicenseType.staff;

  @override
  initState() {
    super.initState();
    fetchStaffLicenses();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _panelScrollController.dispose();
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
              SelectLicensePanelBody(
                isLoading: _isLoading,
                selectedTab: _selectedTab,
                onChangedTab: onChangedTab,
                showLicenseInfo: _showLicenseInfo,
                moreInfoLicense: _moreInfoLicense,
                selectedLicense: _selectedLicense,
                licenses: getLicensesDataList(),
                onScrollNotification: onScrollNotification,
                panelScrollController: _panelScrollController,
                onInputChanged: onInputChanged,
                searchInputValue: _searchInputValue,
                onTogglePreview: onToggleLicenseInfo,
                onSearchLicense: onSearchLicense,
                toggleLicenseAndUpdate: widget.onToggleLicenseAndUpdate,
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

  /// Fetch staff license on Firestore.
  void fetchStaffLicenses() async {
    setState(() {
      _staffLicenses.clear();
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('licenses')
          .limit(_limit)
          .orderBy('name', descending: true)
          .get();

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

        final license = License.fromMap(data);
        _staffLicenses.add(license);
      }

      setState(() {
        _hasNext = _limit == snapshot.size;
        _lastDocumentSnapshot = snapshot.docs.last;
      });
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Fetch more licenses on Firestore.
  void fetchStaffLicensesMore() async {
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

        final license = License.fromMap(data);
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

  /// Fetch user's license on Firestore.
  void fetchUserLicenses() async {
    setState(() {
      _lastDocumentSnapshot = null;
      _userLicenses.clear();
      _isLoading = true;
    });

    try {
      final String? uid = ref.read(AppState.userProvider).authUser?.uid;

      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('user_licenses')
          .orderBy('created_at', descending: true)
          .limit(_limit);

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

        final license = License.fromMap(data);
        _userLicenses.add(license);
      }

      setState(() {
        _hasNext = _limit == snapshot.size;
        _lastDocumentSnapshot = snapshot.docs.last;
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Fetch more user's licenses on Firestore.
  void fetchUserLicensesMore() async {
    setState(() => _isLoadingMore = true);

    try {
      final String? uid = ref.read(AppState.userProvider).authUser?.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('licenses')
          .limit(_limit)
          .orderBy('name', descending: true)
          .startAfterDocument(_lastDocumentSnapshot!)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _isLoadingMore = false;
          _lastDocumentSnapshot = null;
        });

        return;
      }

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        final license = License.fromMap(data);
        _userLicenses.add(license);
      }

      setState(() {
        _hasNext = _limit == snapshot.size;
        _lastDocumentSnapshot = snapshot.docs.last;
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  /// On scroll notification
  bool onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.pixels < notification.metrics.maxScrollExtent) {
      return false;
    }

    if (_hasNext && !_isLoadingMore && _lastDocumentSnapshot != null) {
      fetchStaffLicensesMore();
    }

    return false;
  }

  void onSearchLicense() async {
    _searchResultLicenses.clear();

    try {
      final AlgoliaQuery query = await SearchUtilities.algolia
          .index("licenses")
          .query(_searchInputValue)
          .setHitsPerPage(_limit)
          .setPage(0);

      final AlgoliaQuerySnapshot snapshot = await query.getObjects();

      if (snapshot.empty) {
        setState(() {});
        return;
      }

      setState(() {
        for (final AlgoliaObjectSnapshot hit in snapshot.hits) {
          final data = hit.data;
          data['id'] = hit.objectID;

          final license = License.fromMap(data);
          _searchResultLicenses.add(license);
        }
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void onInputChanged(String newSearchInputValue) {
    _searchInputValue = newSearchInputValue;
    _searchTimer?.cancel();

    _searchTimer = Timer(
      500.milliseconds,
      onSearchLicense,
    );
  }

  void onToggleLicenseInfo(bool visible, License? license) {
    setState(() {
      _showLicenseInfo = visible;
      if (license != null) {
        _moreInfoLicense = license;
      }
    });
  }

  void onChangedTab(EnumLicenseType newSelectedTab) {
    setState(() {
      _selectedTab = newSelectedTab;
    });

    switch (newSelectedTab) {
      case EnumLicenseType.staff:
        fetchStaffLicenses();
        break;
      case EnumLicenseType.user:
        fetchUserLicenses();
        break;
      default:
    }
  }

  List<License> getLicensesDataList() {
    if (_searchInputValue.isNotEmpty) {
      return _searchResultLicenses;
    }

    if (_selectedTab == EnumLicenseType.staff) {
      return _staffLicenses;
    }

    return _userLicenses;
  }
}
