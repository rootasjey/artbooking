import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class PopupProgressIndicator extends StatelessWidget {
  const PopupProgressIndicator({
    Key? key,
    required this.message,
    this.show = true,
    this.onClose,
    this.icon,
  }) : super(key: key);

  /// This widget is displayed if true.
  final bool show;

  /// Callback when this widget is dismissed.
  final void Function()? onClose;

  /// Text to show inside this widget
  final String message;

  /// Icon prefix inside this widget.
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    final Widget prefix = icon != null
        ? icon!
        : Icon(
            UniconsLine.circle,
            color: Constants.colors.secondary,
          );

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
                  prefix,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Opacity(
                        opacity: 0.6,
                        child: Text(
                          message,
                          style: Utilities.fonts.body(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (onClose != null)
                    Opacity(
                      opacity: 0.6,
                      child: IconButton(
                        onPressed: onClose,
                        icon: Icon(UniconsLine.times),
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
