import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:artbooking/components/animations/fade_in_x.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/licenses/selection_panel/select_license_panel_body.dart';
import 'package:artbooking/screens/licenses/selection_panel/select_license_panel_header.dart';
import 'package:artbooking/types/enums/enum_license_type.dart';
import 'package:artbooking/types/json_types.dart';
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

  /// True if the panel is visible.
  final bool isVisible;

  /// Aleady selected styles for the illustration.
  final License selectedLicense;

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
  bool _loading = false;

  /// True if loading more licenses.
  bool _loadingMore = false;

  /// Searching art movements according to `_searchInputController.text` if true.
  bool _searching = false;

  /// True if the style's image is visible.
  bool _showLicenseInfo = false;

  /// Last fetched document snapshot. Useful for pagination.
  DocumentSnapshot<Object>? _lastDocumentSnapshot;

  /// Maximum container's width.
  double _width = 400.0;

  final FocusNode _searchFocusNode = FocusNode();

  /// Staff licenses.
  final List<License> _staffLicenses = [];

  /// The current authenticated user licenses.
  final List<License> _userLicenses = [];

  /// Search results.
  final List<License> _searchResultLicenses = [];

  EnumLicenseType _selectedTab = EnumLicenseType.staff;

  /// Maximum licenses to fetch in one request.
  int _limit = 10;

  /// Selected style for image preview.
  License _selectedLicense = License.empty();

  /// License we want to show information preview.
  License _moreInfoLicense = License.empty();

  final ScrollController _pageScrollController = ScrollController();

  final TextEditingController _searchInputController = TextEditingController();

  /// Delay search after typing input.
  Timer? _searchTimer;

  @override
  initState() {
    super.initState();
    fetchStaffLicenses();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _pageScrollController.dispose();
    _searchFocusNode.dispose();
    _searchInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return Container();
    }

    _selectedLicense = widget.selectedLicense;

    final Size size = MediaQuery.of(context).size;
    final bool isMobileSize = size.width < Utilities.size.mobileWidthTreshold;

    _width = isMobileSize ? size.width : 400.0;
    final double height = isMobileSize ? size.height : size.height - 200.0;

    return FadeInX(
      beginX: 16.0,
      child: Material(
        elevation: widget.elevation,
        color: Constants.colors.clairPink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          width: _width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SelectLicensePanelBody(
                isMobileSize: isMobileSize,
                loading: _loading,
                showSearchResults: _searchInputController.text.isNotEmpty,
                showLicenseInfo: _showLicenseInfo,
                moreInfoLicense: _moreInfoLicense,
                selectedLicense: _selectedLicense,
                licenses: getLicensesDataList(),
                onPageScroll: onPageScroll,
                panelScrollController: _pageScrollController,
                onTogglePreview: onToggleLicenseInfo,
                searching: _searching,
                toggleLicenseAndUpdate: widget.onToggleLicenseAndUpdate,
              ),
              SelectLicensePanelHeader(
                onClose: widget.onClose,
                width: _width,
                selectedTab: _selectedTab,
                onChangedTab: onChangedTab,
                onClearInput: onClearInput,
                onInputChanged: onInputChanged,
                trySearchLicense: trySearchLicense,
                searchInputController: _searchInputController,
                searching: _searching,
                searchFocusNode: _searchFocusNode,
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
      _loading = true;
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
          _loading = false;
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
        _loading = false;
      });
    }
  }

  /// Fetch more licenses on Firestore.
  void fetchMoreStaffLicenses() async {
    _loadingMore = true;

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
      _loading = true;
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
          _loading = false;
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
        _loading = false;
      });
    }
  }

  /// Fetch more user's licenses on Firestore.
  void fetchMoreUserLicenses() async {
    setState(() => _loadingMore = true);

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
          _loadingMore = false;
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
      setState(() => _loadingMore = false);
    }
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

  /// Callback when the page scrolls up and down.
  void onPageScroll(double offset) {
    maybeFetchMore(offset);
  }

  /// Run a search based on the user input.
  void trySearchLicense() async {
    _searchResultLicenses.clear();
    setState(() => _searching = true);

    try {
      final AlgoliaQuery query = await SearchUtilities.algolia
          .index("licenses")
          .query(_searchInputController.text)
          .setHitsPerPage(_limit)
          .setPage(0);

      final AlgoliaQuerySnapshot snapshot = await query.getObjects();

      if (snapshot.empty) {
        setState(() {});
        return;
      }

      setState(() {
        for (final AlgoliaObjectSnapshot hit in snapshot.hits) {
          final Json data = hit.data;
          data["id"] = hit.objectID;

          final License license = License.fromMap(data);
          _searchResultLicenses.add(license);
        }
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _searching = false);
    }
  }

  void onInputChanged(String _) {
    _searchTimer?.cancel();

    if (_searchInputController.text.isEmpty) {
      onClearInput();
      return;
    }

    _searchTimer = Timer(
      500.milliseconds,
      trySearchLicense,
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

  void onClearInput() {
    setState(() {
      _searchInputController.clear();
      _searchResultLicenses.clear();
    });

    _searchFocusNode.requestFocus();
  }

  List<License> getLicensesDataList() {
    if (_searchInputController.text.isNotEmpty) {
      return _searchResultLicenses;
    }

    if (_selectedTab == EnumLicenseType.staff) {
      return _staffLicenses;
    }

    return _userLicenses;
  }
}
