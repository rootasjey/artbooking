import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:artbooking/components/circle_button.dart';
import 'package:artbooking/components/fade_in_x.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/illustration/license.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

/// A side panel to add art style to an illustration.
class SelectLicensePanel extends StatefulWidget {
  /// Aleady selected styles for the illustration.
  final IllustrationLicense? selectedLicense;

  /// True if the panel is visible.
  final bool isVisible;

  /// Function callback when the panel is closed.
  final void Function()? onClose;

  /// This callback when an item is tapped.
  final void Function(IllustrationLicense, bool)? toggleLicenseAndUpdate;

  /// The panel elevation.
  final double elevation;

  /// Return an panel widget showing art styles.
  const SelectLicensePanel({
    Key? key,
    this.selectedLicense,
    this.isVisible = false,
    this.onClose,
    this.toggleLicenseAndUpdate,
    this.elevation = 4.0,
  }) : super(key: key);

  @override
  _SelectLicensePanelState createState() => _SelectLicensePanelState();
}

class _SelectLicensePanelState extends State<SelectLicensePanel> {
  /// True if there're more data to fetch.
  bool _hasNext = false;

  /// True if loading more style from Firestore.
  bool _isLoadingMore = false;

  /// True if the style's image is visible.
  bool _isImagePreviewVisible = false;

  /// Last fetched document snapshot. Useful for pagination.
  DocumentSnapshot<Object>? _lastDocumentSnapshot;

  /// All available art styles.
  final List<IllustrationLicense> _availableLicenses = [];

  /// Search results.
  final List<IllustrationLicense> _suggestionsLicenses = [];

  /// Search controller.
  final _searchTextController = TextEditingController();

  /// Maximum container's width.
  final double _containerWidth = 400.0;

  /// Maximum styles to fetch in one request.
  int _limitStyles = 10;

  /// Selected style for image preview.
  IllustrationLicense? _selectedLicensePreview;

  /// Delay search after typing input.
  Timer? _searchTimer;

  Color _secondaryColor = Colors.pink;

