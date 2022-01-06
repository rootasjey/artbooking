import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class PopupProgressIndicator extends StatelessWidget {
  final bool show;
  final String message;

  const PopupProgressIndicator({
    Key? key,
    this.show = true,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    return SizedBox(
      width: 240.0,
      child: Card(
        elevation: 4.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 4.0,
              child: LinearProgressIndicator(),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    UniconsLine.circle,
                    color: Constants.colors.secondary,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Opacity(
                        opacity: 0.6,
                        child: Text(
                          message,
                          style: FontsUtils.mainStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
