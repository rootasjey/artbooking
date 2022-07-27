import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class MyIllustrationsPageFab extends StatelessWidget {
  const MyIllustrationsPageFab({
    Key? key,
    required this.showFabUpload,
    required this.scrollController,
    this.uploadIllustration,
    this.isOwner = false,
    this.showFabToTop = false,
  }) : super(key: key);

  /// Show create book FAB if true.
  final bool isOwner;

  /// Show the scroll to top FAB if true.
  final bool showFabUpload;

  /// Show the scroll to top FAB if true.
  final bool showFabToTop;

  /// Callback to upload an illustration.
  final void Function()? uploadIllustration;

  /// Page scroll controller to scroll to top.
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isOwner && showFabUpload)
          FadeInY(
            beginY: 25.0,
            delay: Duration(milliseconds: 25),
            duration: Duration(milliseconds: 250),
            child: FloatingActionButton.extended(
              onPressed: uploadIllustration,
              backgroundColor: Theme.of(context).primaryColor,
              label: Text(
                "upload".tr(),
                style: Utilities.fonts.body(
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: Icon(UniconsLine.upload),
            ),
          ),
        if (showFabUpload && showFabToTop)
          FadeInY(
            beginY: 25.0,
            duration: Duration(milliseconds: 250),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: FloatingActionButton(
                onPressed: () {
                  scrollController.animateTo(
                    0.0,
                    duration: Duration(milliseconds: 250),
                    curve: Curves.decelerate,
                  );
                },
                heroTag: null,
                backgroundColor: Colors.grey.shade900,
                child: Icon(UniconsLine.arrow_up),
              ),
            ),
          ),
      ],
    );
  }
}
