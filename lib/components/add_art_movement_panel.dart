import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/components/animations/fade_in_x.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/components/inputs/search_text_input.dart';
import 'package:artbooking/types/art_movement/art_movement.dart';
import 'package:artbooking/globals/utilities/search_utilities.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/firestore/query_snap_map.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

/// A side panel to toggle art movement of an illustration.
class AddArtMovementPanel extends StatefulWidget {
  /// Return an panel widget showing art art movements.
  const AddArtMovementPanel({
    Key? key,
    this.selectedArtMovements = const [],
    this.isVisible = false,
    this.onClose,
    this.onToggleArtMovementAndUpdate,
    this.elevation = 4.0,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapts its layout to small screens.
  final bool isMobileSize;

  /// True if the panel is visible.
  final bool isVisible;

  /// The panel elevation.
  final double elevation;

  /// Aleady selected art movements for the illustration.
  final List<String?> selectedArtMovements;

  /// Function callback when the panel is closed.
  final void Function()? onClose;

  /// This callback when an item is tapped.
  final void Function(
    ArtMovement style,
    bool selected,
  )? onToggleArtMovementAndUpdate;

  @override
  _AddArtMovementPanelState createState() => _AddArtMovementPanelState();
}

class _AddArtMovementPanelState extends State<AddArtMovementPanel> {
  /// Selected art movement for image preview.
  ArtMovement _selectedArtMovementPreview = ArtMovement.empty();

  /// True if there're more data to fetch.
  bool _hasNext = false;

  /// True if loading more art movement from Firestore.
  bool _loadingMore = false;

  /// Searching art movements according to `_searchTextController.text` if true.
  bool _searching = false;

  /// True if the art movement's image is visible.
  bool _isImagePreviewVisible = false;

  final Color _clairPink = Constants.colors.clairPink;
  final Color _secondaryColor = Constants.colors.secondary;

  /// Last fetched document snapshot. Useful for pagination.
  DocumentSnapshot<Object>? _lastDocumentSnapshot;

  /// Maximum container's width.
  double _containerWidth = 400.0;

  /// Search input focus node.
  final FocusNode _searchFocusNode = FocusNode();

  /// Maximum art movements to fetch in one request.
  int _limit = 10;

  /// All available art art movements.
  final List<ArtMovement> _availableArtMovements = [];

  /// Search results.
  final List<ArtMovement> _suggestionsList = [];

  /// Delay search after typing input.
  Timer? _searchTimer;

  /// Page scroll controller.
  final ScrollController _scrollController = ScrollController();

  /// Search text controller.
  final TextEditingController _searchTextController = TextEditingController();

  @override
  initState() {
    super.initState();
    _containerWidth = widget.isMobileSize ? 300.0 : 400.0;
    fetchArtMovements();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _scrollController.dispose();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return Container();
    }

    final double height = widget.isMobileSize
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.height - 200.0;

    return FadeInX(
      beginX: 16.0,
      child: Material(
        elevation: widget.elevation,
        color: _clairPink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          width: _containerWidth,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              body(),
              header(),
            ],
          ),
        ),
      ),
    );
  }

  Widget body() {
    if (_isImagePreviewVisible) {
      return imagePreview();
    }

    return Padding(
      padding: widget.isMobileSize
          ? const EdgeInsets.only(top: 180.0)
          : const EdgeInsets.only(top: 120.0),
      child: NotificationListener<ScrollNotification>(
        onNotification: onNotification,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _searchTextController.text.isNotEmpty && _suggestionsList.isNotEmpty
                ? searchResultListView()
                : predefinedListView(),
            SliverPadding(padding: const EdgeInsets.only(bottom: 100.0)),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Positioned(
      top: 0.0,
      child: Container(
        padding: const EdgeInsets.only(top: 20.0),
        decoration: BoxDecoration(
          color: _clairPink,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _containerWidth,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: CircleButton(
                      tooltip: "close".tr(),
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
                            "art_movements_available".tr(),
                            style: Utilities.fonts.body(
                              fontSize: widget.isMobileSize ? 16.0 : 22.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Opacity(
                            opacity: 0.5,
                            child: Text(
                              "art_movements_subtitle".tr(),
                              style: Utilities.fonts.body(
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
            searchInput(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: _containerWidth,
                      maxWidth: _containerWidth * 1.5,
                    ),
                    child: _searching
                        ? LinearProgressIndicator()
                        : Divider(
                            thickness: 2.0,
                            color: _secondaryColor,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget imagePreview() {
    Widget imageContainer;

    if (_selectedArtMovementPreview.links.image.isEmpty) {
      imageContainer = Container();
    } else {
      imageContainer = Material(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Ink.image(
          image: NetworkImage(_selectedArtMovementPreview.links.image),
          width: 300.0,
          height: 260.0,
          fit: BoxFit.cover,
          child: InkWell(
            onTap: () =>
                launchUrl(Uri.parse(_selectedArtMovementPreview.links.image)),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 140.0,
        bottom: 12.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                        _selectedArtMovementPreview.name.toUpperCase(),
                        style: Utilities.fonts.body(
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
                  _selectedArtMovementPreview.description,
                  style: Utilities.fonts.body(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => launchUrl(
                  Uri.parse(_selectedArtMovementPreview.links.wikipedia)),
              child: Text(_selectedArtMovementPreview.links.wikipedia),
              style: TextButton.styleFrom(
                primary: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget predefinedListView() {
    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final artMovement = _availableArtMovements.elementAt(index);
            final selected = widget.selectedArtMovements.contains(
              artMovement.id,
            );

            return ListTile(
              onTap: () => widget.onToggleArtMovementAndUpdate?.call(
                artMovement,
                selected,
              ),
              onLongPress: () {
                setState(() {
                  _selectedArtMovementPreview = artMovement;
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
                        artMovement.name.toUpperCase(),
                        style: Utilities.fonts.body(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            color: selected ? _secondaryColor : null),
                      ),
                    ),
                  ],
                ),
              ),
              subtitle: Text(
                artMovement.description,
                style: Utilities.fonts.body(
                  fontWeight: FontWeight.w600,
                ),
              ),
              contentPadding: const EdgeInsets.all(16.0),
            );
          },
          childCount: _availableArtMovements.length,
        ),
      ),
    );
  }

  Widget searchResultListView() {
    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final ArtMovement artMovement = _suggestionsList.elementAt(index);
            final bool selected = widget.selectedArtMovements.contains(
              artMovement.id,
            );

            return ListTile(
              onTap: () => widget.onToggleArtMovementAndUpdate?.call(
                artMovement,
                selected,
              ),
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
                        artMovement.name.toUpperCase(),
                        style: Utilities.fonts.body(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            color: selected ? _secondaryColor : null),
                      ),
                    ),
                  ],
                ),
              ),
              subtitle: Text(
                artMovement.description,
                style: Utilities.fonts.body(
                  fontWeight: FontWeight.w600,
                ),
              ),
              contentPadding: const EdgeInsets.all(16.0),
            );
          },
          childCount: _suggestionsList.length,
        ),
      ),
    );
  }

  Widget searchInput() {
    return Padding(
      padding: widget.isMobileSize
          ? EdgeInsets.only(left: 8.0, right: 6.0, top: 24.0)
          : const EdgeInsets.all(24.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchTextInput(
            autofocus: true,
            controller: _searchTextController,
            focusNode: _searchFocusNode,
            label: "search".tr(),
            hintText: "art_movement_label_text".tr(),
            constraints: BoxConstraints(maxWidth: 300.0, maxHeight: 140.0),
            onChanged: (String newValue) {
              _searchTimer?.cancel();

              _searchTimer = Timer(
                500.milliseconds,
                trySearch,
              );
            },
            onClearInput: () {
              setState(() {
                _searchTextController.clear();
                _suggestionsList.clear();
              });

              _searchFocusNode.requestFocus();
            },
          ),
          CircleButton(
            icon: Icon(UniconsLine.search, color: Colors.black87),
            margin: const EdgeInsets.only(left: 4.0, top: 18.0),
            onTap: trySearch,
          ),
        ],
      ),
    );
  }

  void fetchArtMovements() async {
    _availableArtMovements.clear();

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection('art_movements')
          .limit(_limit)
          .orderBy('name', descending: true)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json map = doc.data();
        map["id"] = doc.id;

        final ArtMovement artMovement = ArtMovement.fromMap(map);
        _availableArtMovements.add(artMovement);
      }

      setState(() {
        _hasNext = _limit == snapshot.size;
        _lastDocumentSnapshot = snapshot.docs.last;
      });
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  void fetchMoreArtMovements() async {
    _loadingMore = true;

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("art_movements")
          .limit(_limit)
          .orderBy("name", descending: true)
          .startAfterDocument(_lastDocumentSnapshot!)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _lastDocumentSnapshot = null;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json map = doc.data();
        map["id"] = doc.id;

        final ArtMovement artMovement = ArtMovement.fromMap(map);
        _availableArtMovements.add(artMovement);
      }

      setState(() {
        _hasNext = _limit == snapshot.size;
        _lastDocumentSnapshot = snapshot.docs.last;
      });
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  bool onNotification(ScrollNotification notification) {
    if (notification.metrics.pixels < notification.metrics.maxScrollExtent) {
      return false;
    }

    if (_hasNext && !_loadingMore && _lastDocumentSnapshot != null) {
      fetchMoreArtMovements();
    }

    return false;
  }

  void trySearch() async {
    setState(() {
      _suggestionsList.clear();
      _searching = true;
    });

    try {
      final AlgoliaQuery query = await SearchUtilities.algolia
          .index("art_movements")
          .query(_searchTextController.text)
          .setHitsPerPage(_limit)
          .setPage(0);

      final AlgoliaQuerySnapshot snapshot = await query.getObjects();

      if (snapshot.empty) {
        return;
      }

      setState(() {
        for (final AlgoliaObjectSnapshot hit in snapshot.hits) {
          final Json data = hit.data;
          data["id"] = hit.objectID;

          final ArtMovement artMovement = ArtMovement.fromMap(data);
          _suggestionsList.add(artMovement);
        }
      });
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _searching = false);
    }
  }
}
