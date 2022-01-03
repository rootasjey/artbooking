import 'package:artbooking/router/locations/search_location.dart';
import 'package:artbooking/types/globals/globals.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Globals.constants.colors;
    final foregroundColor = colors.getForeground(context).withOpacity(0.6);

    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 8.0,
      ),
      child: IconButton(
        tooltip: "search".tr(),
        onPressed: () => Beamer.of(context).beamToNamed(SearchLocation.route),
        color: foregroundColor,
        icon: Icon(UniconsLine.search),
      ),
    );
  }
}
