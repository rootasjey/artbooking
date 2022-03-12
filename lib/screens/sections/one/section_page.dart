import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/sections/edit/edit_section_page.dart';
import 'package:artbooking/screens/sections/one/section_page_body.dart';
import 'package:artbooking/types/firestore/doc_snapshot_stream_subscription.dart';
import 'package:artbooking/types/firestore/document_snapshot_map.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/section.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
  bool _deleting = false;
  bool _loading = false;

  DocSnapshotStreamSubscription? _sectionSubscription;

  var _section = Section.empty();

  @override
  void initState() {
    super.initState();

    final Section? sectionFromNav = NavigationStateHelper.section;

    if (sectionFromNav != null && sectionFromNav.id == widget.sectionId) {
      _section = sectionFromNav;

      final query =
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
    return Scaffold(
      floatingActionButton: fab(),
      body: CustomScrollView(
        slivers: [
          ApplicationBar(),
          SectionPageBody(
            loading: _loading,
            deleting: _deleting,
            section: _section,
            onEditSection: onEditSection,
            onDeleteSection: onDeleteSection,
          ),
        ],
      ),
    );
  }

  Widget fab() {
    return FloatingActionButton(
      onPressed: onEditSection,
      child: Icon(UniconsLine.edit),
      backgroundColor: Theme.of(context).secondaryHeaderColor,
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
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => EditSectionPage(
        section: _section,
      ),
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
                style: Utilities.fonts.style(
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
                    style: Utilities.fonts.style(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: section.name,
                        style: Utilities.fonts.style(
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
