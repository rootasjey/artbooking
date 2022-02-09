import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SelectLicensePanelHeader extends StatelessWidget {
  const SelectLicensePanelHeader({
    Key? key,
    this.onClose,
    this.containerWidth = 400.0,
  }) : super(key: key);

  final Function()? onClose;
  final double containerWidth;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0.0,
      child: Container(
        padding: const EdgeInsets.only(top: 20.0),
        decoration: BoxDecoration(
          color: Constants.colors.clairPink,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 380.0,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: CircleButton(
                      tooltip: "close".tr(),
                      icon: Icon(
                        UniconsLine.times,
                        color: Colors.black54,
                      ),
                      onTap: onClose,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "licenses_available".tr(),
                            style: Utilities.fonts.style(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Opacity(
                            opacity: 0.5,
                            child: Text(
                              "licenses_subtitle".tr(),
                              style: Utilities.fonts.style(
                                height: 1.0,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: containerWidth,
              child: Divider(
                thickness: 2.0,
                color: Theme.of(context).secondaryHeaderColor,
                height: 40.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
