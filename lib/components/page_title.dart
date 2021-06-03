import 'package:artbooking/utils/fonts.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class PageTitle extends StatelessWidget {
  final String textTitle;
  final bool isLoading;
  final MainAxisAlignment mainAxisAlignment;

  const PageTitle({
    Key key,
    @required this.textTitle,
    this.isLoading = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                tooltip: "back".tr(),
                onPressed: context.router.pop,
                icon: Icon(UniconsLine.arrow_left),
              ),
            ),
            Text(
              textTitle,
              style: FontsUtils.mainStyle(
                fontSize: 80.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 22.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
