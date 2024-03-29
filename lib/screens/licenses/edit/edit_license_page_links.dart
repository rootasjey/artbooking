import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/components/square/square_link.dart';
import 'package:artbooking/types/dialog_return_value.dart';
import 'package:artbooking/types/license/license_links.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unicons/unicons.dart';

class EditLicensePageLinks extends StatelessWidget {
  const EditLicensePageLinks({
    Key? key,
    required this.links,
    this.onValueChange,
  }) : super(key: key);

  final LicenseLinks links;
  final Function(LicenseLinks)? onValueChange;

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
                "links".tr().toUpperCase(),
                style: Utilities.fonts.body(
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
                onTap: () async {
                  final DialogReturnValue<String> dialogReturnValue =
                      await onEditUrl(
                    context,
                    dialogTitle: 'website',
                    initialValue: links.website,
                  );

                  if (dialogReturnValue.validated) {
                    onValueChange?.call(links.copyWith(
                      website: dialogReturnValue.value,
                    ));
                  }
                },
                checked: links.website.isNotEmpty,
                icon: Icon(
                  UniconsLine.globe,
                  size: 42.0,
                  color: getIconColor(context, links.website.isNotEmpty),
                ),
                text: Text(
                  "website",
                  style: Utilities.fonts.body(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SquareLink(
                onTap: () async {
                  final DialogReturnValue<String> dialogReturnValue =
                      await onEditUrl(
                    context,
                    dialogTitle: 'wikipedia',
                    initialValue: links.wikipedia,
                  );

                  if (dialogReturnValue.validated) {
                    onValueChange?.call(
                      links.copyWith(wikipedia: dialogReturnValue.value),
                    );
                  }
                },
                checked: links.wikipedia.isNotEmpty,
                icon: Icon(
                  FontAwesomeIcons.wikipediaW,
                  size: 36.0,
                  color: getIconColor(context, links.wikipedia.isNotEmpty),
                ),
                text: Text(
                  "wikipedia",
                  style: Utilities.fonts.body(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<DialogReturnValue<String>> onEditUrl(
    BuildContext context, {
    required String dialogTitle,
    String initialValue = '',
  }) async {
    var _nameTextController = TextEditingController();
    _nameTextController.text = initialValue;
    var _validated = false;

    await showDialog(
      context: context,
      builder: (context) {
        return ThemedDialog(
          spaceActive: false,
          centerTitle: false,
          autofocus: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Opacity(
              opacity: 0.8,
              child: Text.rich(
                TextSpan(
                  text: "${'url_edit'.tr().toUpperCase()} ",
                  style: Utilities.fonts.body(
                    color: Theme.of(context)
                        .textTheme
                        .bodyText2
                        ?.color
                        ?.withOpacity(0.3),
                  ),
                  children: [
                    TextSpan(
                      text: dialogTitle.toUpperCase(),
                      style: Utilities.fonts.body(
                        color: Theme.of(context).textTheme.bodyText2?.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
                child: TextField(
                  autofocus: true,
                  controller: _nameTextController,
                  keyboardType: TextInputType.url,
                  textCapitalization: TextCapitalization.none,
                  style: Utilities.fonts.body(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: "https://...",
                    filled: true,
                    isDense: true,
                    fillColor: Constants.colors.clairPink,
                    focusColor: Constants.colors.clairPink,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2.0,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  onSubmitted: (value) {
                    _validated = true;
                  },
                ),
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

    return DialogReturnValue<String>(
      validated: _validated,
      value: _nameTextController.text,
    );
  }

  Color? getIconColor(BuildContext context, bool isActive) {
    return isActive ? Theme.of(context).primaryColor : null;
  }
}
