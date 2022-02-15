import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class MyIllustrationsPageEmpty extends ConsumerWidget {
  const MyIllustrationsPageEmpty({
    Key? key,
    this.uploadIllustration,
  }) : super(key: key);

  final void Function()? uploadIllustration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 40.0,
          left: 54.0,
          bottom: 100.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: 0.8,
              child: Icon(
                UniconsLine.no_entry,
                size: 60.0,
              ),
            ),
            Stack(
              children: [
                Positioned(
                  bottom: 6.0,
                  child: SizedBox(
                    height: 8.0,
                    width: 280.0,
                    child: Container(
                      color: Colors.pink.withOpacity(0.4),
                    ),
                  ),
                ),
                Text(
                  "illustrations_my_empty".tr(),
                  style: Utilities.fonts.style(
                    fontSize: 26.0,
                    fontWeight: FontWeight.w600,
                    // color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            Container(
              width: 500.0,
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Opacity(
                opacity: 0.4,
                child: Text(
                  "illustrations_my_empty_subtitle".tr(),
                  style: Utilities.fonts.style(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            DarkElevatedButton.large(
              onPressed: uploadIllustration,
              child: Text("upload".tr()),
            ),
          ],
        ),
      ),
    );
  }
}
