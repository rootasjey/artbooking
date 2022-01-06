import 'package:artbooking/types/shortcuts_intent/enter_intent.dart';
import 'package:artbooking/types/shortcuts_intent/escape_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Add keyboard shortcuts events to a [Widget].
/// Events triggered: [escape], [space], [enter].
/// Supply a [focusNode] parameter to force focus request
/// if it doesn't automatically works.
class ValidationShortcuts extends StatelessWidget {
  const ValidationShortcuts({
    Key? key,
    required this.child,
    this.onValidate,
    this.onCancel,
    this.focusNode,
  }) : super(key: key);

  final Widget child;
  final Function()? onValidate;
  final Function()? onCancel;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      focusNode?.requestFocus();
    });

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.enter): const EnterIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): const EnterIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const EscapeIntent(),
      },
      child: Actions(
        actions: {
          EnterIntent: CallbackAction<EnterIntent>(
            onInvoke: (EnterIntent enterIntent) {
              onValidate?.call();
            },
          ),
          EscapeIntent: CallbackAction<EscapeIntent>(
            onInvoke: (EscapeIntent escapeIntent) {
              onCancel?.call();
            },
          ),
        },
        child: Focus(
          autofocus: true,
          focusNode: focusNode,
          child: child,
        ),
      ),
    );
  }
}
