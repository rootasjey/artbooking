import 'package:artbooking/components/texts/text_divider.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class BookPageBodyEmpty extends StatelessWidget {
  const BookPageBodyEmpty({
    Key? key,
    this.uploadToThisBook,
  }) : super(key: key);

  final void Function()? uploadToThisBook;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 40.0,
        left: 50.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Opacity(
                  opacity: 0.8,
                  child: Icon(
                    UniconsLine.trees,
                    size: 80.0,
                    color: Colors.lightGreen,
                  ),
                ),
              ),
              Opacity(
                opacity: 0.6,
                child: Text(
                  "new_start_sentence".tr().toUpperCase(),
                  style: Utilities.fonts.style(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                width: 400.0,
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                ),
                child: Opacity(
                  opacity: 0.4,
                  child: Text(
                    "book_no_illustrations".tr(),
                    textAlign: TextAlign.center,
                    style: Utilities.fonts.style(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              Container(
                width: 400.0,
                padding: const EdgeInsets.only(top: 24.0),
                child: Column(
                  children: [
                    IconButton(
                      tooltip: "book_upload_illustration".tr(),
                      onPressed: uploadToThisBook,
                      icon: Icon(UniconsLine.upload),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextDivider(
                        text: Opacity(
                          opacity: 0.6,
                          child: Text(
                            "or".tr().toUpperCase(),
                            style: Utilities.fonts.style(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.beamToNamed(
                            DashboardLocationContent.illustrationsRoute);
                      },
                      child: Text("illustrations_yours_browse".tr()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
