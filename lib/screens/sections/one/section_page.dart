import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/sections/one/section_page_body.dart';
import 'package:artbooking/types/firestore/doc_snapshot_stream_subscription.dart';
import 'package:artbooking/types/firestore/document_map.dart';
import 'package:artbooking/types/firestore/document_snapshot_map.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/section.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class SectionPage extends ConsumerStatefulWidget {
  const SectionPage({
    Key? key,
    required this.sectionId,
  }) : super(key: key);

  final String sectionId;

  @override
  ConsumerState<SectionPage> createState() => _LicensePageState();
}

class _LicensePageState extends ConsumerState<SectionPage> {
  /// Deleting this page section if true.
  bool _deleting = false;

  /// Fetching data bout this page section if true.
  bool _loading = false;

  /// Subscribes to Firestore document changes.
  DocSnapshotStreamSubscription? _sectionSubscription;

  /// Section's page data.
  Section _section = Section.empty();

  @override
  void initState() {
    super.initState();

    final Section? sectionFromNav = NavigationStateHelper.section;

    if (sectionFromNav != null && sectionFromNav.id == widget.sectionId) {
      _section = sectionFromNav;

      final DocumentMap query =
          FirebaseFirestore.instance.collection("sections").doc(_section.id);

      listenSectionEvents(query);
      return;
    }

    fetchSection();
  }

  @override
  void dispose() {
    _sectionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    return Scaffold(
      floatingActionButton: fab(),
      body: CustomScrollView(
        slivers: [
          ApplicationBar(),
          SectionPageBody(
            isMobileSize: isMobileSize,
            loading: _loading,
            deleting: _deleting,
            section: _section,
          ),
        ],
      ),
    );
  }

  Widget fab() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          onPressed: onEditSection,
          icon: Icon(UniconsLine.pen, size: 24.0),
          label: Text("section_edit".tr()),
          extendedTextStyle: Utilities.fonts.body(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: Colors.black,
          extendedPadding: EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: FloatingActionButton(
            heroTag: null,
            onPressed: onDeleteSection,
            child: Icon(UniconsLine.trash),
            backgroundColor: Theme.of(context).secondaryHeaderColor,
          ),
        ),
      ],
    );
  }

  void fetchSection() async {
    setState(() => _loading = true);

    try {
      final query = FirebaseFirestore.instance
          .collection("sections")
          .doc(widget.sectionId);

      final DocumentSnapshotMap docSnapshot = await query.get();
      final data = docSnapshot.data();

      if (!docSnapshot.exists || data == null) {
        return;
      }

      listenSectionEvents(query);

      data["id"] = docSnapshot.id;
      _section = Section.fromMap(data);
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _loading = false);
    }
  }

  void listenSectionEvents(DocumentReference<Map<String, dynamic>> query) {
    _sectionSubscription?.cancel();
    _sectionSubscription = query.snapshots().skip(1).listen((docSnapshot) {
      final Json? data = docSnapshot.data();

      if (!docSnapshot.exists || data == null) {
        context.canBeamBack
            ? Beamer.of(context).popRoute()
            : Beamer.of(context).beamToNamed(HomeLocation.route);

        return;
      }

      setState(() {
        data["id"] = docSnapshot.id;
        _section = Section.fromMap(data);
      });
    });
  }

  void onDeleteSection() {
    showDeleteConfirmDialog(_section);
  }

  void onEditSection() {
    NavigationStateHelper.section = _section;
    Beamer.of(context).beamToNamed(
      AtelierLocationContent.editSectionRoute.replaceFirst(
        ":sectionId",
        _section.id,
      ),
      routeState: {
        "sectionId": _section.id,
      },
    );
  }

  void showDeleteConfirmDialog(Section section) {
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
                        text: section.name,
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
            tryDeleteSection(section);
            Beamer.of(context).popRoute();
          },
          onCancel: Beamer.of(context).popRoute,
        );
      },
    );
  }

  void tryDeleteSection(Section section) async {
    setState(() => _deleting = true);

    try {
      await FirebaseFirestore.instance
          .collection("sections")
          .doc(section.id)
          .delete();

      Beamer.of(context).beamBack();
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _deleting = false);
    }
  }
}
