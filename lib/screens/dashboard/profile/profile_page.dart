import 'package:artbooking/components/dialogs/delete_dialog.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/components/dialogs/input_dialog.dart';
import 'package:artbooking/screens/dashboard/profile/profile_page_body.dart';
import 'package:artbooking/screens/dashboard/profile/profile_page_empty.dart';
import 'package:artbooking/screens/dashboard/profile/profile_page_error.dart';
import 'package:artbooking/types/artistic_page.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/enums/enum_section_size.dart';
import 'package:artbooking/types/section.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  final String userId;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  /// True if this page is currently loading.
  bool _isLoading = false;

  /// True if there was an error while loading the user's profile page.
  bool _hasErrors = false;

  /// True if the target user has no page.
  bool _emptyProfile = false;

  /// Main user's artistic page.
  var _artisticPage = ArtisticPage.empty();

  final _popupMenuEntries = <PopupMenuItemIcon<EnumSectionAction>>[
    PopupMenuItemIcon(
      icon: Icon(UniconsLine.edit_alt),
      textLabel: "rename".tr(),
      value: EnumSectionAction.rename,
    ),
    PopupMenuItemIcon(
      icon: Icon(UniconsLine.arrow_up),
      textLabel: "move_up".tr(),
      value: EnumSectionAction.moveUp,
    ),
    PopupMenuItemIcon(
      icon: Icon(UniconsLine.arrow_down),
      textLabel: "move_down".tr(),
      value: EnumSectionAction.moveDown,
    ),
    PopupMenuItemIcon(
      icon: Icon(UniconsLine.trash),
      textLabel: "delete".tr(),
      value: EnumSectionAction.delete,
    ),
  ];

  @override
  void initState() {
    super.initState();
    tryFetchPage();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasErrors) {
      return ProfilePageError();
    }

    if (_emptyProfile) {
      return ProfilePageEmpty(
        username: getUserName(),
        onCreateProfilePage: tryCreatePage,
      );
    }

    if (_isLoading) {
      return Scaffold(
        body: LoadingView(
          sliver: false,
          title: Center(
            child: Text(
              "profile_page_loading".tr() + "...",
              style: Utilities.fonts.style(
                fontSize: 26.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return ProfilePageBody(
      userId: getUserId(),
      artisticPage: _artisticPage,
      onAddSection: tryAddSection,
      popupMenuEntries: _popupMenuEntries,
      onPopupMenuItemSelected: onPopupMenuItemSelected,
    );
  }

  String getUserId() {
    String userId = widget.userId;
    if (userId.isEmpty) {
      userId = ref.read(AppState.userProvider).authUser?.uid ?? '';
    }

    return userId;
  }

  String getUserName() {
    return ref.read(AppState.userProvider).firestoreUser?.name ?? '';
  }

  void onPopupMenuItemSelected(
    EnumSectionAction action,
    int index,
    Section section,
  ) {
    switch (action) {
      case EnumSectionAction.rename:
        showRenameSectionDialog(section, index);
        break;
      case EnumSectionAction.moveUp:
        tryMoveSection(
          section: section,
          index: index,
          newIndex: index - 1,
        );
        break;
      case EnumSectionAction.moveDown:
        tryMoveSection(
          section: section,
          index: index,
          newIndex: index + 1,
        );
        break;
      case EnumSectionAction.delete:
        confirmDeleteSection(section, index);
        break;
      default:
    }
  }

  /// Show a dialog to confirm a single section deletion.
  void confirmDeleteSection(Section section, int index) async {
    showDialog(
      context: context,
      builder: (context) {
        return DeleteDialog(
          titleValue: "section_delete".tr(),
          descriptionValue: "section_delete_description".tr(),
          onValidate: () => tryDeleteSection(section, index),
        );
      },
    );
  }

  void showRenameSectionDialog(Section section, int index) {
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();

    _nameController.text = section.name;
    _descriptionController.text = section.description;

    showDialog(
      context: context,
      builder: (context) => InputDialog(
        descriptionController: _descriptionController,
        nameController: _nameController,
        submitButtonValue: "rename".tr(),
        subtitleValue: "section_rename_description".tr(),
        titleValue: "section_rename".tr().toUpperCase(),
        onCancel: Beamer.of(context).popRoute,
        onSubmitted: (value) {
          tryRenameSection(
            section: section,
            index: index,
            name: _nameController.text,
            description: _descriptionController.text,
          );
          Beamer.of(context).popRoute();
        },
      ),
    );
  }

  void tryAddSection(Section section) async {
    try {
      final Section editedSection = section.copyWith(
        mode: EnumSectionDataMode.lastUpdated,
        size: EnumSectionSize.large,
      );

      _artisticPage.sections.add(editedSection);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(getUserId())
          .collection("pages")
          .doc(_artisticPage.id)
          .update({
        "sections": _artisticPage.sections.map((x) => x.toMap()).toList(),
      });

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void tryDeleteSection(Section section, int index) async {
    try {
      _artisticPage.sections.removeAt(index);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(getUserId())
          .collection("pages")
          .doc(_artisticPage.id)
          .update({
        "sections": _artisticPage.sections.map((x) => x.toMap()).toList(),
      });

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void tryMoveSection({
    required Section section,
    required int index,
    required int newIndex,
  }) async {
    if (newIndex < 0 || newIndex >= _artisticPage.sections.length) {
      return;
    }

    try {
      _artisticPage.sections.removeAt(index);
      _artisticPage.sections.insert(newIndex, section);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(getUserId())
          .collection("pages")
          .doc(_artisticPage.id)
          .update({
        "sections": _artisticPage.sections.map((x) => x.toMap()).toList(),
      });

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void tryRenameSection({
    required Section section,
    required int index,
    required String name,
    required String description,
  }) async {
    try {
      final editedSection = section.copyWith(
        description: description,
        name: name,
      );

      _artisticPage.sections.replaceRange(
        index,
        index + 1,
        [editedSection],
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(getUserId())
          .collection("pages")
          .doc(_artisticPage.id)
          .update({
        "sections": _artisticPage.sections.map((x) => x.toMap()).toList(),
      });

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  Future<List<Section>> tryFetchSections({
    int limit = 3,
    bool descending = false,
  }) async {
    final List<Section> sections = [];

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("sections")
          .limit(limit)
          .orderBy("createdAt", descending: descending)
          .get();

      if (snapshot.size == 0) {
        return sections;
      }

      for (var doc in snapshot.docs) {
        final data = doc.data();
        data["id"] = doc.id;
        sections.add(Section.fromMap(data));
      }
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
      _hasErrors = true;
    } finally {
      return sections;
    }
  }

  void tryCreatePage() async {
    final userId = getUserId();
    if (userId.isEmpty) {
      context.showErrorBar(
        content: Text(
          "Hu ho. The was no user id passer as an argument to this path."
          " Please provid a valide id.",
        ),
      );

      setState(() {
        _hasErrors = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasErrors = false;
      _emptyProfile = false;
    });

    try {
      final sections = await tryFetchSections();
      if (sections.isEmpty) return;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("pages")
          .add({
        "createdAt": Timestamp.now(),
        "isActive": true,
        "isDraft": true,
        "name": "Sample-${DateTime.now()}",
        "sections": sections.map((x) => x.toMap()).toList(),
        "type": "profile",
        "updatedAt": Timestamp.now(),
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
      _hasErrors = true;
    } finally {
      tryFetchPage();
    }
  }

  void tryFetchPage() async {
    final userId = getUserId();
    if (userId.isEmpty) {
      context.showErrorBar(
        content: Text("error_user_no_id".tr()),
      );

      setState(() {
        _hasErrors = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasErrors = false;
      _emptyProfile = false;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("pages")
          .where("type", isEqualTo: "profile")
          .limit(1)
          .get();

      if (snapshot.size == 0) {
        _emptyProfile = true;
        return;
      }

      final doc = snapshot.docs.first;
      final map = doc.data();
      map["id"] = doc.id;

      _artisticPage = ArtisticPage.fromMap(map);
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
      _hasErrors = true;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
