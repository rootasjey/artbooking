import 'package:artbooking/components/buttons/heart_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class FooterCompanyWatermark extends StatefulWidget {
  const FooterCompanyWatermark({
    Key? key,
    this.padding = const EdgeInsets.only(
      left: 8.0,
      bottom: 8.0,
    ),
  }) : super(key: key);

  final EdgeInsets padding;

  @override
  State<FooterCompanyWatermark> createState() => _FooterCompanyWatermarkState();
}

class _FooterCompanyWatermarkState extends State<FooterCompanyWatermark> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "artbooking 2021 - ${DateTime.now().year}",
                  style: Utilities.fonts.body(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText2
                        ?.color
                        ?.withOpacity(0.4),
                  ),
                ),
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Opacity(
                      opacity: 0.6,
                      child: Icon(
                        UniconsLine.copyright,
                        size: 18.0,
                      ),
                    ),
                  ),
                ),
                TextSpan(
                  text: "\n" + "company_by".tr(),
                  style: Utilities.fonts.body2(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText2
                        ?.color
                        ?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Container(
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "company_made_in".tr(),
                  style: Utilities.fonts.body2(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                WidgetSpan(
                  child: HeartButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
