import 'package:artbooking/components/themed_dialog.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/licenses/square_link.dart';
import 'package:artbooking/types/dialog_return_value.dart';
import 'package:artbooking/types/illustration/license_urls.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unicons/unicons.dart';

class EditLicensePageUrls extends StatelessWidget {
  const EditLicensePageUrls({
    Key? key,
    required this.urls,
  }) : super(key: key);

  final LicenseUrls urls;

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
                onTap: () async {
                  final DialogReturnValue<String> dialogReturnValue =
                      await onEditUrl(context, 'website');

                  if (dialogReturnValue.validated) {
                    urls.website = dialogReturnValue.value;
                  }
                },
                icon: Icon(
                  UniconsLine.globe,
                  size: 42.0,
                ),
                text: Text(
                  "website",
                  style: Utilities.fonts.style(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SquareLink(
                onTap: () async {
                  final DialogReturnValue<String> dialogReturnValue =
                      await onEditUrl(context, 'wikipedia');

                  if (dialogReturnValue.validated) {
                    urls.wikipedia = dialogReturnValue.value;
                  }
                },
                icon: Icon(
                  FontAwesomeIcons.wikipediaW,
                  size: 36.0,
                ),
                text: Text(
                  "wikipedia",
                  style: Utilities.fonts.style(
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
    BuildContext context,
    String urlName,
  ) async {
    var _nameTextController = TextEditingController();
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
                  style: Utilities.fonts.style(
                    color: Theme.of(context)
                        .textTheme
                        .bodyText2
                        ?.color
                        ?.withOpacity(0.3),
                  ),
                  children: [
                    TextSpan(
                      text: urlName.toUpperCase(),
                      style: Utilities.fonts.style(
                        color: Theme.of(context).textTheme.bodyText2?.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // child: Text(
              //   "EDIT URL: ${urlName.toUpperCase()}",
              //   style: Utilities.fonts.style(
              //     color: Colors.black,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
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
                  style: Utilities.fonts.style(
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
}
