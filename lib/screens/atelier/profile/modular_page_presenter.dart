import 'dart:async';

import 'package:artbooking/components/dialogs/add_section_dialog.dart';
import 'package:artbooking/components/dialogs/colors_selector.dart';
import 'package:artbooking/components/dialogs/delete_dialog.dart';
import 'package:artbooking/components/dialogs/section_settings_dialog.dart';
import 'package:artbooking/components/dialogs/select_artist_dialog.dart';
import 'package:artbooking/components/dialogs/select_books_dialog.dart';
import 'package:artbooking/components/dialogs/select_illustrations_dialog.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/components/dialogs/input_dialog.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/screens/atelier/profile/default_profile_page.dart';
import 'package:artbooking/screens/atelier/profile/modular_page_error.dart';
import 'package:artbooking/screens/atelier/profile/modular_page_loading.dart';
import 'package:artbooking/screens/atelier/profile/modular_page_body.dart';
import 'package:artbooking/types/firestore/document_map.dart';
import 'package:artbooking/types/firestore/document_snapshot_map.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/firestore/query_snap_map.dart';
import 'package:artbooking/types/modular_page.dart';
import 'package:artbooking/types/book/scale_factor.dart';
import 'package:artbooking/types/enums/enum_navigation_section.dart';
import 'package:artbooking/types/enums/enum_page_type.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/enums/enum_section_size.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/firestore/doc_snapshot_stream_subscription.dart';
import 'package:artbooking/types/illustration/sized_illustration.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/named_color.dart';
import 'package:artbooking/types/popup_item_section.dart';
import 'package:artbooking/types/section.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class ModularPagePresenter extends ConsumerStatefulWidget {
  const ModularPagePresenter({
    Key? key,
    required this.pageId,
    required this.userId,
    required this.pageType,
  }) : super(key: key);

  /// Page unique identifier.
  /// If this parameter is filled, this page is a part of this app.
  /// May be empty if [userId] is populated.
  final String pageId;

  /// Page's owner id.
  /// If this parameter is filled, this page belongs to an user.
  /// May be empty if [pageId] is populated.
  final String userId;

  /// Either home page or an user page/
  final EnumPageType pageType;

  @override
  ConsumerState<ModularPagePresenter> createState() => _ModularPageState();
}

class _ModularPageState extends ConsumerState<ModularPagePresenter> {
  /// True if this page is currently loading.
  bool _loading = false;

  /// True if there was an error while loading the user's profile page.
  bool _hasErrors = false;

  /// True if the target user has no page.
  bool _isEmpty = false;

  /// If true, the current user is an admin and can add, remove, and edit
  /// this page sections.
  bool _editMode = true;

  /// If true, Floating Action Button will be displayed.
  bool _showFab = true;

  /// If true, a Floating Action Button to scroll to top will be displayed.
  bool _showFabToTop = false;

  /// Show profile page username if true, and if it's a profile page type.
  bool _showAppBarTitle = false;

  /// If true, a section is being dragged from its original position.
  bool _isDraggingSection = false;

  /// Previous scroll offset.
  /// Works with [_pageScrollController] to show/hide FAB.
  double _previousOffset = 0.0;

  /// Run a periodic timer to continuously scroll in a direction
  /// (without necessarly moving the cursor).
  Timer? _scrollTimer;

  /// Modular page data.
  ModularPage _modularPage = ModularPage.empty();

  /// Listens to book's updates.
  DocSnapshotStreamSubscription? _modularPageSubscription;

