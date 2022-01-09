import 'dart:async';
import 'dart:collection';

import 'package:artbooking/globals/utilities.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class _MessageItem<T> {
  final String message;
  Completer<Future<T>> completer;

  _MessageItem(this.message) : completer = Completer<Future<T>>();
}

class FlashUtilities {
  const FlashUtilities();

  static Completer<BuildContext> _buildCompleter = Completer<BuildContext>();
  static Queue<_MessageItem> _messageQueue = Queue<_MessageItem>();
  static Completer? _previousCompleter;
  static FlashController? _previousController;
  static String _currentProgressId = '';

  void init(BuildContext context) {
    if (_buildCompleter.isCompleted == false) {
      _buildCompleter.complete(context);
    }
  }

  void dispose() {
    _messageQueue.clear();

    if (_buildCompleter.isCompleted == false) {
      _buildCompleter.completeError('NotInitalize');
    }
    _buildCompleter = Completer<BuildContext>();
  }

  void dismissProgress({String id = ''}) {
    if (id.isEmpty) {
      _previousController?.dismiss();
      return;
    }

    if (id == _currentProgressId) {
      _previousController?.dismiss();
    }
  }

  Future<T?> toast<T>(String message) async {
    var context = await _buildCompleter.future;

    // Wait previous toast dismissed.
    if (_previousCompleter?.isCompleted == false) {
      var item = _MessageItem<T?>(message);
      _messageQueue.add(item);
      return await (item.completer.future as FutureOr<T?>);
    }

    _previousCompleter = Completer();

    Future<T?> showToast(String message) {
      return showFlash<T>(
        context: context,
        builder: (context, controller) {
          return Flash<T>.dialog(
            controller: controller,
            alignment: const Alignment(0, 0.5),
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            backgroundColor: Colors.black87,
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 16.0, color: Colors.white),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    Text(message),
                  ],
                ),
              ),
            ),
          );
        },
        duration: const Duration(seconds: 3),
      ).whenComplete(() {
        if (_messageQueue.isNotEmpty) {
          var item = _messageQueue.removeFirst();
          item.completer.complete(showToast(item.message));
        } else {
          _previousCompleter!.complete();
        }
      });
    }

    return showToast(message);
  }

  Color _backgroundColor(BuildContext context) {
    var theme = Theme.of(context);
    return theme.dialogTheme.backgroundColor ?? theme.dialogBackgroundColor;
  }

  TextStyle _titleStyle(BuildContext context, [Color? color]) {
    var theme = Theme.of(context);
    return (theme.dialogTheme.titleTextStyle ?? theme.textTheme.headline6)!
        .copyWith(color: color);
  }

  TextStyle _contentStyle(BuildContext context, [Color? color]) {
    var theme = Theme.of(context);
    return (theme.dialogTheme.contentTextStyle ?? theme.textTheme.bodyText2)!
        .copyWith(color: color);
  }

  Future<T?> groundedBottom<T>(
    BuildContext context, {
    String? title,
    required String? message,
    Widget icon = const Icon(UniconsLine.chat_info),
    Duration duration = const Duration(seconds: 5),
    Widget? primaryAction,
  }) {
    return showFlash<T>(
      context: context,
      duration: duration,
      persistent: true,
      builder: (_, controller) {
        _previousController = controller;

        return Flash(
          controller: controller,
          backgroundColor: Theme.of(context).backgroundColor,
          boxShadows: [BoxShadow(blurRadius: 4)],
          barrierBlur: 1.0,
          barrierColor: Colors.black38,
          barrierDismissible: true,
          position: FlashPosition.bottom,
          child: FlashBar(
            icon: icon,
            title: title != null && title.length > 0
                ? Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
            content: Opacity(
              opacity: 0.5,
              child: Text(
                message!,
                overflow: TextOverflow.ellipsis,
                style: Utilities.fonts.style(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            primaryAction: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (primaryAction != null) primaryAction,
                if (primaryAction == null)
                  IconButton(
                    icon: Icon(
                      UniconsLine.times,
                    ),
                    onPressed: () => controller.dismiss(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<T?> infoBar<T>(
    BuildContext context, {
    String? title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    return showFlash<T>(
      context: context,
      duration: duration,
      builder: (context, controller) {
        return Flash(
          controller: controller,
          horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          backgroundColor: Colors.black87,
          child: FlashBar(
            title: title == null
                ? null
                : Text(title, style: _titleStyle(context, Colors.white)),
            content: Text(message, style: _contentStyle(context, Colors.white)),
            icon: Icon(Icons.info_outline, color: Colors.green[300]),
            indicatorColor: Colors.green[300],
          ),
        );
      },
    );
  }

  Future<T?> successBar<T>(
    BuildContext context, {
    String? title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    return showFlash<T>(
      context: context,
      duration: duration,
      builder: (context, controller) {
        return Flash(
          controller: controller,
          horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          backgroundColor: Colors.black87,
          child: FlashBar(
            title: title == null
                ? null
                : Text(title, style: _titleStyle(context, Colors.white)),
            content: Text(message, style: _contentStyle(context, Colors.white)),
            icon: Icon(Icons.check_circle, color: Colors.blue[300]),
            indicatorColor: Colors.blue[300],
          ),
        );
      },
    );
  }

  Future<T?> errorBar<T>(
    BuildContext context, {
    String? title,
    required String message,
    ChildBuilder<T>? primaryAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    return showFlash<T>(
      context: context,
      duration: duration,
      builder: (context, controller) {
        return StatefulBuilder(builder: (context, setState) {
          return Flash(
            controller: controller,
            horizontalDismissDirection: HorizontalDismissDirection.horizontal,
            backgroundColor: Colors.black87,
            child: FlashBar(
              title: title == null
                  ? null
                  : Text(title, style: _titleStyle(context, Colors.white)),
              content:
                  Text(message, style: _contentStyle(context, Colors.white)),
              primaryAction: primaryAction?.call(context, controller, setState),
              icon: Icon(Icons.warning, color: Colors.red[300]),
              indicatorColor: Colors.red[300],
            ),
          );
        });
      },
    );
  }

  Future<T?> actionBar<T>(
    BuildContext context, {
    String? title,
    required String message,
    required ChildBuilder<T> primaryAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    return showFlash<T>(
      context: context,
      duration: duration,
      builder: (context, controller) {
        return StatefulBuilder(builder: (context, setState) {
          return Flash(
            controller: controller,
            horizontalDismissDirection: HorizontalDismissDirection.horizontal,
            backgroundColor: Colors.black87,
            child: FlashBar(
              title: title == null
                  ? null
                  : Text(title, style: _titleStyle(context, Colors.white)),
              content:
                  Text(message, style: _contentStyle(context, Colors.white)),
              primaryAction: primaryAction.call(context, controller, setState),
            ),
          );
        });
      },
    );
  }

  Future<T?> dialogWithChild<T>(
    BuildContext context, {
    required Widget child,
  }) {
    return showFlash<T>(
      context: context,
      persistent: false,
      builder: (context, controller) {
        return Flash.dialog(
          controller: controller,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          margin: const EdgeInsets.only(
            left: 120.0,
            right: 120.0,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(8.0),
          ),
          child: FlashBar(
            content: Container(
              height: MediaQuery.of(context).size.height - 100.0,
              padding: const EdgeInsets.all(60.0),
              child: child,
            ),
          ),
        );
      },
    );
  }

  Future<T?> simpleDialog<T>(
    BuildContext context, {
    String? title,
    required String message,
    Color? messageColor,
    ChildBuilder<T>? negativeAction,
    ChildBuilder<T>? positiveAction,
  }) {
    return showFlash<T>(
      context: context,
      persistent: false,
      builder: (context, controller) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Flash.dialog(
              controller: controller,
              backgroundColor: _backgroundColor(context),
              margin: const EdgeInsets.only(left: 40.0, right: 40.0),
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              child: FlashBar(
                title: title == null
                    ? null
                    : Text(title, style: _titleStyle(context)),
                content:
                    Text(message, style: _contentStyle(context, messageColor)),
                actions: <Widget>[
                  if (negativeAction != null)
                    negativeAction(context, controller, setState),
                  if (positiveAction != null)
                    positiveAction(context, controller, setState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<T?> customDialog<T>(
    BuildContext context, {
    ChildBuilder<T>? titleBuilder,
    required ChildBuilder messageBuilder,
    ChildBuilder<T>? negativeAction,
    ChildBuilder<T>? positiveAction,
  }) {
    return showFlash<T>(
      context: context,
      persistent: false,
      builder: (context, controller) {
        return StatefulBuilder(
          builder: (context, setState) {
            final childTitle = titleBuilder != null
                ? titleBuilder.call(context, controller, setState)
                : Container();

            return Flash.dialog(
              controller: controller,
              backgroundColor: _backgroundColor(context),
              margin: const EdgeInsets.only(left: 40.0, right: 40.0),
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              child: FlashBar(
                title: DefaultTextStyle(
                  style: _titleStyle(context),
                  child: childTitle,
                ),
                content: DefaultTextStyle(
                  style: _contentStyle(context),
                  child: messageBuilder.call(context, controller, setState),
                ),
                actions: <Widget>[
                  if (negativeAction != null)
                    negativeAction(context, controller, setState),
                  if (positiveAction != null)
                    positiveAction(context, controller, setState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<T?> blockDialog<T>(
    BuildContext context, {
    required Completer<T> dismissCompleter,
  }) {
    var controller = FlashController<T>(
      context,
      builder: (context, FlashController<T> controller) {
        return Flash.dialog(
          controller: controller,
          barrierDismissible: false,
          backgroundColor: Colors.black87,
          margin: const EdgeInsets.only(left: 40.0, right: 40.0),
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: const CircularProgressIndicator(strokeWidth: 2.0),
          ),
        );
      },
      persistent: false,
      onWillPop: () => Future.value(false),
    );
    dismissCompleter.future.then((value) => controller.dismiss(value));
    return controller.show();
  }

  Future<String?> inputDialog(
    BuildContext context, {
    String? title,
    String? message,
    String? defaultValue,
    bool persistent = true,
    WillPopCallback? onWillPop,
  }) {
    var editingController = TextEditingController(text: defaultValue);
    return showFlash<String>(
      context: context,
      persistent: persistent,
      onWillPop: onWillPop,
      builder: (context, controller) {
        var theme = Theme.of(context);
        return Flash<String>.bar(
          controller: controller,
          barrierColor: Colors.black54,
          borderWidth: 3,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
          child: FlashBar(
            title: title == null
                ? null
                : Text(title, style: TextStyle(fontSize: 24.0)),
            content: Column(
              children: [
                if (message != null) Text(message),
                Form(
                  child: TextFormField(
                    controller: editingController,
                    autofocus: true,
                  ),
                ),
              ],
            ),
            indicatorColor: theme.primaryColor,
            primaryAction: IconButton(
              onPressed: () {
                var message = editingController.text;
                controller.dismiss(message);
              },
              icon: Icon(Icons.send, color: theme.colorScheme.secondary),
            ),
          ),
        );
      },
    );
  }

  Future<T?> showProgress<T>(
    BuildContext context, {
    String? title,
    String progressId = '',
    required String message,
    Widget icon = const Icon(UniconsLine.chat_info),
    Duration duration = const Duration(seconds: 10),
  }) {
    if (progressId.isNotEmpty) {
      _currentProgressId = progressId;
    }

    return showFlash<T>(
      context: context,
      duration: duration,
      persistent: true,
      builder: (_, controller) {
        _previousController = controller;

        return Flash(
          controller: controller,
          backgroundColor: Theme.of(context).backgroundColor,
          boxShadows: [BoxShadow(blurRadius: 4)],
          barrierBlur: 3.0,
          barrierColor: Colors.black38,
          barrierDismissible: true,
          position: FlashPosition.top,
          child: FlashBar(
            icon: icon,
            title: title != null && title.length > 0
                ? Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
            content: Opacity(
              opacity: 0.5,
              child: Text(
                message,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            showProgressIndicator: true,
            primaryAction: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    UniconsLine.times,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                  onPressed: () => controller.dismiss(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

typedef ChildBuilder<T> = Widget Function(
    BuildContext context, FlashController<T?> controller, StateSetter setState);