  @override
  initState() {
    super.initState();
    fetchLicenses();
    _secondaryColor = Theme.of(context).secondaryHeaderColor;
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
              content(),
              header(),
            ],
          ),
        ),
      ),
    );
  }

  Widget content() {
    if (_isImagePreviewVisible) {
      return containerPreview();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 120.0),
      child: NotificationListener<ScrollNotification>(
        onNotification: onNotification,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 0.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Column(
                    children: [
                      licenseInput(),
                    ],
                  ),
                ]),
              ),
            ),
            body(),
          ],
        ),
      ),
    );
  }

  Widget body() {
    if (_searchTextController.text.isNotEmpty &&
        _suggestionsLicenses.isNotEmpty) {
      return searchResultsLicensesList();
    }

    return predefLicensesList();
  }

  Widget header() {
    return Positioned(
      top: 0.0,
      child: Container(
        padding: const EdgeInsets.only(top: 20.0),
        decoration: BoxDecoration(
          color: Constants.colors.clairPink,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 380.0,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: CircleButton(
                      icon: Icon(
                        UniconsLine.times,
                        color: Colors.black54,
                      ),
                      onTap: widget.onClose,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "licenses_available".tr(),
                            style: Utilities.fonts.style(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Opacity(
                            opacity: 0.5,
                            child: Text(
                              "licenses_subtitle".tr(),
                              style: Utilities.fonts.style(
                                height: 1.0,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: _containerWidth,
              child: Divider(
                thickness: 2.0,
                color: _secondaryColor,
                height: 40.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget containerPreview() {
    Widget imageContainer;

    if (_selectedLicensePreview == null) {
      imageContainer = Container();
    } else {
      imageContainer = Container();
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 140.0,
        bottom: 12.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: "back".tr(),
                    onPressed: () {
                      setState(() {
                        _isImagePreviewVisible = false;
                      });
                    },
                    icon: Icon(UniconsLine.arrow_left),
                  ),
                  Expanded(
                    child: Opacity(
                      opacity: 0.8,
                      child: Text(
                        _selectedLicensePreview!.name!.toUpperCase(),
                        style: Utilities.fonts.style(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            imageContainer,
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  _selectedLicensePreview!.description,
                  style: Utilities.fonts.style(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            linksPreview(),
          ],
        ),
      ),
    );
  }

  Widget linksPreview() {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: [
          if (_selectedLicensePreview!.urls!.wikipedia.isNotEmpty)
            OutlinedButton(
              onPressed: () => launch(_selectedLicensePreview!.urls!.wikipedia),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("wikipedia"),
              ),
              style: OutlinedButton.styleFrom(
                primary: Colors.black54,
              ),
            ),
          if (_selectedLicensePreview!.urls!.website.isNotEmpty)
            OutlinedButton(
              onPressed: () => launch(_selectedLicensePreview!.urls!.website),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("website"),
              ),
              style: OutlinedButton.styleFrom(
                primary: Colors.black54,
              ),
            ),
        ],
      ),
    );
  }

  Widget predefLicensesList() {
    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final currentLicense = _availableLicenses.elementAt(index);
            final selectedLicenseId = widget.selectedLicense!.id;
            final selected = selectedLicenseId == currentLicense.id;

            return ListTile(
              onTap: () =>
                  widget.toggleLicenseAndUpdate!(currentLicense, selected),
              onLongPress: () {
                setState(() {
                  _selectedLicensePreview = currentLicense;
                  _isImagePreviewVisible = true;
                });
              },
              title: Opacity(
                opacity: 0.8,
                child: Row(
                  children: [
                    if (selected)
                      Icon(
                        UniconsLine.check,
                        color: selected ? _secondaryColor : null,
                      ),
                    Expanded(
                      child: Text(
                        currentLicense.name!.toUpperCase(),
                        style: Utilities.fonts.style(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            color: selected ? _secondaryColor : null),
                      ),
                    ),
                  ],
                ),
              ),
              subtitle: Text(
                currentLicense.description,
                style: Utilities.fonts.style(
                  fontWeight: FontWeight.w600,
                ),
              ),
              contentPadding: const EdgeInsets.all(16.0),
            );
          },
          childCount: _availableLicenses.length,
        ),
      ),
    );
  }

  Widget searchResultsLicensesList() {
    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final license = _suggestionsLicenses.elementAt(index);
            final selected = widget.selectedLicense!.id == license.id;

            return ListTile(
              onTap: () => widget.toggleLicenseAndUpdate!(license, selected),
              title: Opacity(
                opacity: 0.8,
                child: Row(
                  children: [
                    if (selected)
                      Icon(
                        UniconsLine.check,
                        color: selected ? _secondaryColor : null,
                      ),
                    Expanded(
                      child: Text(
                        license.name!.toUpperCase(),
                        style: Utilities.fonts.style(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            color: selected ? _secondaryColor : null),
                      ),
                    ),
                  ],
                ),
              ),
              subtitle: Text(
                license.description,
                style: Utilities.fonts.style(
                  fontWeight: FontWeight.w600,
                ),
              ),
              contentPadding: const EdgeInsets.all(16.0),
            );
          },
          childCount: _suggestionsLicenses.length,
        ),
      ),
    );
  }

  Widget licenseInput() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300.0,
                child: TextFormField(
                  autofocus: true,
                  controller: _searchTextController,
                  decoration: InputDecoration(
                    filled: true,
                    isDense: true,
                    labelText: "license_label_text".tr(),
                    fillColor: Constants.colors.clairPink,
                    focusColor: Constants.colors.clairPink,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 4.0,
                        color: Constants.colors.primary,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    _searchTimer?.cancel();

                    _searchTimer = Timer(
                      500.milliseconds,
                      searchLicense,
                    );
                  },
                  onFieldSubmitted: (value) {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Opacity(
                  opacity: 0.6,
                  child: IconButton(
                    tooltip: "styles_search".tr(),
                    icon: Icon(UniconsLine.search),
                    onPressed: searchLicense,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchTextController.clear();
                });
              },
              icon: Icon(UniconsLine.times),
              label: Text("clear".tr()),
              style: TextButton.styleFrom(
                primary: Colors.black54,
                textStyle: Utilities.fonts.style(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 1st fetch
  void fetchLicenses() async {
    _availableLicenses.clear();

    try {
      final stylesSnap = await FirebaseFirestore.instance
          .collection('licenses')
          .limit(_limitStyles)
          .orderBy('name', descending: true)
          .get();

      if (stylesSnap.size == 0) {
        setState(() {
          _hasNext = false;
        });

        return;
      }

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in stylesSnap.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        final license = IllustrationLicense.fromJSON(data);
        _availableLicenses.add(license);
      }

      setState(() {
        _hasNext = _limitStyles == stylesSnap.size;
        _lastDocumentSnapshot = stylesSnap.docs.last;
      });
    } catch (error) {
      appLogger.e(error);
    }
  }

  /// 2nd + more fetches
  void fetchMoreStyles() async {
    _isLoadingMore = true;

    try {
      final stylesSnap = await FirebaseFirestore.instance
          .collection('licenses')
          .limit(_limitStyles)
          .orderBy('name', descending: true)
          .startAfterDocument(_lastDocumentSnapshot!)
          .get();

      if (stylesSnap.size == 0) {
        setState(() {
          _hasNext = false;
          _lastDocumentSnapshot = null;
        });

        return;
      }

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in stylesSnap.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        final license = IllustrationLicense.fromJSON(data);
        _availableLicenses.add(license);
      }

      setState(() {
        _hasNext = _limitStyles == stylesSnap.size;
        _lastDocumentSnapshot = stylesSnap.docs.last;
      });
    } catch (error) {
      appLogger.e(error);
    }
  }

  /// On scroll notification
  bool onNotification(ScrollNotification notification) {
    if (notification.metrics.pixels < notification.metrics.maxScrollExtent) {
      return false;
    }

    if (_hasNext && !_isLoadingMore && _lastDocumentSnapshot != null) {
      fetchMoreStyles();
    }

    return false;
  }

  void searchLicense() async {
    _suggestionsLicenses.clear();

    try {
      final AlgoliaQuery query = await SearchHelper.algolia!
          .index("licenses")
          .query(_searchTextController.text)
          .setHitsPerPage(_limitStyles)
          .setPage(0);

      final AlgoliaQuerySnapshot snapshot = await query.getObjects();

      if (snapshot.empty) {
        return;
      }

      setState(() {
        for (final AlgoliaObjectSnapshot hit in snapshot.hits) {
          final data = hit.data;
          data['id'] = hit.objectID;

          final license = IllustrationLicense.fromJSON(data);
          _suggestionsLicenses.add(license);
        }
      });
    } catch (error) {
      appLogger.e(error);
    }
  }
}