  /// Section's popup menu entries.
  final List<PopupMenuItemSection> _popupMenuEntries = [
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.edit_alt),
      textLabel: "rename".tr(),
      value: EnumSectionAction.rename,
    ),
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.arrow_up),
      textLabel: "move_up".tr(),
      value: EnumSectionAction.moveUp,
      delay: const Duration(milliseconds: 25),
    ),
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.arrow_down),
      textLabel: "move_down".tr(),
      value: EnumSectionAction.moveDown,
      delay: const Duration(milliseconds: 50),
    ),
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.trash),
      textLabel: "delete".tr(),
      value: EnumSectionAction.delete,
      delay: const Duration(milliseconds: 75),
    ),
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.setting),
      textLabel: "settings".tr(),
      value: EnumSectionAction.settings,
      delay: const Duration(milliseconds: 100),
    ),
  ];

  /// Scroll controller to move inside the page.
  final ScrollController _pageCcrollController = ScrollController();

  String _username = "";

  @override
  void initState() {
    super.initState();

    _modularPage = _modularPage.copyWith(
      userId: widget.userId,
    );

    loadPreferences();
    tryFetchPage();
  }

  @override
  void dispose() {
    _modularPageSubscription?.cancel();
    _scrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    if (_hasErrors) {
      return ModularPageError(
        isMobileSize: isMobileSize,
        onTryFetchPage: tryFetchPage,
        pageType: widget.pageType,
      );
    }

    if (_loading) {
      return ModularPageLoading(
        pageType: widget.pageType,
      );
    }

    final UserFirestore? userFirestore =
        ref.watch(AppState.userProvider).firestoreUser;

    final String? userId = userFirestore?.id;
    final bool canManagePages = userFirestore?.rights.canManagePages ?? false;

    final bool isPageOwner = userId == getUserId();

    final bool isOwner =
        widget.pageType == EnumPageType.profile ? isPageOwner : canManagePages;

    if (_isEmpty) {
      return DefaultProfilePage(
        userId: getUserId(),
        isMobileSize: isMobileSize,
        isOwner: isOwner,
        onCreateProfilePage: tryCreatePage,
      );
    }

    return ModularPageBody(
      editMode: _editMode,
      isMobileSize: isMobileSize,
      isOwner: isOwner,
      modularPage: _modularPage,
      onAddSection: tryAddSection,
      onDragSectionStarted: onDragSectionStarted,
      onDraggableSectionCanceled: onDraggableSectionCanceled,
      onDropSection: onDropSection,
      onDragSectionCompleted: onDragSectionCompleted,
      onDragSectionEnd: onDragSectionEnd,
      onDropSectionInBetween: onDropSectionInBetween,
      onNavigateFromSection: onNavigateFromSection,
      onPageScroll: onPageScroll,
      onPointerMove: onPointerMove,
      onPopupMenuItemSelected: onPopupMenuItemSelected,
      onShowAddSection: onShowAddSection,
      onShowBookDialog: onShowBookDialog,
      onShowIllustrationDialog: onShowIllustrationDialog,
      onToggleEditMode: onToggleEditMode,
      onUpdateSectionItems: tryUpdateSectionItems,
      pageType: widget.pageType,
      popupMenuEntries: _popupMenuEntries,
      scrollController: _pageCcrollController,
      showAppBarTitle: _showAppBarTitle,
      showFab: _showFab,
      showNavToTopFab: _showFabToTop,
      userId: getUserId(),
      username: _username,
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

  Future<void> fetchUsername() async {
    try {
      final DocumentSnapshotMap snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(_modularPage.userId)
          .collection("user_public_fields")
          .doc("base")
          .get();

      final Json? data = snapshot.data();

      if (!snapshot.exists || data == null) {
        return;
      }

      data["id"] = _modularPage.userId;
      final UserFirestore userFirestore = UserFirestore.fromMap(data);
      _username = userFirestore.name;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  String getUserId() {
    String userId = _modularPage.userId;
    if (userId.isEmpty) {
      userId = ref.read(AppState.userProvider).authUser?.uid ?? '';
    }

    return userId;
  }

  String getUserName() {
    return ref.read(AppState.userProvider).firestoreUser?.name ?? '';
  }

  void listenModularPage(DocumentReference<Map<String, dynamic>> query) {
    _modularPageSubscription?.cancel();
    _modularPageSubscription = query.snapshots().skip(1).listen((snapshot) {
      final Json? data = snapshot.data();

      if (!snapshot.exists || data == null) {
        return;
      }

      setState(() {
        data["id"] = snapshot.id;
        _modularPage = ModularPage.fromMap(data);
      });
    }, onError: (error) {
      Utilities.logger.e(error);
    });
  }

  void loadPreferences() {
    setState(() {
      _editMode = Utilities.storage.getModularPageEditMode();
    });
  }

  void onDropSection(int dropTargetIndex, List<int> dragIndexes) async {
    final int firstDragIndex = dragIndexes.first;
    if (dropTargetIndex == firstDragIndex) {
      return;
    }

    final List<Section> sections = _modularPage.sections;

    if (dropTargetIndex < 0 ||
        firstDragIndex < 0 ||
        dropTargetIndex >= sections.length ||
        firstDragIndex > sections.length) {
      return;
    }

    final Section dropTargetSection = sections.elementAt(dropTargetIndex);
    final Section dragSection = sections.elementAt(firstDragIndex);

    setState(() {
      _modularPage.sections[firstDragIndex] = dropTargetSection;
      _modularPage.sections[dropTargetIndex] = dragSection;
    });

    try {
      final bool success = await updateSectionData();
      if (!success) {
        throw ErrorDescription("modular_page_error_update".tr());
      }

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void onDropSectionInBetween(
    int dropTargetIndex,
    List<int> dragIndexes,
  ) async {
    final int firstDragIndex = dragIndexes.first;
    if (dropTargetIndex == firstDragIndex) {
      return;
    }

    final List<Section> sections = _modularPage.sections;

    if (dropTargetIndex < 0 ||
        firstDragIndex < 0 ||
        dropTargetIndex >= sections.length ||
        firstDragIndex > sections.length) {
      return;
    }

    final Section dragSection = sections.removeAt(firstDragIndex);

    setState(() {
      _modularPage.sections.insert(dropTargetIndex, dragSection);
    });

    try {
      final bool success = await updateSectionData();
      if (!success) {
        throw ErrorDescription("modular_page_error_update".tr());
      }

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void onNavigateFromSection(EnumNavigationSection enumNavigationSection) {
    switch (enumNavigationSection) {
      case EnumNavigationSection.books:
        onNavigateToBooksPage();
        break;
      case EnumNavigationSection.illustrations:
        onNavigateToIllustrationsPage();
        break;
      default:
    }
  }

  void onNavigateToBooksPage() {
    if (_modularPage.type == EnumPageType.profile) {
      final String userId = _modularPage.userId;

      if (_modularPage.userId.isEmpty) {
        final String message = "modular_page_navigate_books_error".tr();

        Utilities.logger.e(message);
        context.showErrorBar(
          content: Text(message),
        );
      }

      Beamer.of(context).beamToNamed(
        HomeLocation.userBooksRoute.replaceFirst(":userId", userId),
        routeState: {
          "userId": userId,
        },
      );

      return;
    }

    if (_modularPage.type == EnumPageType.home) {
      Beamer.of(context).beamToNamed("/books");
      return;
    }
  }

  void onNavigateToIllustrationsPage() {
    if (_modularPage.type == EnumPageType.profile) {
      final String userId = _modularPage.userId;

      if (_modularPage.userId.isEmpty) {
        final String message = "modular_page_navigate_illustrations_error".tr();

        Utilities.logger.e(message);
        context.showErrorBar(
          content: Text(message),
        );
      }

      Beamer.of(context).beamToNamed(
        HomeLocation.userIllustrationsRoute.replaceFirst(":userId", userId),
        routeState: {
          "userId": userId,
        },
      );
      return;
    }

    if (_modularPage.type == EnumPageType.home) {
      Beamer.of(context).beamToNamed("/illustrations");
      return;
    }
  }

  void onPageScroll(double offset) {
    updateAppBarTitleVisibility(offset);

    final bool scrollingDown = offset - _previousOffset > 0;
    _previousOffset = offset;

    _showFabToTop = offset == 0.0 ? false : true;

    if (scrollingDown) {
      if (!_showFab) {
        return;
      }

      setState(() => _showFab = false);
      return;
    }

    if (offset == 0.0) {
      setState(() => _showFabToTop = false);
    }

    if (_showFab) {
      return;
    }

    setState(() => _showFab = true);
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
      case EnumSectionAction.selectArtists:
        onShowArtistDialog(
          section: section,
          index: index,
          selectType: EnumSelectType.add,
        );
        break;
      default:
    }
  }

  void onShowAddSection(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AddSectionDialog(
          index: index,
          onAddSection: tryAddSection,
        );
      },
    );
  }

  void onShowArtistDialog({
    required Section section,
    required int index,
    required EnumSelectType selectType,
    int maxPick = 6,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final UserFirestore? user =
            ref.read(AppState.userProvider).firestoreUser;

        final String userId = user?.id ?? "";
        final bool canManagePages = user?.rights.canManagePages ?? false;

        return SelectArtistDialog(
          autoFocus: true,
          maxPick: maxPick,
          userId: userId,
          admin: canManagePages,
          onValidate: selectType == EnumSelectType.add
              ? (items) => tryAddSectionItems(section, index, items)
              : (items) => tryUpdateSectionItems(section, index, items),
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
        final UserFirestore? user =
            ref.read(AppState.userProvider).firestoreUser;

        final String userId = user?.id ?? "";
        final bool canManagePages = user?.rights.canManagePages ?? false;

        return SelectBooksDialog(
          autoFocus: true,
          maxPick: maxPick,
          userId: userId,
          admin: canManagePages,
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
              selectedColorInt: section.borderColor,
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
        final UserFirestore? user =
            ref.read(AppState.userProvider).firestoreUser;

        final String? userId = user?.id;
        final bool canManagePages = user?.rights.canManagePages ?? false;

        return SelectIllustrationsDialog(
          autoFocus: true,
          admin: canManagePages,
          maxPick: maxPick,
          userId: userId ?? "",
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

  void onToggleEditMode() {
    final UserFirestore? user = ref.read(AppState.userProvider).firestoreUser;
    final bool canManagePages = user?.rights.canManagePages ?? false;

    if (!canManagePages) {
      return;
    }

    setState(() {
      _editMode = !_editMode;
    });

    Utilities.storage.saveModularPageEditMode(_editMode);
  }

  Future<void> popuplateUsername() async {
    final UserFirestore? firestoreUser =
        ref.read(AppState.userProvider).firestoreUser;

    final String? userId = firestoreUser?.id;

    if (firestoreUser != null && userId != null) {
      _username = firestoreUser.name;
    }

    await fetchUsername();
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

  void tryAddSection(Section section, int index) async {
    try {
      final EnumSectionDataMode dataMode = section.dataFetchModes.isNotEmpty
          ? section.dataFetchModes.first
          : EnumSectionDataMode.chosen;

      final Section editedSection = section.copyWith(
        dataFetchMode: dataMode,
        size: EnumSectionSize.large,
      );

      if (index == -1) {
        _modularPage.sections.add(editedSection);
      } else {
        _modularPage.sections.insert(index, editedSection);
      }

      final bool success = await updateSectionData();
      if (!success) {
        throw ErrorDescription("modular_page_error_update".tr());
      }

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void tryCreatePage() async {
    final String userId = getUserId();

    if (userId.isEmpty) {
      context.showErrorBar(
        content: Text(
          "profile_page_create_error_empty_id".tr(),
        ),
      );

      setState(() => _hasErrors = true);
      return;
    }

    setState(() {
      _loading = true;
      _hasErrors = false;
      _isEmpty = false;
    });

    try {
      final sections = await tryFetchSections();
      if (sections.isEmpty) return;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_pages")
          .add({
        "created_at": Timestamp.now(),
        "is_ctive": true,
        "is_draft": false,
        "name": "Sample-${DateTime.now()}",
        "sections": sections.map((x) => x.toMap()).toList(),
        "type": "profile",
        "updated_at": Timestamp.now(),
        "user_id": userId,
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
      _hasErrors = true;
    } finally {
      tryFetchPage();
    }
  }

  void tryDeleteSection(Section section, int index) async {
    try {
      _modularPage.sections.removeAt(index);

      final bool success = await updateSectionData();
      if (!success) {
        throw ErrorDescription("modular_page_error_update".tr());
      }

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
    if (newIndex < 0 || newIndex >= _modularPage.sections.length) {
      return;
    }

    try {
      _modularPage.sections.removeAt(index);
      _modularPage.sections.insert(newIndex, section);

      final bool success = await updateSectionData();
      if (!success) {
        throw ErrorDescription("modular_page_error_update".tr());
      }

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
      final Section editedSection = section.copyWith(
        description: description,
        name: name,
      );

      _modularPage.sections.replaceRange(
        index,
        index + 1,
        [editedSection],
      );

      final bool success = await updateSectionData();
      if (!success) {
        throw ErrorDescription("modular_page_error_update".tr());
      }

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
      final Section editedSection = section.copyWith(
        name: name,
      );

      _modularPage.sections.replaceRange(
        index,
        index + 1,
        [editedSection],
      );

      final bool success = await updateSectionData();
      if (!success) {
        throw ErrorDescription("modular_page_error_update".tr());
      }

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
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("sections")
          .limit(limit)
          .orderBy("created_at", descending: descending)
          .get();

      if (snapshot.size == 0) {
        return sections;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
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

  Future<DocumentMap?> getQuery() async {
    if (widget.pageType == EnumPageType.profile) {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("user_pages")
          .where("type", isEqualTo: "profile")
          .limit(1)
          .get();

      if (snapshot.size == 0) {
        _isEmpty = true;
        return null;
      }

      final QueryDocSnapMap doc = snapshot.docs.first;

      return FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("user_pages")
          .doc(doc.id);
    }

    return FirebaseFirestore.instance.collection("pages").doc(widget.pageId);
  }

  void tryFetchPage() async {
    if (widget.pageId.isEmpty && widget.userId.isEmpty) {
      context.showErrorBar(
        content: Text("modular_page_error_empty_parameters".tr()),
      );

      setState(() => _hasErrors = true);
      return;
    }

    setState(() {
      _loading = true;
      _hasErrors = false;
      _isEmpty = false;
    });

    try {
      final DocumentMap? query = await getQuery();
      if (query == null) {
        _isEmpty = true;
        return;
      }

      listenModularPage(query);
      final DocumentSnapshotMap snapshot = await query.get();

      if (!snapshot.exists) {
        _isEmpty = true;
        return;
      }

      final Json? map = snapshot.data();
      if (map == null) {
        return;
      }

      map["id"] = snapshot.id;
      _modularPage = ModularPage.fromMap(map);

      if (widget.pageType == EnumPageType.profile) {
        await popuplateUsername();
      }
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
      _hasErrors = true;
    } finally {
      setState(() => _loading = false);
    }
  }

  void tryUpdateDataFetchMode(
    Section section,
    int index,
    EnumSectionDataMode mode,
  ) async {
    try {
      final Section editedSection = section.copyWith(
        dataFetchMode: mode,
      );

      _modularPage.sections.replaceRange(
        index,
        index + 1,
        [editedSection],
      );

      final bool success = await updateSectionData();
      if (!success) {
        throw ErrorDescription("modular_page_error_update".tr());
      }

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
      final Section editedSection = section.copyWith(
        backgroundColor: selectedNamedColor.color.value,
      );

      _modularPage.sections.replaceRange(
        index,
        index + 1,
        [editedSection],
      );

      final bool success = await updateSectionData();
      if (!success) {
        throw ErrorDescription("modular_page_error_update".tr());
      }

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
      final Section editedSection = section.copyWith(
        borderColor: selectedNamedColor.color.value,
      );

      _modularPage.sections.replaceRange(
        index,
        index + 1,
        [editedSection],
      );

      final bool success = await updateSectionData();
      if (!success) {
        throw ErrorDescription("modular_page_error_update".tr());
      }

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
      final Section editedSection = section.copyWith(
        textColor: selectedNamedColor.color.value,
      );

      _modularPage.sections.replaceRange(
        index,
        index + 1,
        [editedSection],
      );

      final bool success = await updateSectionData();
      if (!success) {
        throw ErrorDescription("modular_page_error_update".tr());
      }

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

      if (combinedItems.length > section.maxItems) {
        combinedItems = combinedItems.sublist(0, section.maxItems);
      }

      Section editedSection = section.copyWith(
        items: combinedItems,
      );

      if (section.hasComplexItems) {
        List<SizedIllustration> addedComplexItems = newItems
            .map(
              (String id) => SizedIllustration(
                id: id,
                scaleFactor: ScaleFactor(),
              ),
            )
            .toList();

        if (addedComplexItems.length > section.maxItems) {
          addedComplexItems = addedComplexItems.sublist(0, section.maxItems);
        }

        editedSection = editedSection.copyWith(
          complexItems: editedSection.complexItems..addAll(addedComplexItems),
        );
      }

      _modularPage.sections.replaceRange(
        index,
        index + 1,
        [editedSection],
      );

      final bool success = await updateSectionData();
      if (!success) {
        throw ErrorDescription("modular_page_error_update".tr());
      }

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
    final Section editedSection = section.copyWith(
      items: items,
    );

    _modularPage.sections.replaceRange(
      index,
      index + 1,
      [editedSection],
    );

    try {
      final bool success = await updateSectionData();
      if (!success) {
        throw ErrorDescription("modular_page_error_update".tr());
      }

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void onDragSectionCompleted() {
    _isDraggingSection = false;
  }

  void onDragSectionEnd(DraggableDetails draggableDetails) {
    _isDraggingSection = false;
  }

  void onDraggableSectionCanceled(Velocity velocity, Offset offset) {
    _isDraggingSection = false;
  }

  void onDragSectionStarted() {
    _isDraggingSection = true;
  }

  /// Callback fired when a pointer is down and moves.
  void onPointerMove(PointerMoveEvent pointerMoveEvent) {
    if (!_isDraggingSection) {
      _scrollTimer?.cancel();
      return;
    }

    final int duration = 50;
    final double jumpOffset = 42.0;
    final double dy = pointerMoveEvent.position.dy;

    final double scrollTreshold = 100.0;

    if (dy < scrollTreshold && _pageCcrollController.offset > 0) {
      _scrollTimer?.cancel();
      _scrollTimer = Timer.periodic(
        Duration(milliseconds: duration),
        (Timer timer) {
          _pageCcrollController.animateTo(
            _pageCcrollController.offset - jumpOffset,
            duration: Duration(milliseconds: duration),
            curve: Curves.easeIn,
          );

          if (_pageCcrollController.position.outOfRange) {
            _scrollTimer?.cancel();
          }
        },
      );

      return;
    }

    final double windowHeight = MediaQuery.of(context).size.height;

    if (dy >= windowHeight - scrollTreshold &&
        !_pageCcrollController.position.atEdge) {
      _scrollTimer?.cancel();
      _scrollTimer = Timer.periodic(
        Duration(milliseconds: duration),
        (Timer timer) {
          _pageCcrollController.animateTo(
            _pageCcrollController.offset + jumpOffset,
            duration: Duration(milliseconds: duration),
            curve: Curves.easeIn,
          );

          if (_pageCcrollController.position.outOfRange) {
            _scrollTimer?.cancel();
          }
        },
      );
      return;
    }

    _scrollTimer?.cancel();
  }

  Future<bool> updateSectionData() async {
    if (widget.pageType == EnumPageType.profile) {
      return updateUserPageData();
    }

    return updateHomePageData();
  }

  Future<bool> updateHomePageData() async {
    try {
      await FirebaseFirestore.instance
          .collection("pages")
          .doc(_modularPage.id)
          .update({
        "sections": _modularPage.sections.map((x) => x.toMap()).toList(),
      });

      return true;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
      return false;
    }
  }

  Future<bool> updateUserPageData() async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("user_pages")
          .doc(_modularPage.id)
          .update({
        "sections": _modularPage.sections.map((x) => x.toMap()).toList(),
      });

      return true;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
      return false;
    }
  }

  void updateAppBarTitleVisibility(double offset) {
    final double treshold = 400.0;

    if (_showAppBarTitle && offset < treshold) {
      setState(() => _showAppBarTitle = false);
    }

    if (!_showAppBarTitle && offset >= treshold) {
      setState(() => _showAppBarTitle = true);
    }
  }
}
