import 'package:artbooking/components/animations/themed_circular_progress.dart';
import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A TextField in order to search content.
class SearchTextInput extends StatelessWidget {
  const SearchTextInput({
    Key? key,
    this.autofocus = true,
    this.loading = false,
    this.obscureText = false,
    this.constraints = const BoxConstraints(maxHeight: 140.0),
    this.focusNode,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.hintText = "",
    this.label,
    this.textCapitalization = TextCapitalization.sentences,
    this.controller,
    this.textInputAction,
    this.keyboardType,
    this.onClearInput,
  }) : super(key: key);

  /// The input will request focus on mount if true.
  final bool autofocus;

  /// Display a circular progress indicator if true.
  final bool loading;

  /// Hide previous typed characters if true.
  final bool obscureText;

  /// Give size constraints to this widget.
  final BoxConstraints constraints;

  /// Focus node to manually request focus.
  final FocusNode? focusNode;

  /// Maximum allowed displayed lines for this inpput.
  final int? maxLines;

  /// Callback fired when the user modify the input's value.
  final void Function(String value)? onChanged;

  /// Callback fired when the user send/validate the input's value.
  final void Function(String value)? onSubmitted;

  /// Callback fired when the input value is cleared.
  final void Function()? onClearInput;

  /// The [hintText] will be displayed inside the input.
  final String hintText;

  /// The label will be displayed on top of the input.
  final String? label;

  /// How to capitalized text inside this input.
  final TextCapitalization textCapitalization;

  /// A controller to manipulate the input component.
  final TextEditingController? controller;

  /// Action button to display on mobile to validate this input.
  final TextInputAction? textInputAction;

  /// Keyboard type on mobile (e.g. sentence, number, email).
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).primaryColor;

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
            if (loading)
              Positioned(
                top: 6.0,
                right: 6.0,
                child: ThemedCircularProgress(),
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
