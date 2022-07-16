import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A TextField in order to search content.
class SearchTextField extends StatelessWidget {
  const SearchTextField({
    Key? key,
    this.label,
    this.controller,
    this.hintText = "",
    this.onChanged,
    this.onSubmitted,
    this.constraints = const BoxConstraints(maxHeight: 140.0),
    this.autofocus = true,
    this.maxLines = 1,
    this.textInputAction,
    this.keyboardType,
    this.focusNode,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.sentences,
    this.onClearInput,
  }) : super(key: key);

  final bool autofocus;
  final bool obscureText;

  final BoxConstraints constraints;

  final FocusNode? focusNode;

  final int? maxLines;

  /// Fires when the user modify the input's value.
  final Function(String)? onChanged;

  /// Fires when the user send/validate the input's value.
  final Function(String)? onSubmitted;

  final void Function()? onClearInput;

  /// The [hintText] will be displayed inside the input.
  final String hintText;

  /// The label will be displayed on top of the input.
  final String? label;

  final TextCapitalization textCapitalization;

  /// A controller to manipulate the input component.
  final TextEditingController? controller;

  final TextInputAction? textInputAction;

  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final _primaryColor = Theme.of(context).primaryColor;

    final BorderRadius borderRadius = BorderRadius.circular(24.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                label!,
                style: Utilities.fonts.body(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        Stack(
          children: [
            ConstrainedBox(
              constraints: constraints,
              child: TextField(
                focusNode: focusNode,
                autofocus: autofocus,
                controller: controller,
                maxLines: maxLines,
                obscureText: obscureText,
                textInputAction: textInputAction,
                keyboardType: keyboardType,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                style: Utilities.fonts.body(
                  fontWeight: FontWeight.w600,
                ),
                cursorColor: _primaryColor,
                decoration: InputDecoration(
                  // filled: true,
                  // fillColor: Theme.of(context).primaryColor,
                  // fillColor: Theme.of(context).backgroundColor,
                  hintText: hintText,
                  contentPadding: EdgeInsets.only(
                    left: 20.0,
                    right: 8.0,
                    top: maxLines == null ? 8.0 : 0.0,
                    bottom: maxLines == null ? 8.0 : 0.0,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide(
                      color: Theme.of(context).secondaryHeaderColor,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide(
                      color: _primaryColor,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide(
                      color: _primaryColor,
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 3.0,
              right: 4.0,
              child: CircleButton(
                backgroundColor: Colors.transparent,
                icon: Icon(
                  UniconsLine.times,
                  color: Theme.of(context)
                      .textTheme
                      .bodyText2
                      ?.color
                      ?.withOpacity(0.6),
                ),
                onTap: onClearInput,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
