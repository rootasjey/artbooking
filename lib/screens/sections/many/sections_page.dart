import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/sections/many/sections_page_body.dart';
import 'package:artbooking/screens/sections/many/sections_page_header.dart';
import 'package:artbooking/types/enums/enum_section_item_action.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/popup_entry_section.dart';
import 'package:artbooking/types/section.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class SectionsPage extends ConsumerStatefulWidget {
  const SectionsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SectionsPage> createState() => _LicensesPageState();
}

class _LicensesPageState extends ConsumerState<SectionsPage> {
  /// Collection order.
  /// Oftent starts as the newest to oldest.
  bool _descending = true;

  /// True if there're more data to fetch.
  bool _hasNext = true;

  /// Fetching data if true.
  bool _loading = false;

  /// True if loading more style from Firestore.
  bool _loadingMore = false;

  /// Last fetched document snapshot. Used for pagination.
  DocumentSnapshot<Object>? _lastDocumentSnapshot;

  /// Staff's available licenses.
  final List<Section> _sections = [];

  /// Available items for authenticated user and book is not liked yet.
  final List<PopupEntrySection> _popupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumSectionItemAction.edit,
      icon: PopupMenuIcon(UniconsLine.pen),
      textLabel: "edit".tr(),
    ),
    PopupMenuItemIcon(
      value: EnumSectionItemAction.delete,
      icon: PopupMenuIcon(UniconsLine.trash),
      textLabel: "delete".tr(),
    ),
  ];

  /// Maximum licenses to fetch in one request.
  int _limit = 20;

  /// Subscribe to Firestore collection.
  QuerySnapshotStreamSubscription? _sectionSubscription;

  @override
  initState() {
    super.initState();
    fetchSections();
  }

  @override
  void dispose() {
    _sectionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddSection,
        icon: Icon(UniconsLine.plus),
        label: Text("section_create_abbreviation".tr()),
        extendedTextStyle: Utilities.fonts.body(fontWeight: FontWeight.w600),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          ApplicationBar(),
          SectionsPageHeader(),
          SectionsPageBody(
            sections: _sections,
            loading: _loading,
            onTapSection: onTapSection,
            onDeleteSection: onDeleteSection,
            onEditSection: onEditSection,
            onCreateSection: navigateToAddSection,
            popupMenuEntries: _popupMenuEntries,
            onPopupMenuItemSelected: onPopupMenuItemSelected,
          )
        ],
      ),
    );
  }

  /// Fetch sections.
  void fetchSections() async {
    _sectionSubscription?.cancel();

    setState(() {
      _lastDocumentSnapshot = null;
      _sections.clear();
      _loading = true;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection("sections")
          .orderBy("created_at", descending: _descending)
          .limit(_limit);

      listenSectionEvents(query);
      final snapshot = await query.get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _loading = false;
        });

        return;
      }

      for (QueryDocSnapMap doc in snapshot.docs) {
        final data = doc.data();
        data["id"] = doc.id;

        final section = Section.fromMap(data);
        _sections.add(section);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocumentSnapshot = snapshot.docs.last;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Fetch more sections (pagination).
  void fetchMoreSections() async {
    final lastDocumentSnapshot = _lastDocumentSnapshot;
    if (_loadingMore || !_hasNext || lastDocumentSnapshot == null) {
      return;
    }

    setState(() => _loadingMore = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("sections")
          .limit(_limit)
          .startAfterDocument(lastDocumentSnapshot)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _loadingMore = false;
          _lastDocumentSnapshot = null;
        });

        return;
      }

      for (QueryDocSnapMap doc in snapshot.docs) {
        final data = doc.data();
        data["id"] = doc.id;

        final section = Section.fromMap(data);
        _sections.add(section);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocumentSnapshot = snapshot.docs.last;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  /// On scroll notification
  bool onNotification(ScrollNotification notification) {
    if (notification.metrics.pixels < notification.metrics.maxScrollExtent) {
      return false;
    }

    if (_hasNext && !_loadingMore && _lastDocumentSnapshot != null) {
      fetchMoreSections();
    }

    return false;
  }

  /// Listen to the last Firestore query of this page.
  void listenSectionEvents(QueryMap query) {
    _sectionSubscription?.cancel();
    _sectionSubscription = query.snapshots().skip(1).listen(
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

  void navigateToAddSection() {
    Beamer.of(context).beamToNamed(
      AtelierLocationContent.addSectionRoute,
      routeState: {
        "sectionId": "",
      },
    );
  }

  void navigateToEditSectionPage(Section section) {
    NavigationStateHelper.section = section;

    final String route = AtelierLocationContent.editSectionRoute
        .replaceFirst(':sectionId', section.id);

    Beamer.of(context).beamToNamed(route, data: {
      "sectionId": section.id,
    });
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
      final section = Section.fromMap(data);
      _sections.insert(0, section);
    });
  }

  void onDeleteSection(targetLicense, targetIndex) {
    showDeleteConfirmDialog(targetLicense, targetIndex);
  }

  void onEditSection(Section targetSection, int targetIndex) {
    NavigationStateHelper.section = targetSection;
    Beamer.of(context).beamToNamed(
      AtelierLocationContent.addSectionRoute,
      routeState: {
        "sectionId": targetSection.id,
      },
    );
  }

  void onPopupMenuItemSelected(
    EnumSectionItemAction action,
    Section section,
    int index,
  ) {
    switch (action) {
      case EnumSectionItemAction.edit:
        navigateToEditSectionPage(section);
        break;
      case EnumSectionItemAction.delete:
        showDeleteConfirmDialog(section, index);
        break;
      default:
        break;
    }
  }

  /// Fire when a new document has been delete from Firestore.
  /// Delete the corresponding document from the UI.
  void onRemoveStreamingLicense(DocumentChangeMap documentChange) {
    setState(() {
      _sections.removeWhere(
        (license) => license.id == documentChange.doc.id,
      );
    });
  }

  void onTapSection(Section section, int index) {
    NavigationStateHelper.section = section;

    final String route = AtelierLocationContent.sectionRoute
        .replaceFirst(':sectionId', section.id);

    Beamer.of(context).beamToNamed(route, data: {
      "sectionId": section.id,
    });
  }

  /// Fire when a new document has been updated in Firestore.
  /// Update the corresponding document in the UI.
  void onUpdateStreamingLicense(DocumentChangeMap documentChange) {
    try {
      final data = documentChange.doc.data();
      if (data == null || !documentChange.doc.exists) {
        return;
      }

      final int index = _sections.indexWhere(
        (x) => x.id == documentChange.doc.id,
      );

      data["id"] = documentChange.doc.id;
      final updatedSection = Section.fromMap(data);

      setState(() {
        _sections.removeAt(index);
        _sections.insert(index, updatedSection);
      });
    } on Exception catch (error) {
      Utilities.logger.e(
        "The document with the id ${documentChange.doc.id} "
        "doesn't exist in the illustrations list.",
      );

      Utilities.logger.e(error);
    }
  }

  void showDeleteConfirmDialog(Section section, int index) {
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
                "section_delete".tr().toUpperCase(),
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
                    text: "section_delete_description".tr(),
                    style: Utilities.fonts.body(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: " ${section.name}",
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
            tryDeleteSection(section, index);
            Beamer.of(context).popRoute();
          },
          onCancel: Beamer.of(context).popRoute,
        );
      },
    );
  }

  void tryDeleteSection(Section section, int index) async {
    setState(() => _sections.removeAt(index));

    try {
      await FirebaseFirestore.instance
          .collection("sections")
          .doc(section.id)
          .delete();
    } catch (error) {
      setState(() => _sections.insert(index, section));
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }
}
