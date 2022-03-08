import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/firestore/doc_snap_map.dart';
import 'package:artbooking/types/section.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

/// Open a dialog showing available sections.
class AddSectionDialog extends StatefulWidget {
  const AddSectionDialog({
    Key? key,
    this.onAddSection,
  }) : super(key: key);

  final void Function(Section)? onAddSection;

  @override
  _AddSectionDialogState createState() => _AddSectionDialogState();
}

class _AddSectionDialogState extends State<AddSectionDialog> {
  bool _loading = false;
  bool _hasNext = false;
  bool _loadingMore = false;

  DocumentSnapshot? _lastDocument;

  final int _limit = 20;
  List<Section> _sections = [];

  var _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchSections();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _lastDocument = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedDialog(
      useRawDialog: true,
      title: Opacity(
        opacity: 0.8,
        child: Column(
          children: [
            Text(
              "section_add_new".tr().toUpperCase(),
              style: Utilities.fonts.style(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Opacity(
                opacity: 0.4,
                child: Text(
                  "section_add_new_description".tr(),
                  textAlign: TextAlign.center,
                  style: Utilities.fonts.style(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: body(),
      textButtonValidation: "close".tr(),
      onCancel: Beamer.of(context).popRoute,
      onValidate: Beamer.of(context).popRoute,
    );
  }

  Widget body() {
    if (_loading) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Column(
            children: [
              Opacity(
                opacity: 0.8,
                child: Text(
                  "loading".tr(),
                  style: Utilities.fonts.style(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              LinearProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 380.0,
        maxWidth: 400.0,
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: onScrollNotification,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final book = _sections.elementAt(index);
                  return sectionTile(book);
                },
                childCount: _sections.length,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget sectionTile(Section section) {
    final double cardWidth = 100.0;
    final double cardHeight = 100.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: cardHeight,
                width: cardWidth,
                child: Card(
                  elevation: 3.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    child: Opacity(
                      opacity: 0.8,
                      child: Icon(
                        Utilities.getSectionIcon(section.id),
                        size: 32.0,
                      ),
                    ),
                    onTap: () => _onAddSection(section),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0, right: 12.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () => _onAddSection(section),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Opacity(
                              opacity: 0.8,
                              child: Text(
                                "section_name.${section.id}".tr(),
                                maxLines: 1,
                                style: Utilities.fonts.style(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Opacity(
                              opacity: 0.4,
                              child: Text(
                                "section_description.${section.id}".tr(),
                                maxLines: 3,
                                style: Utilities.fonts.style(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void fetchSections() async {
    setState(() {
      _sections.clear();
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("sections")
          .limit(_limit)
          .orderBy("created_at", descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        _hasNext = false;
        return;
      }

      for (DocSnapMap document in snapshot.docs) {
        final map = document.data();
        map["id"] = document.id;
        _sections.add(Section.fromMap(map));
      }

      _lastDocument = snapshot.docs.last;
      _hasNext = snapshot.docs.length == _limit;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future fetchMoreSections() async {
    final lastDocument = _lastDocument;
    if (lastDocument == null || !_hasNext || _loadingMore) {
      return;
    }

    setState(() => _loadingMore = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("sections")
          .limit(_limit)
          .orderBy("created_at", descending: true)
          .startAfterDocument(lastDocument)
          .get();

      if (snapshot.docs.isEmpty) {
        _hasNext = false;
        return;
      }

      for (DocSnapMap document in snapshot.docs) {
        final map = document.data();
        map["id"] = document.id;
        _sections.add(Section.fromMap(map));
      }

      _lastDocument = snapshot.docs.last;
      _hasNext = snapshot.docs.length == _limit;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text("books_fetch_more_error".tr()));
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  bool onScrollNotification(ScrollNotification scrollNotif) {
    if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
      return false;
    }

    if (_hasNext && !_loadingMore) {
      fetchMoreSections();
    }

    return false;
  }

  _onAddSection(Section section) {
    Beamer.of(context).popRoute();
    widget.onAddSection?.call(section);
  }
}
