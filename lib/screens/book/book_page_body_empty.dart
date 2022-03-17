import 'package:artbooking/components/buttons/dark_text_button.dart';
import 'package:artbooking/components/texts/text_divider.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class BookPageBodyEmpty extends StatelessWidget {
  const BookPageBodyEmpty({
    Key? key,
    this.onUploadToThisBook,
    this.onBrowseIllustrations,
    this.isOwner = false,
  }) : super(key: key);

  /// True if the current authenticated user is the owner of this book.
  final bool isOwner;

  /// Upload a new illustration and add it to this book.
  final void Function()? onUploadToThisBook;

  /// Navigate to user's illustrations.
  final void Function()? onBrowseIllustrations;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 40.0,
        left: 50.0,
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 400.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      isOwner
                          ? "new_start_sentence".tr().toUpperCase()
                          : "under_construction".tr().toUpperCase(),
                      textAlign: TextAlign.center,
                      style: Utilities.fonts.style(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16.0,
                    ),
                    child: Opacity(
                      opacity: 0.4,
                      child: Text(
                        isOwner
                            ? "book_owner_no_illustration".tr()
                            : "book_no_illustration".tr(),
                        textAlign: TextAlign.center,
                        style: Utilities.fonts.style(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  if (isOwner)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Column(
                        children: [
                          IconButton(
                            tooltip: "book_upload_illustration".tr(),
                            onPressed: onUploadToThisBook,
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
                          DarkTextButton(
                            onPressed: onBrowseIllustrations,
                            child: Text("illustrations_yours_browse".tr()),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
