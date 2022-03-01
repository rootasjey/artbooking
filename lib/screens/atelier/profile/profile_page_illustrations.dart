import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/firestore/doc_snap_map.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/section.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ProfilePageIllustrations extends StatefulWidget {
  const ProfilePageIllustrations({
    Key? key,
    required this.title,
    required this.mode,
    required this.userId,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
    required this.index,
    required this.section,
    this.isLast = false,
  }) : super(key: key);

  final bool isLast;
  final EnumSectionDataMode mode;
  final void Function(EnumSectionAction, int, Section)? onPopupMenuItemSelected;
  final int index;
  final List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries;

  /// Section's position in the layout (e.g. 0 is the first).
  final Section section;
  final String title;
  final String userId;

  @override
  State<ProfilePageIllustrations> createState() =>
      _ProfilePageIllustrationsState();
}

class _ProfilePageIllustrationsState extends State<ProfilePageIllustrations> {
  bool _isLoading = false;

  List<Illustration> _illustrations = [];

  @override
  initState() {
    super.initState();
    fetchIllustrations();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed([]),
      );
    }

    var popupMenuEntries = widget.popupMenuEntries;

    if (widget.index == 0) {
      popupMenuEntries = popupMenuEntries.toList();
      popupMenuEntries.removeWhere((x) => x.value == EnumSectionAction.moveUp);
    }

    if (widget.isLast) {
      popupMenuEntries = popupMenuEntries.toList();
      popupMenuEntries
          .removeWhere((x) => x.value == EnumSectionAction.moveDown);
    }

    int index = -1;

    return SliverToBoxAdapter(
      child: FadeInY(
        beginY: 24.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 90.9,
            vertical: 24.0,
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  children: [
                    Opacity(
                      opacity: 0.6,
                      child: Text(
                        widget.title.toUpperCase(),
                        style: Utilities.fonts.style(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 200.0,
                      child: Divider(
                        color: Theme.of(context).secondaryHeaderColor,
                        thickness: 4.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 34.0),
                      child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        mainAxisSpacing: 24.0,
                        crossAxisSpacing: 24.0,
                        children: _illustrations.map((illustration) {
                          index++;

                          return IllustrationCard(
                            heroTag: illustration.id,
                            illustration: illustration,
                            index: index,
                            onTap: () =>
                                navigateToIllustrationPage(illustration),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0.0,
                child: PopupMenuButton(
                  icon: Opacity(
                    opacity: 0.8,
                    child: Icon(
                      UniconsLine.ellipsis_h,
                    ),
                  ),
                  itemBuilder: (_) => popupMenuEntries,
                  onSelected: (EnumSectionAction action) {
                    widget.onPopupMenuItemSelected?.call(
                      action,
                      widget.index,
                      widget.section,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void fetchIllustrations() async {
    setState(() {
      _isLoading = true;
      _illustrations.clear();
    });

    try {
      final illustrationsSnapshot = await FirebaseFirestore.instance
          .collection("illustrations")
          .where("user_id", isEqualTo: widget.userId)
          .orderBy("user_custom_index", descending: true)
          .where("visibility", isEqualTo: "public")
          .limit(6)
          .get();

      if (illustrationsSnapshot.size == 0) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      for (DocSnapMap document in illustrationsSnapshot.docs) {
        final data = document.data();
        data['id'] = document.id;

        _illustrations.add(Illustration.fromMap(data));
      }
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void navigateToIllustrationPage(Illustration illustration) {
    NavigationStateHelper.illustration = illustration;
    Beamer.of(context).beamToNamed(
      AtelierLocationContent.illustrationRoute.replaceFirst(
        ":illustrationId",
        illustration.id,
      ),
      data: {
        "illustrationId": illustration.id,
      },
    );
  }
}
