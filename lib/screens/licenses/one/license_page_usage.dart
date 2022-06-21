import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/components/square/square_link.dart';
import 'package:artbooking/types/license/license_usage.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class LicensePageUsage extends StatelessWidget {
  const LicensePageUsage({
    Key? key,
    required this.usage,
    this.margin = EdgeInsets.zero,
  }) : super(key: key);

  /// External padding (blank space around this widget).
  final EdgeInsets margin;

  /// License's usage data.
  final LicenseUsage usage;

  @override
  Widget build(BuildContext context) {
    int milliseconds = 100;

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInY(
            beginY: 12.0,
            delay: Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Opacity(
                opacity: 0.8,
                child: Text(
                  "license_usage".tr().toUpperCase(),
                  style: Utilities.fonts.body2(
                    fontSize: 28.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: [
              SquareLink(
                onTap: () => onTap(context, "adapt"),
                active: usage.adapt,
                icon: Icon(
                  UniconsLine.drill,
                  size: getIconSize(),
                  color: getIconColor(context, usage.adapt),
                ),
                text: Text(
                  "adapt",
                  style: getTextStyle(),
                ),
              ),
              SquareLink(
                onTap: () => onTap(context, "commercial"),
                active: usage.commercial,
                icon: Icon(
                  UniconsLine.coins,
                  size: getIconSize(),
                  color: getIconColor(context, usage.commercial),
                ),
                text: Text(
                  "commercial",
                  style: getTextStyle(),
                ),
              ),
              SquareLink(
                onTap: () => onTap(context, "free"),
                active: usage.free,
                icon: Icon(
                  UniconsLine.money_bill_slash,
                  size: getIconSize(),
                  color: getIconColor(context, usage.free),
                ),
                text: Text(
                  "free",
                  style: getTextStyle(),
                ),
              ),
              SquareLink(
                onTap: () => onTap(context, "oss"),
                active: usage.oss,
                icon: Icon(
                  UniconsLine.book_open,
                  size: getIconSize(),
                  color: getIconColor(context, usage.oss),
                ),
                text: Text(
                  "open source",
                  style: getTextStyle(),
                ),
              ),
              SquareLink(
                onTap: () => onTap(context, "personal"),
                active: usage.personal,
                icon: Icon(
                  UniconsLine.user_square,
                  size: getIconSize(),
                  color: getIconColor(context, usage.personal),
                ),
                text: Text(
                  "personal",
                  style: getTextStyle(),
                ),
              ),
              SquareLink(
                onTap: () => onTap(context, "print"),
                active: usage.print,
                icon: Icon(
                  UniconsLine.print,
                  size: getIconSize(),
                  color: getIconColor(context, usage.print),
                ),
                text: Text(
                  "print",
                  style: getTextStyle(),
                ),
              ),
              SquareLink(
                onTap: () => onTap(context, "sell"),
                active: usage.sell,
                icon: Icon(
                  UniconsLine.invoice,
                  size: getIconSize(),
                  color: getIconColor(context, usage.sell),
                ),
                text: Text(
                  "sell",
                  style: getTextStyle(),
                ),
              ),
              SquareLink(
                onTap: () => onTap(context, "share"),
                active: usage.share,
                icon: Icon(
                  UniconsLine.share,
                  size: getIconSize(),
                  color: getIconColor(context, usage.share),
                ),
                text: Text(
                  "share",
                  style: getTextStyle(),
                ),
              ),
              SquareLink(
                onTap: () => onTap(context, "view"),
                active: usage.view,
                icon: Icon(
                  UniconsLine.eye,
                  size: getIconSize(),
                  color: getIconColor(context, usage.view),
                ),
                text: Text(
                  "view",
                  style: getTextStyle(),
                ),
              ),
            ].map((SquareLink child) {
              milliseconds += 25;

              return FadeInY(
                beginY: 12.0,
                delay: Duration(
                  milliseconds: milliseconds,
                ),
                child: child,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void onTap(BuildContext context, String usageString) {
    final String usageInfoStr = "license_usage_information".tr().toUpperCase();

    showDialog(
      context: context,
      builder: (context) {
        return ThemedDialog(
          centerTitle: false,
          title: Opacity(
            opacity: 0.8,
            child: Text(
              "${usageString.toUpperCase()} : $usageInfoStr",
              style: Utilities.fonts.body(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: Container(
            width: 300.0,
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Opacity(
                opacity: 0.4,
                child: Text(
                  "license_usages.$usageString".tr(),
                  style: Utilities.fonts.body(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          textButtonValidation: "close".tr(),
          onValidate: Beamer.of(context).popRoute,
          onCancel: Beamer.of(context).popRoute,
        );
      },
    );
  }

  Color? getIconColor(BuildContext context, bool isActive) {
    return isActive ? Theme.of(context).primaryColor : null;
  }

  TextStyle getTextStyle() {
    return Utilities.fonts.body(
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
    );
  }

  double getIconSize() {
    return 36.0;
  }
}
