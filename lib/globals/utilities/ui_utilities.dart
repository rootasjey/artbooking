import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/constants/section_ids.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/enums/enum_section_data_type.dart';
import 'package:artbooking/types/enums/enum_separator_shape.dart';
import 'package:artbooking/types/named_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unicons/unicons.dart';

class UIUtilities {
  const UIUtilities();

  String getPageTitle(String trailingText) {
    final base = "ArtBooking •";
    return "$base $trailingText";
  }

  /// Return a list of NamedColor for background section.
  List<NamedColor> getBackgroundSectionColors() {
    return [
      NamedColor(
        name: "Transparent",
        color: Colors.transparent,
      ),
      NamedColor(
        name: "Clair Pink",
        color: Constants.colors.clairPink,
      ),
      NamedColor(
        name: "Light Blue",
        color: Constants.colors.lightBackground,
      ),
      NamedColor(
        name: "Blue",
        color: Colors.blue,
      ),
      NamedColor(
        name: "Blue 100",
        color: Colors.blue.shade100,
      ),
      NamedColor(
        name: "Green 100",
        color: Colors.green.shade100,
      ),
      NamedColor(
        name: "Lime 100",
        color: Colors.lime.shade100,
      ),
      NamedColor(
        name: "Amber",
        color: Colors.amber,
      ),
      NamedColor(
        name: "Amber 100",
        color: Colors.amber.shade100,
      ),
      NamedColor(
        name: "Yellow 100",
        color: Colors.yellow.shade100,
      ),
      NamedColor(
        name: "Deep Orange 100",
        color: Colors.deepOrange.shade100,
      ),
      NamedColor(
        name: "Orange 100",
        color: Colors.orange.shade100,
      ),
      NamedColor(
        name: "Red 100",
        color: Colors.red.shade100,
      ),
      NamedColor(
        name: "Pink",
        color: Colors.pink,
      ),
      NamedColor(
        name: "Pink 100",
        color: Colors.pink.shade100,
      ),
      NamedColor(
        name: "Deep Purple",
        color: Colors.deepPurple,
      ),
      NamedColor(
        name: "Deep Purple 100",
        color: Colors.deepPurple.shade100,
      ),
      NamedColor(
        name: "Purple",
        color: Colors.purple,
      ),
      NamedColor(
        name: "Purple 100",
        color: Colors.purple.shade100,
      ),
      NamedColor(
        name: "Indigo 100",
        color: Colors.indigo.shade100,
      ),
      NamedColor(
        name: "Grey 100",
        color: Colors.grey.shade100,
      ),
      NamedColor(
        name: "White 54",
        color: Colors.white54,
      ),
      NamedColor(
        name: "Black 26",
        color: Colors.black26,
      ),
      NamedColor(
        name: "White",
        color: Colors.white,
      ),
      NamedColor(
        name: "Black",
        color: Colors.black,
      ),
    ];
  }

  List<NamedColor> getSeparatorColors() {
    return [
      NamedColor(
        name: "color_primary".tr(),
        color: Constants.colors.primary,
      ),
      NamedColor(
        name: "color_secondary".tr(),
        color: Constants.colors.secondary,
      ),
    ]..addAll(getBackgroundSectionColors());
  }

  IconData getDataFetchModeIconData(EnumSectionDataMode mode) {
    switch (mode) {
      case EnumSectionDataMode.chosen:
        return UniconsLine.list_ol;
      case EnumSectionDataMode.sync:
        return UniconsLine.sync_icon;
      default:
        return UniconsLine.question;
    }
  }

  IconData getDataTypeIcon(EnumSectionDataType type) {
    switch (type) {
      case EnumSectionDataType.books:
        return UniconsLine.book_medical;
      case EnumSectionDataType.illustrations:
        return UniconsLine.picture;
      case EnumSectionDataType.text:
        return UniconsLine.text;
      case EnumSectionDataType.user:
        return UniconsLine.user;
      default:
        return UniconsLine.question;
    }
  }

  IconData getHeaderSeparatorIconData(EnumSeparatorShape separatorType) {
    switch (separatorType) {
      case EnumSeparatorShape.dot:
        return UniconsLine.circle;
      case EnumSeparatorShape.line:
        return UniconsLine.line_alt;
      case EnumSeparatorShape.none:
        return UniconsLine.ban;
      default:
        return UniconsLine.ban;
    }
  }

  IconData getPostIcon(String id) {
    switch (id) {
      case "eye":
        return UniconsLine.eye;
      case "image":
        return UniconsLine.image;
      default:
        return UniconsLine.newspaper;
    }
  }

  IconData getSectionIcon(String id) {
    switch (id) {
      case SectionIds.appBar:
        return UniconsLine.panorama_h_alt;
      case SectionIds.bookGrid:
        return UniconsLine.books;
      case SectionIds.borderedPoster:
        return UniconsLine.image;
      case SectionIds.illustrationGrid:
        return UniconsLine.images;
      case SectionIds.user:
        return UniconsLine.user_circle;
      case SectionIds.userWithIllustration:
        return UniconsLine.user_square;
      case SectionIds.poster:
        return UniconsLine.picture;
      case SectionIds.illustrationRow:
        return UniconsLine.horizontal_distribution_center;
      case SectionIds.spacing:
        return UniconsLine.space_key;
      case SectionIds.illustrationWindow:
        return UniconsLine.th;
      case SectionIds.h1:
        return UniconsLine.text;
      default:
        return UniconsLine.books;
    }
  }

  /// Show a dialog or a modal bottom sheet according to `isMobileSize` value.
  void showAdaptiveDialog(
    BuildContext context, {
    required Widget Function(BuildContext) builder,
    bool isMobileSize = false,
    Color backgroundColor = Colors.white,
  }) {
    if (isMobileSize) {
      showCupertinoModalBottomSheet(
        context: context,
        expand: false,
        backgroundColor: backgroundColor,
        builder: builder,
      );
      return;
    }

    showDialog(
      context: context,
      builder: builder,
    );
  }
}
