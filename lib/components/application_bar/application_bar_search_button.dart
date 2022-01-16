import 'package:artbooking/router/locations/search_location.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ApplicationBarSearchButton extends StatelessWidget {
  const ApplicationBarSearchButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.6);

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
