import 'dart:async';
import 'dart:collection';

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
