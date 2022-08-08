import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

/// A TextField with a predefined outlined border.
class OutlinedTextField extends StatelessWidget {
  const OutlinedTextField({
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
  }) : super(key: key);

  /// Will immediately request focus on mount if true.
  final bool autofocus;

  /// Will hide characters of true (usually for passwords).
  final bool obscureText;

  /// Limit this widget constrants.
  final BoxConstraints constraints;

  /// Allow to request focus.
  final FocusNode? focusNode;

  /// Maxium allowed lines.
  final int? maxLines;

  /// Fires when the user modify the input's value.
  final Function(String)? onChanged;

  /// Fires when the user send/validate the input's value.
  final Function(String)? onSubmitted;

  /// The [hintText] will be displayed inside the input.
  final String hintText;

  /// The label will be displayed on top of the input.
  final String? label;

  /// How to capitalize this text input.
  final TextCapitalization textCapitalization;

  /// A controller to manipulate the input component.
  final TextEditingController? controller;

  /// Associated keyboard to this input (on mobile).
  final TextInputAction? textInputAction;

  /// Adapt mobile keyboard to this input (sentences, email, ...).
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).primaryColor;

    final BorderRadius borderRadius = BorderRadius.circular(4.0);

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
              filled: true,
              fillColor: Colors.white,
              hintText: hintText,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: maxLines == null ? 8.0 : 0.0,
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
      ],
    );
  }
}
