import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/dialogs/add_section_dialog.dart';
import 'package:artbooking/components/dialogs/colors_selector.dart';
import 'package:artbooking/components/dialogs/delete_dialog.dart';
import 'package:artbooking/components/dialogs/section_settings_dialog.dart';
import 'package:artbooking/components/dialogs/select_books_dialog.dart';
import 'package:artbooking/components/dialogs/select_illustrations_dialog.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/components/dialogs/input_dialog.dart';
import 'package:artbooking/screens/atelier/profile/profile_page_body.dart';
import 'package:artbooking/screens/atelier/profile/profile_page_empty.dart';
import 'package:artbooking/types/artistic_page.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/enums/enum_section_size.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/named_color.dart';
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
  bool _loading = false;

  /// True if there was an error while loading the user's profile page.
  bool _hasErrors = false;

  /// True if the target user has no page.
  bool _emptyProfile = false;

  /// Main user's artistic page.
  var _profilePage = ArtisticPage.empty();

  /// Listens to book's updates.
  QuerySnapshotStreamSubscription? _profilePageSubscription;

  /// Section's popup menu entries.
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
    PopupMenuItemIcon(
      icon: Icon(UniconsLine.setting),
      textLabel: "settings".tr(),
      value: EnumSectionAction.settings,
    ),
  ];

  @override
  void initState() {
    super.initState();
    tryFetchPage();
  }

  @override
  void dispose() {
    _profilePageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasErrors) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            ApplicationBar(),
            SliverToBoxAdapter(
              child: Center(
                child: Text(
                  "profile_page_loading_error".tr(),
                  style: Utilities.fonts.body(),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_emptyProfile) {
      return ProfilePageEmpty(
        username: getUserName(),
        onCreateProfilePage: tryCreatePage,
      );
    }

    if (_loading) {
      return Scaffold(
        body: LoadingView(
          sliver: false,
          title: Center(
            child: Text(
              "profile_page_loading".tr() + "...",
              style: Utilities.fonts.body(
                fontSize: 26.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    final String? userId = ref.watch(AppState.userProvider).firestoreUser?.id;
    final bool isOwner = userId == getUserId();

    return ProfilePageBody(
      userId: getUserId(),
      isOwner: isOwner,
      showBackButton: true,
      artisticPage: _profilePage,
      onAddSection: tryAddSection,
      popupMenuEntries: _popupMenuEntries,
      onPopupMenuItemSelected: onPopupMenuItemSelected,
      onShowAddSection: onShowAddSection,
      onShowIllustrationDialog: onShowIllustrationDialog,
      onUpdateSectionItems: tryUpdateSectionItems,
      onShowBookDialog: onShowBookDialog,
      onDropSection: onDropSection,
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

  void listenProfilePage(Query<Map<String, dynamic>> query) {
    _profilePageSubscription?.cancel();
    _profilePageSubscription = query.snapshots().skip(1).listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        return;
      }

      final doc = snapshot.docs.first;
      if (!doc.exists) {
        return;
      }

      setState(() {
        final data = doc.data();
        data["id"] = doc.id;
        _profilePage = ArtisticPage.fromMap(data);
      });
    }, onError: (error) {
      Utilities.logger.e(error);
    });
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
      case EnumSectionAction.renameTitle:
        showRenameTitleDialog(section, index);
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
      case EnumSectionAction.settings:
        onShowEditSectionSettings(section, index);
        break;
      case EnumSectionAction.editBackgroundColor:
        onShowEditSectionSettings(section, index, showDataMode: false);
        break;
      case EnumSectionAction.editTextColor:
        onShowColorDialog(section, index);
        break;
      case EnumSectionAction.editBorderColor:
        onShowBorderColorDialog(section, index);
        break;
      case EnumSectionAction.setSyncDataMode:
        tryUpdateDataFetchMode(
          section,
          index,
          EnumSectionDataMode.sync,
        );
        break;
      case EnumSectionAction.selectIllustrations:
        onShowIllustrationDialog(
          section: section,
          index: index,
          selectType: EnumSelectType.add,
        );
        break;
      case EnumSectionAction.selectBooks:
        onShowBookDialog(
          section: section,
          index: index,
          selectType: EnumSelectType.add,
        );
        break;
      default:
    }
  }

  void onShowAddSection() {
    showDialog(
      context: context,
      builder: (context) {
        return AddSectionDialog(
          onAddSection: tryAddSection,
        );
      },
    );
  }

  void onShowBookDialog({
    required Section section,
    required int index,
    required EnumSelectType selectType,
    int maxPick = 6,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SelectBooksDialog(
          autoFocus: true,
          maxPick: maxPick,
          userId: getUserId(),
          onValidate: selectType == EnumSelectType.add
              ? (items) => tryAddSectionItems(section, index, items)
              : (items) => tryUpdateSectionItems(section, index, items),
        );
      },
    );
  }

  void onShowColorDialog(Section section, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ThemedDialog(
          useRawDialog: true,
          titleValue: "text_color_update".tr(),
          body: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 420.0,
              maxWidth: 400.0,
            ),
            child: ColorsSelector(
              subtitle: "text_color_choose".tr(),
              selectedColorInt: section.textColor,
              onTapNamedColor: (NamedColor namedColor) {
                tryUpdateTextColor(namedColor, index, section);
                Beamer.of(context).popRoute();
              },
            ),
          ),
          textButtonValidation: "close".tr(),
          onCancel: Beamer.of(context).popRoute,
          onValidate: Beamer.of(context).popRoute,
        );
      },
    );
  }

  void onShowBorderColorDialog(Section section, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ThemedDialog(
          useRawDialog: true,
          titleValue: "border_color_update".tr(),
          body: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 420.0,
              maxWidth: 400.0,
            ),
            child: ColorsSelector(
              subtitle: "border_color_choose".tr(),
              selectedColorInt: section.textColor,
              onTapNamedColor: (NamedColor namedColor) {
                tryUpdateBorderColor(namedColor, index, section);
                Beamer.of(context).popRoute();
              },
            ),
          ),
          textButtonValidation: "close".tr(),
          onCancel: Beamer.of(context).popRoute,
          onValidate: Beamer.of(context).popRoute,
        );
      },
    );
  }

  void onShowIllustrationDialog({
    required Section section,
    required int index,
    required EnumSelectType selectType,
    int maxPick = 6,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SelectIllustrationsDialog(
          autoFocus: true,
          maxPick: maxPick,
          userId: getUserId(),
          onValidate: selectType == EnumSelectType.add
              ? (items) => tryAddSectionItems(section, index, items)
              : (items) => tryUpdateSectionItems(section, index, items),
        );
      },
    );
  }

  /// Show a popup to edit section settings (background color, fetch mode).
  void onShowEditSectionSettings(
    Section section,
    int index, {
    bool showDataMode = true,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SectionSettingsDialog(
          section: section,
          onValidate: tryUpdateBackgroundColor,
          index: index,
          showDataMode: showDataMode,
          onDataFetchModeChanged: tryUpdateDataFetchMode,
        );
      },
    );
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

  void showRenameTitleDialog(Section section, int index) {
    final _nameController = TextEditingController();

    _nameController.text = section.name;

    showDialog(
      context: context,
      builder: (context) => InputDialog.singleInput(
        nameController: _nameController,
        submitButtonValue: "rename".tr(),
        subtitleValue: "section_title_edit_description".tr(),
        titleValue: "title_edit".tr().toUpperCase(),
        onCancel: Beamer.of(context).popRoute,
        textInputAction: TextInputAction.newline,
        maxLines: null,
        validateOnEnter: false,
        onSubmitted: (value) {
          tryRenameTitle(
            section: section,
            index: index,
            name: _nameController.text,
          );
          Beamer.of(context).popRoute();
        },
      ),
    );
  }

  void tryAddSection(Section section) async {
    try {
      final dataMode = section.dataFetchModes.isNotEmpty
          ? section.dataFetchModes.first
          : EnumSectionDataMode.chosen;

      final Section editedSection = section.copyWith(
        dataFetchMode: dataMode,
        size: EnumSectionSize.large,
      );

      _profilePage.sections.add(editedSection);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(getUserId())
          .collection("user_pages")
          .doc(_profilePage.id)
          .update({
        "sections": _profilePage.sections.map((x) => x.toMap()).toList(),
      });

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void tryDeleteSection(Section section, int index) async {
    try {
      _profilePage.sections.removeAt(index);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(getUserId())
          .collection("user_pages")
          .doc(_profilePage.id)
          .update({
        "sections": _profilePage.sections.map((x) => x.toMap()).toList(),
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
    if (newIndex < 0 || newIndex >= _profilePage.sections.length) {
      return;
    }

    try {
      _profilePage.sections.removeAt(index);
      _profilePage.sections.insert(newIndex, section);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(getUserId())
          .collection("user_pages")
          .doc(_profilePage.id)
          .update({
        "sections": _profilePage.sections.map((x) => x.toMap()).toList(),
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

      _profilePage.sections.replaceRange(
        index,
        index + 1,
        [editedSection],
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(getUserId())
          .collection("user_pages")
          .doc(_profilePage.id)
          .update({
        "sections": _profilePage.sections.map((x) => x.toMap()).toList(),
      });

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void tryRenameTitle({
    required Section section,
    required int index,
    required String name,
  }) async {
    try {
      final editedSection = section.copyWith(
        name: name,
      );

      _profilePage.sections.replaceRange(
        index,
        index + 1,
        [editedSection],
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(getUserId())
          .collection("user_pages")
          .doc(_profilePage.id)
          .update({
        "sections": _profilePage.sections.map((x) => x.toMap()).toList(),
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
          .orderBy("created_at", descending: descending)
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
      _loading = true;
      _hasErrors = false;
      _emptyProfile = false;
    });

    try {
      final sections = await tryFetchSections();
      if (sections.isEmpty) return;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_pages")
          .add({
        'created_at': Timestamp.now(),
        'is_ctive': true,
        'is_draft': true,
        'name': 'Sample-${DateTime.now()}',
        'sections': sections.map((x) => x.toMap()).toList(),
        'type': 'profile',
        'updated_at': Timestamp.now(),
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

      setState(() => _hasErrors = true);
      return;
    }

    setState(() {
      _loading = true;
      _hasErrors = false;
      _emptyProfile = false;
    });

    try {
      final query = FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_pages")
          .where("type", isEqualTo: "profile")
          .limit(1);

      listenProfilePage(query);

      final snapshot = await query.get();

      if (snapshot.size == 0) {
        _emptyProfile = true;
        return;
      }

      final doc = snapshot.docs.first;
      final map = doc.data();
      map["id"] = doc.id;

      _profilePage = ArtisticPage.fromMap(map);
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
      _hasErrors = true;
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void tryUpdateDataFetchMode(
    Section section,
    int index,
    EnumSectionDataMode mode,
  ) async {
    try {
      final editedSection = section.copyWith(
        dataFetchMode: mode,
      );

      _profilePage.sections.replaceRange(
        index,
        index + 1,
        [editedSection],
      );

      final String userId = getUserId();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_pages")
          .doc(_profilePage.id)
          .update({
        "sections": _profilePage.sections.map((x) => x.toMap()).toList(),
      });

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void tryUpdateBackgroundColor(
    NamedColor selectedNamedColor,
    int index,
    Section section,
  ) async {
    try {
      final editedSection = section.copyWith(
        backgroundColor: selectedNamedColor.color.value,
      );

      _profilePage.sections.replaceRange(
        index,
        index + 1,
        [editedSection],
      );

      final String userId = getUserId();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_pages")
          .doc(_profilePage.id)
          .update({
        "sections": _profilePage.sections.map((x) => x.toMap()).toList(),
      });

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void tryUpdateBorderColor(
    NamedColor selectedNamedColor,
    int index,
    Section section,
  ) async {
    try {
      final editedSection = section.copyWith(
        borderColor: selectedNamedColor.color.value,
      );

      _profilePage.sections.replaceRange(
        index,
        index + 1,
        [editedSection],
      );

      await FirebaseFirestore.instance
          .collection("pages")
          .doc(_profilePage.id)
          .update({
        "sections": _profilePage.sections.map((x) => x.toMap()).toList(),
      });

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void tryUpdateTextColor(
    NamedColor selectedNamedColor,
    int index,
    Section section,
  ) async {
    try {
      final editedSection = section.copyWith(
        textColor: selectedNamedColor.color.value,
      );

      _profilePage.sections.replaceRange(
        index,
        index + 1,
        [editedSection],
      );

      final String userId = getUserId();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_pages")
          .doc(_profilePage.id)
          .update({
        "sections": _profilePage.sections.map((x) => x.toMap()).toList(),
      });

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void tryAddSectionItems(
    Section section,
    int index,
    List<String> newItems,
  ) async {
    try {
      List<String> combinedItems = section.items;
      combinedItems.addAll(newItems);

      if (combinedItems.length > 6) {
        combinedItems = combinedItems.sublist(0, 6);
      }

      final editedSection = section.copyWith(
        items: combinedItems,
      );

      _profilePage.sections.replaceRange(
        index,
        index + 1,
        [editedSection],
      );

      final String userId = getUserId();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_pages")
          .doc(_profilePage.id)
          .update({
        "sections": _profilePage.sections.map((x) => x.toMap()).toList(),
      });

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void tryUpdateSectionItems(
    Section section,
    int index,
    List<String> items,
  ) async {
    final editedSection = section.copyWith(
      items: items,
    );

    _profilePage.sections.replaceRange(
      index,
      index + 1,
      [editedSection],
    );

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(getUserId())
          .collection("user_pages")
          .doc(_profilePage.id)
          .update({
        "sections": _profilePage.sections.map((x) => x.toMap()).toList(),
      });

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void onDropSection(int dropTargetIndex, List<int> dragIndexes) async {
    final int firstDragIndex = dragIndexes.first;
    if (dropTargetIndex == firstDragIndex) {
      return;
    }

    final sections = _profilePage.sections;

    if (dropTargetIndex < 0 ||
        firstDragIndex < 0 ||
        dropTargetIndex >= sections.length ||
        firstDragIndex > sections.length) {
      return;
    }

    final dropTargetSection = sections.elementAt(dropTargetIndex);
    final dragSection = sections.elementAt(firstDragIndex);

    setState(() {
      _profilePage.sections[firstDragIndex] = dropTargetSection;
      _profilePage.sections[dropTargetIndex] = dragSection;
    });

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(getUserId())
          .collection("user_pages")
          .doc(_profilePage.id)
          .update({
        "sections": _profilePage.sections.map((x) => x.toMap()).toList(),
      });

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }
}
