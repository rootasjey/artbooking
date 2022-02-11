import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class BookPageBodyError extends StatelessWidget {
  const BookPageBodyError({Key? key, this.fetchBookAndIllustrations})
      : super(key: key);

  final void Function()? fetchBookAndIllustrations;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 12.0,
                ),
                child: Text(
                  "issue_unexpected".tr(),
                  style: TextStyle(
                    fontSize: 32.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                  // top: 24.0,
                ),
                child: Opacity(
                  opacity: 0.4,
                  child: Text(
                    "issue_data_retry".tr(),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: fetchBookAndIllustrations,
                icon: Icon(UniconsLine.refresh),
                label: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "retry".tr(),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
