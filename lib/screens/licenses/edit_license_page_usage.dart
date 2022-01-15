import 'package:artbooking/components/themed_dialog.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/licenses/square_link.dart';
import 'package:artbooking/screens/licenses/square_toggle.dart';
import 'package:artbooking/types/dialog_return_value.dart';
import 'package:artbooking/types/illustration/license_usage.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class EditLicensePageUsage extends StatelessWidget {
  const EditLicensePageUsage({
    Key? key,
    required this.usage,
    this.onValueChange,
  }) : super(key: key);

  final LicenseUsage usage;
  final Function()? onValueChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 42.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                "Usage".toUpperCase(),
                style: Utilities.fonts.style(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: [
              SquareLink(
                onTap: () {
                  usage.adapt = !usage.adapt;
                  onValueChange?.call();
                },
                onLongPress: () async {
                  final dialogReturnValue = await onEditUsage(
                    context,
                    usageString: "adapt",
                    initialUsageActive: usage.adapt,
                  );

                  if (dialogReturnValue.validated) {
                    usage.adapt = dialogReturnValue.value;
                    onValueChange?.call();
                  }
                },
                checked: usage.adapt,
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
                onTap: () {
                  usage.commercial = !usage.commercial;
                  onValueChange?.call();
                },
                onLongPress: () async {
                  final dialogReturnValue = await onEditUsage(
                    context,
                    usageString: "commercial",
                    initialUsageActive: usage.commercial,
                  );

                  if (dialogReturnValue.validated) {
                    usage.commercial = dialogReturnValue.value;
                    onValueChange?.call();
                  }
                },
                checked: usage.commercial,
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
                onTap: () {
                  usage.free = !usage.free;
                  onValueChange?.call();
                },
                onLongPress: () async {
                  final dialogReturnValue = await onEditUsage(
                    context,
                    usageString: "free",
                    initialUsageActive: usage.free,
                  );

                  if (dialogReturnValue.validated) {
                    usage.free = dialogReturnValue.value;
                    onValueChange?.call();
                  }
                },
                checked: usage.free,
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
                onTap: () {
                  usage.oss = !usage.oss;
                  onValueChange?.call();
                },
                onLongPress: () async {
                  final dialogReturnValue = await onEditUsage(
                    context,
                    usageString: "oss",
                    initialUsageActive: usage.oss,
                  );

                  if (dialogReturnValue.validated) {
                    usage.oss = dialogReturnValue.value;
                    onValueChange?.call();
                  }
                },
                checked: usage.oss,
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
                onTap: () {
                  usage.personal = !usage.personal;
                  onValueChange?.call();
                },
                onLongPress: () async {
                  final dialogReturnValue = await onEditUsage(
                    context,
                    usageString: "personal",
                    initialUsageActive: usage.personal,
                  );

                  if (dialogReturnValue.validated) {
                    usage.personal = dialogReturnValue.value;
                    onValueChange?.call();
                  }
                },
                checked: usage.personal,
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
                onTap: () {
                  usage.print = !usage.print;
                  onValueChange?.call();
                },
                onLongPress: () async {
                  final dialogReturnValue = await onEditUsage(
                    context,
                    usageString: "print",
                    initialUsageActive: usage.print,
                  );

                  if (dialogReturnValue.validated) {
                    usage.print = dialogReturnValue.value;
                    onValueChange?.call();
                  }
                },
                checked: usage.print,
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
                onTap: () {
                  usage.sell = !usage.sell;
                  onValueChange?.call();
                },
                onLongPress: () async {
                  final dialogReturnValue = await onEditUsage(
                    context,
                    usageString: "sell",
                    initialUsageActive: usage.sell,
                  );

                  if (dialogReturnValue.validated) {
                    usage.sell = dialogReturnValue.value;
                    onValueChange?.call();
                  }
                },
                checked: usage.sell,
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
                onTap: () {
                  usage.share = !usage.share;
                  onValueChange?.call();
                },
                onLongPress: () async {
                  final dialogReturnValue = await onEditUsage(
                    context,
                    usageString: "share",
                    initialUsageActive: usage.share,
                  );

                  if (dialogReturnValue.validated) {
                    usage.share = dialogReturnValue.value;
                    onValueChange?.call();
                  }
                },
                checked: usage.share,
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
                onTap: () {
                  usage.view = !usage.view;
                  onValueChange?.call();
                },
                onLongPress: () async {
                  final dialogReturnValue = await onEditUsage(
                    context,
                    usageString: "view",
                    initialUsageActive: usage.view,
                  );

                  if (dialogReturnValue.validated) {
                    usage.view = dialogReturnValue.value;
                    onValueChange?.call();
                  }
                },
                checked: usage.view,
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
            ],
          ),
        ],
      ),
    );
  }

  Future<DialogReturnValue<bool>> onEditUsage(
    BuildContext context, {
    required String usageString,
    bool initialUsageActive = false,
  }) async {
    var _usageActive = initialUsageActive;
    var _validated = false;

    final String usageInfoStr = "license_usage_information".tr().toUpperCase();

    await showDialog(
      context: context,
      builder: (context) {
        return ThemedDialog(
          centerTitle: false,
          title: Opacity(
            opacity: 0.8,
            child: Text.rich(
              TextSpan(
                text: usageString.toUpperCase() + " : ",
                style: Utilities.fonts.style(
                  color: Theme.of(context).textTheme.bodyText2?.color,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(
                    text: usageInfoStr,
                    style: Utilities.fonts.style(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText2
                          ?.color
                          ?.withOpacity(0.3),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Container(
            width: 300.0,
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Opacity(
                    opacity: 0.4,
                    child: Text(
                      "license_usages.$usageString".tr(),
                      style: Utilities.fonts.style(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: SquareToggle(
                      initialActive: _usageActive,
                      onChangeValue: (newValue) {
                        _usageActive = newValue;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          textButtonValidation: "save".tr(),
          onValidate: () {
            _validated = true;
            Beamer.of(context).popRoute();
          },
          onCancel: Beamer.of(context).popRoute,
        );
      },
    );

    return DialogReturnValue(
      validated: _validated,
      value: _usageActive,
    );
  }

  Color? getIconColor(BuildContext context, bool isActive) {
    return isActive ? Theme.of(context).primaryColor : null;
  }

  TextStyle getTextStyle() {
    return Utilities.fonts.style(
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
    );
  }

  double getIconSize() {
    return 36.0;
  }
}
