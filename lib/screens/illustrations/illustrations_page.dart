import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/components/texts/page_title.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/types/firestore/doc_snap_map.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class IllustrationsPage extends StatefulWidget {
  @override
  _IllustrationsPageState createState() => _IllustrationsPageState();
}

class _IllustrationsPageState extends State<IllustrationsPage> {
  bool _hasNext = true;
  bool _isFabVisible = false;

  final _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _descending = true;

  final int _limit = 30;

  final List<Illustration> _illustrationsList = [];
  DocumentSnapshot? _lastFirestoreDoc;
  QuerySnapshotStreamSubscription? _streamSubscription;

  @override
  void initState() {
    super.initState();
    fetchIllustrations();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: HeroController(),
      child: Scaffold(
        floatingActionButton: fab(),
        body: NotificationListener<ScrollNotification>(
          onNotification: onNotification,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              ApplicationBar(),
              SliverPadding(
                padding: const EdgeInsets.only(top: 70.0, bottom: 24.0),
                sliver: PageTitle(
                  showBackButton: true,
                  titleValue: "illustrations".tr(),
                  subtitleValue: "illustrations_browse".tr(),
                ),
              ),
              body(),
            ],
          ),
        ),
      ),
    );
  }

  Widget body() {
    if (_isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed([
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 100.0),
            child: AnimatedAppIcon(
              textTitle: "illustrations_loading".tr(),
            ),
          ),
        ]),
      );
    }

    if (_illustrationsList.isEmpty) {
      return emptyView();
    }

    return gridView();
  }

  Widget emptyView() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 40.0,
        left: 50.0,
        bottom: 100.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 12.0,
                ),
                child: Text(
                  "lonely_there".tr(),
                  style: TextStyle(
                    fontSize: 32.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                  // top: 24.0,
                ),
                child: Opacity(
                  opacity: 0.4,
                  child: Text(
                    "illustrations_empty".tr(),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget fab() {
    if (!_isFabVisible) {
      return Container();
    }

    return FloatingActionButton(
      onPressed: () {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(seconds: 1),
          curve: Curves.easeOut,
        );
      },
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      child: Icon(UniconsLine.arrow_up),
    );
  }

  Widget gridView() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 40.0,
        left: 40.0,
        right: 40.0,
        bottom: 100.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final illustration = _illustrationsList.elementAt(index);

            return IllustrationCard(
              index: index,
              heroTag: illustration.id,
              illustration: illustration,
              onTap: () => onTapIllustrationCard(illustration),
              // onPopupMenuItemSelected: onPopupMenuItemSelected,
              // popupMenuEntries: _popupMenuEntries,
            );
          },
          childCount: _illustrationsList.length,
        ),
      ),
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
      final illustration = Illustration.fromMap(data);
      _illustrationsList.insert(0, illustration);
    });
  }

  /// Fetch illustrations data from Firestore.
  void fetchIllustrations() async {
    setState(() {
      _isLoading = true;
      _illustrationsList.clear();
    });

    try {
      final QueryMap query = FirebaseFirestore.instance
          .collection('illustrations')
          .where('visibility', isEqualTo: 'public')
          .orderBy('createdAt', descending: _descending)
          .limit(_limit);

      startListenningToData(query);
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasNext = false;
        });

        return;
      }

      for (DocSnapMap document in snapshot.docs) {
        final data = document.data();
        data['id'] = document.id;

        _illustrationsList.add(Illustration.fromMap(data));
      }

      setState(() {
        _lastFirestoreDoc = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
      });
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Fetch more illustrations data from Firestore.
  void fetchMoreIllustrations() async {
    if (!_hasNext || _lastFirestoreDoc == null) {
      return;
    }

    _isLoadingMore = true;

    try {
      final QueryMap query = await FirebaseFirestore.instance
          .collection('illustrations')
          .where('visibility', isEqualTo: 'public')
          .orderBy('createdAt', descending: _descending)
          .limit(_limit)
          .startAfterDocument(_lastFirestoreDoc!);

      startListenningToData(query);
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasNext = false;
          _isLoadingMore = false;
        });

        return;
      }

      for (DocSnapMap document in snapshot.docs) {
        final data = document.data();
        data['id'] = document.id;

        _illustrationsList.add(Illustration.fromMap(data));
      }

      setState(() {
        _lastFirestoreDoc = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
        _isLoadingMore = false;
      });
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool onNotification(ScrollNotification notification) {
    // FAB visibility
    if (notification.metrics.pixels < 50 && _isFabVisible) {
      setState(() {
        _isFabVisible = false;
      });
    } else if (notification.metrics.pixels > 50 && !_isFabVisible) {
      setState(() {
        _isFabVisible = true;
      });
    }

    if (notification.metrics.pixels < notification.metrics.maxScrollExtent) {
      return false;
    }

    if (_hasNext && !_isLoadingMore) {
      fetchMoreIllustrations();
    }

    return false;
  }

  void onTapIllustrationCard(Illustration illustration) {
    NavigationStateHelper.illustration = illustration;
    Beamer.of(context).beamToNamed(
      "illustrations/${illustration.id}",
      data: {
        "illustrationId": illustration.id,
      },
    );
  }

  /// Fire when a new document has been delete from Firestore.
  /// Delete the corresponding document from the UI.
  void removeStreamingDoc(DocumentChangeMap documentChange) {
    setState(() {
      _illustrationsList.removeWhere(
        (illustration) => illustration.id == documentChange.doc.id,
      );
    });
  }

  /// Listen to the last Firestore query of this page.
  void startListenningToData(QueryMap query) {
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

  /// Fire when a new document has been updated in Firestore.
  /// Update the corresponding document in the UI.
  void updateStreamingDoc(DocumentChangeMap documentChange) {
    try {
      final data = documentChange.doc.data();
      if (data == null) {
        return;
      }

      final int index = _illustrationsList.indexWhere(
        (illustration) => illustration.id == documentChange.doc.id,
      );

      data['id'] = documentChange.doc.id;
      final updatedIllustration = Illustration.fromMap(data);

      setState(() {
        _illustrationsList.removeAt(index);
        _illustrationsList.insert(index, updatedIllustration);
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
