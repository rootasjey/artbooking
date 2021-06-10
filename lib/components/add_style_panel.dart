import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:artbooking/components/circle_button.dart';
import 'package:artbooking/components/fade_in_x.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/types/style.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

/// A side panel to add art style to an illustration.
class AddStylePanel extends StatefulWidget {
  /// Aleady selected styles for the illustration.
  final List<String> selectedStyles;

  /// True if the panel is visible.
  final bool isVisible;

  /// Function callback when the panel is closed.
  final void Function() onClose;

  /// This callback when an item is tapped.
  final void Function(Style style, bool selected) toggleStyleAndUpdate;

  /// The panel elevation.
  final double elevation;

  /// Return an panel widget showing art styles.
  const AddStylePanel({
    Key key,
    this.selectedStyles,
    this.isVisible = false,
    this.onClose,
    this.toggleStyleAndUpdate,
    this.elevation = 4.0,
  }) : super(key: key);

  @override
  _AddStylePanelState createState() => _AddStylePanelState();
}

class _AddStylePanelState extends State<AddStylePanel> {
  /// True if there're more data to fetch.
  bool _hasNext = false;
  bool _isLoadingMore = false;

  /// Last fetched document snapshot. Useful for pagination.
  DocumentSnapshot<Object> _lastDocumentSnapshot;

  /// All available art styles.
  final List<Style> _availableStyles = [];

  /// Search results.
  final List<Style> _suggestionsStyles = [];

  /// Search controller.
  final _searchTextController = TextEditingController();

  /// Maximum container's width.
  final double _containerWidth = 400.0;

  /// Maximum styles to fetch in one request.
  int _limitStyles = 10;

  /// Delay search after typing input.
  Timer _searchTimer;

  @override
  initState() {
    super.initState();
    fetchStyles();
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
        color: stateColors.clairPink,
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
    return Padding(
      padding: const EdgeInsets.only(top: 90.0),
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
                      stylesInput(),
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
        _suggestionsStyles.isNotEmpty) {
      return searchResultsStylesList();
    }

    return predefStylesList();
  }

  Widget header() {
    return Positioned(
      top: 0.0,
      child: Container(
        padding: const EdgeInsets.only(top: 20.0),
        decoration: BoxDecoration(
          color: stateColors.clairPink,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 24.0,
              alignment: WrapAlignment.spaceAround,
              crossAxisAlignment: WrapCrossAlignment.center,
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
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Text(
                    "styles_available".tr(),
                    style: FontsUtils.mainStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: _containerWidth,
              child: Divider(
                thickness: 2.0,
                color: stateColors.secondary,
                height: 40.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget predefStylesList() {
    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final style = _availableStyles.elementAt(index);
            final selected = widget.selectedStyles.contains(style.name);

            return ListTile(
              onTap: () => widget.toggleStyleAndUpdate(style, selected),
              title: Opacity(
                opacity: 0.8,
                child: Row(
                  children: [
                    if (selected)
                      Icon(
                        UniconsLine.check,
                        color: selected ? stateColors.secondary : null,
                      ),
                    Expanded(
                      child: Text(
                        style.name.toUpperCase(),
                        style: FontsUtils.mainStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            color: selected ? stateColors.secondary : null),
                      ),
                    ),
                  ],
                ),
              ),
              subtitle: Text(
                style.description,
                style: FontsUtils.mainStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              contentPadding: const EdgeInsets.all(16.0),
            );
          },
          childCount: _availableStyles.length,
        ),
      ),
    );
  }

  Widget searchResultsStylesList() {
    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final style = _suggestionsStyles.elementAt(index);
            final selected = widget.selectedStyles.contains(style.name);

            return ListTile(
              onTap: () => widget.toggleStyleAndUpdate(style, selected),
              title: Opacity(
                opacity: 0.8,
                child: Row(
                  children: [
                    if (selected)
                      Icon(
                        UniconsLine.check,
                        color: selected ? stateColors.secondary : null,
                      ),
                    Expanded(
                      child: Text(
                        style.name.toUpperCase(),
                        style: FontsUtils.mainStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            color: selected ? stateColors.secondary : null),
                      ),
                    ),
                  ],
                ),
              ),
              subtitle: Text(
                style.description,
                style: FontsUtils.mainStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              contentPadding: const EdgeInsets.all(16.0),
            );
          },
          childCount: _suggestionsStyles.length,
        ),
      ),
    );
  }

  Widget stylesInput() {
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
                    labelText: "style_label_text".tr(),
                    fillColor: stateColors.clairPink,
                    focusColor: stateColors.clairPink,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 4.0,
                        color: stateColors.primary,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    _searchTimer?.cancel();

                    _searchTimer = Timer(
                      500.milliseconds,
                      searchStyle,
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
                    onPressed: searchStyle,
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
                textStyle: FontsUtils.mainStyle(
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
  void fetchStyles() async {
    _availableStyles.clear();

    try {
      final stylesSnap = await FirebaseFirestore.instance
          .collection('styles')
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

        final style = Style.fromJSON(data);
        _availableStyles.add(style);
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
          .collection('styles')
          .limit(_limitStyles)
          .orderBy('name', descending: true)
          .startAfterDocument(_lastDocumentSnapshot)
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

        final style = Style.fromJSON(data);
        _availableStyles.add(style);
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

  void searchStyle() async {
    _suggestionsStyles.clear();

    try {
      final AlgoliaQuery query = await SearchHelper.algolia
          .index("styles")
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

          final style = Style.fromJSON(data);
          _suggestionsStyles.add(style);
        }
      });
    } catch (error) {
      appLogger.e(error);
    }
  }
}
