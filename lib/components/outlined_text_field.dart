import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

/// A TextField with a predefined outlined border.
class OutlinedTextField extends StatelessWidget {
  const OutlinedTextField({
    Key? key,
    this.label,
    this.controller,
    this.hintText = '',
    this.onChanged,
    this.onSubmitted,
    this.sizeContaints = const Size(300.0, 45.0),
  }) : super(key: key);

  /// The label will be displayed on top of the input.
  final String? label;

  /// A controller to manipulate the input component.
  final TextEditingController? controller;

  /// The [hintText] will be displayed inside the input.
  final String hintText;

  /// Fires when the user modify the input's value.
  final Function(String)? onChanged;

  /// Fires when the user send/validate the input's value.
  final Function(String)? onSubmitted;

  /// Maximum size for the input.
  final Size sizeContaints;

  @override
  Widget build(BuildContext context) {
    final _primaryColor = Theme.of(context).primaryColor;

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
                style: Utilities.fonts.style(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ConstrainedBox(
          constraints: BoxConstraints.tight(sizeContaints),
          child: TextField(
            autofocus: true,
            controller: controller,
            textInputAction: TextInputAction.next,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: Utilities.fonts.style(
              fontWeight: FontWeight.w600,
            ),
            cursorColor: _primaryColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: hintText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8.0,
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
