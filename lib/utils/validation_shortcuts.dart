import 'package:artbooking/utils/shortcut_intents.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ValidationShortcuts extends StatelessWidget {
  const ValidationShortcuts({
    Key? key,
    required this.child,
    this.onValidate,
    this.onCancel,
  }) : super(key: key);

  final Widget child;
  final Function()? onValidate;
  final Function()? onCancel;

  @override
  Widget build(BuildContext context) {
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
          child: child,
        ),
      ),
    );
  }
}
